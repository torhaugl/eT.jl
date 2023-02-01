using eT
using Test
using Molecules
using GaussianBasis

function test_hf_energy()
    mol = Molecules.parse_string("""
    O  0.0       0.0  0.0
    H  0.756952  0.0  0.585883
    H -0.756952  0.0  0.585883
    """)
    bset = "cc-pvdz"
    E, ϵ = run_hf(mol, bset)
    return E, sum(ϵ)
end

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
    @test test_cholesky()[1] ≈ 391.54512680090147
    @test test_cholesky()[2] == (nmo = 24, no = 5, nv = 19, nJ = 279)
    @test all(test_hf_energy() .≈ (-76.02679861491, 13.546816246511554))
end
