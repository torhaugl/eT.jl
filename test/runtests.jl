using Test
using eT
using Molecules

mol = Molecule("""
O  0.0       0.0  0.0
H  0.756952  0.0  0.585883
H -0.756952  0.0  0.585883
""")
bset = "cc-pVDZ"

function test_hf_energy()
    threshold = 1.0e-10
    inp = InputFile(mol, bset)

    add_fields!(inp, "do" => ["ground state"])
    add_fields!(inp, "method" => ["hf"])
    add_fields!(inp, "solver scf" => ["gradient threshold: $threshold"])

    out = run_input(inp)
    return get_hf_energy(out)
end

function test_ccsd_energy()
    threshold = 1.0e-10

    inp = InputFile(mol, bset)
    add_fields!(inp, "do" => ["ground state"])
    add_fields!(inp, "method" => ["hf", "ccsd"])
    add_fields!(inp, "solver scf" => ["gradient threshold: $threshold"])
    add_fields!(inp, "solver cholesky" => ["threshold: $threshold"])
    add_fields!(inp, "solver cc gs" => ["omega threshold: $threshold"])

    out = run_input(inp)
    return get_cc_energy(out)
end

function test_cholesky()
    threshold = 1.0e-10

    inp = InputFile(mol, bset)
    add_fields!(inp, "do" => ["ground state"])
    add_fields!(inp, "method" => ["hf", "ccsd"])
    add_fields!(inp, "solver scf" => ["gradient threshold: $threshold"])
    add_fields!(inp, "solver cholesky" => ["threshold: $threshold"])
    add_fields!(inp, "solver cc gs" => ["omega threshold: $threshold"])
    add_fields!(inp, "solver cc multipliers" => ["threshold: $threshold"])
    add_fields!(inp, "solver cc response" => ["threshold: $threshold"])
    add_fields!(inp, "integrals" => ["cholesky storage: disk"])

    out = run_input(inp; cholesky=true)
    L_pqJ, norb = read_cholesky(out)
    return sum(abs, L_pqJ), norb
end

function test_ccsd_polarizability()
    threshold = 1.0e-10
    frequency = [0.01]

    inp = InputFile(mol, bset)
    add_fields!(inp, "do" => ["response"])
    add_fields!(inp, "method" => ["hf", "ccsd"])
    add_fields!(inp, "solver scf" => ["gradient threshold: $threshold"])
    add_fields!(inp, "solver cholesky" => ["threshold: $threshold"])
    add_fields!(inp, "solver cc gs" => ["omega threshold: $threshold"])
    add_fields!(inp, "solver cc multipliers" => ["threshold: $threshold"])
    add_fields!(inp, "solver cc response" => ["threshold: $threshold"])
    add_fields!(inp, "cc response" => ["lr", "dipole length", "polarizabilities", "frequencies: {$("$frequency"[begin+1:end-1])}"])

    out = run_input(inp)
    polarizability_matrix = get_polarizability(out)

    return polarizability_matrix
end

@testset "eT.jl" begin
    @test test_hf_energy() ≈ -76.026798614918
    @test test_ccsd_energy() ≈ -76.24008257677
    @test isapprox(test_cholesky()[1], 391.543634972865, atol=1e-5)
    @test test_cholesky()[2] == (nmo=24, no=5, nv=19, nJ=274)
end

@testset "hf_energy" begin
    inp = make_input_hf(mol, "cc-pvdz", "solver scf" => ["print orbitals"])
    out = run_input(inp)

    E = get_hf_energy(out)

    @test E ≈ -76.02679861491

    ε = get_mo_energy(out)

    @test sum(ε) ≈ 13.546816246511554
end
