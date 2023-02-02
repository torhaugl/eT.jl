function input_ccsd(mol, bset; kwargs...)
    xyz = chomp(string(Molecules.get_xyz(mol)))
    memory = get(kwargs, :memory, 8)
    cholesky_storage = haskey(kwargs, :cholesky_storage) ? "\ncholesky storage: " * kwargs[:cholesky_storage] : ""
    max_ccsd_iterations = get(kwargs, :max_ccsd_iterations, 100)
    ccsd_threshold = get(kwargs, :ccsd_threshold, 1e-10)
"""system
end system

do
    ground state
end do

memory
    available: $memory
end memory

print
    output print level: normal
end print

method
    hf
    ccsd
end method

solver cholesky
    threshold: 1.0d-12
end solver cholesky

integrals $(cholesky_storage)
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
basis: $bset
$xyz
end geometry"""
end

function input_hf(mol, bset; kwargs...)
    xyz = chomp(string(Molecules.get_xyz(mol)))
    memory = get(kwargs, :memory, 8)
    max_hf_iterations = get(kwargs, :max_ccsd_iterations, 100)
    hf_threshold = get(kwargs, :ccsd_threshold, 1e-10)
"""system
end system

do
    ground state
end do

memory
    available: $memory
end memory

print
    output print level: normal
end print

method
    hf
end method

solver scf
    energy threshold: $hf_threshold
    gradient threshold: $hf_threshold
    max iterations: $max_hf_iterations
    diis dimension: 8
end solver scf

geometry
basis: $bset
$xyz
end geometry"""
end

function input_ccsd_polarizability(mol, bset, frequency; kwargs...)
    xyz = chomp(string(Molecules.get_xyz(mol)))
    memory = get(kwargs, :memory, 8)
    cholesky_storage = haskey(kwargs, :cholesky_storage) ? "\ncholesky storage: " * kwargs[:cholesky_storage] : ""
    max_ccsd_iterations = get(kwargs, :max_ccsd_iterations, 100)
    ccsd_threshold = get(kwargs, :ccsd_threshold, 1e-10)
"""system
end system

do
    response
end do

memory
    available: $memory
end memory

print
    output print level: normal
end print

method
    hf
    ccsd
end method

solver cholesky
    threshold: 1.0d-12
end solver cholesky

integrals $(cholesky_storage)
end integrals

solver scf
    gradient threshold: 1.0d-12
end solver scf

cc response
    eom
    polarizabilities: {11,12,13,22,23,33}
    frequencies: {$("$frequency"[begin+1:end-1])}
    dipole length
end cc response

solver cc gs
    omega threshold: $ccsd_threshold
    energy threshold: $ccsd_threshold
    diis dimension: 8
    max iterations: $max_ccsd_iterations
end solver cc gs

solver cc multipliers
    threshold: 1.0d-10
end solver cc multipliers

solver cc response
    threshold: 1.0d-10
end solver cc response

geometry
basis: $bset
$xyz
end geometry"""
end