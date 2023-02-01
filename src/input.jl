
struct InputFile
    molecule::Molecule{Atom}
    basis::String

    methods::Vector{String}
end

function Base.show(io::IO, inp::InputFile)
    println(io, "system")
    println(io, "    charge: ", inp.molecule.charge)
    if inp.molecule.multiplicity != 1
        println(io, "    multiplicity: ", inp.molecule.multiplicity)
    end
    println(io, "end system")
end
