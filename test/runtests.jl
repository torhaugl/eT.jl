using Test
using eT
using Molecules

function test_ccsd_energy()
    mol = Molecules.parse_string("""
    O  0.0       0.0  0.0
    H  0.756952  0.0  0.585883
    H -0.756952  0.0  0.585883
    """)
    bset = "cc-pvdz"
    E = run_ccsd(mol, bset)
    return E
end

function test_cholesky()
    mol = Molecules.parse_string("""
    O  0.0       0.0  0.0
    H  0.756952  0.0  0.585883
    H -0.756952  0.0  0.585883
    """)
    bset = "cc-pvdz"
    L_pqJ, norb = run_cholesky(mol, bset)
    return sum(abs, L_pqJ), norb
end

@testset "eT.jl" begin
    @test test_ccsd_energy() ≈ -76.24008257677
    @test abs(test_cholesky()[1] - 391.54512680090147) < 1e-5
    @test test_cholesky()[2] == (nmo=24, no=5, nv=19, nJ=279)
end

@testset "hf_energy" begin
    mol = Molecule("""
    O  0.0       0.0  0.0
    H  0.756952  0.0  0.585883
    H -0.756952  0.0  0.585883
    """)

    inp = make_input_hf(mol, "cc-pvdz", "solver scf" => ["print orbitals"])
    out = run_input(inp)

    E = get_hf_energy(out)

    @test E ≈ -76.02679861491

    ε = get_mo_energy(out)

    @test sum(ε) ≈ 13.546816246511554
end
