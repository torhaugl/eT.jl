function input_ccsd(mol, bset; kwargs...)
    mem = get(kwargs, :memory, 8)
    cholesky_storage = haskey(kwargs, :cholesky_storage) ? "cholesky storage: " * kwargs[:cholesky_storage] : ""
    max_ccsd_iterations = get(kwargs, :max_ccsd_iterations, 100)
    ccsd_threshold = get(kwargs, :ccsd_threshold, 1e-10)
"""system
end system

do
    ground state
end do

memory
    available: $mem
end memory

method
    hf
    ccsd
end method

solver cholesky
    threshold: 1.0d-12
end solver cholesky

integrals
    $(cholesky_storage)
end integrals

solver scf
    gradient threshold: 1.0d-12
end solver scf

solver cc gs
    omega threshold: $ccsd_threshold
    energy threshold: $ccsd_threshold
    diis dimension: 8
    max iterations: $max_ccsd_iterations
end solver cc gs

geometry
basis: $(bset.name)
$(Molecules.get_xyz(mol))end geometry"""
end
