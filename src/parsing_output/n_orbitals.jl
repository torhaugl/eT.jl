export n_orbitals

function n_orbitals(out::OutputFile)
    norb = Dict{String, Int}()
    norb["nao"] = parse(Int, match(r"Number of atomic orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    norb["orthogonal nao"] = parse(Int, match(r"Number of orthonormal atomic orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    norb["no"] = parse(Int, match(r"Number of occupied orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    norb["nv"] = parse(Int, match(r"Number of virtual orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    norb["nmo"] = parse(Int, match(r"Number of molecular orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    return norb
end