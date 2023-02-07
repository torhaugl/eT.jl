export InputFile, make_input_hf

struct InputFile
    molecule::Molecule{Atom}
    basis::String

    sections::Dict{String,Vector{Any}}
end

function InputFile(molecule, basis)
    InputFile(
        molecule,
        basis,
        Dict{String,Vector{Any}}()
    )
end

function Base.show(io::IO, inp::InputFile)
    println(io, "system")
    println(io, "    charge: ", inp.molecule.charge)
    if inp.molecule.multiplicity != 1
        println(io, "    multiplicity: ", inp.molecule.multiplicity)
    end
    println(io, "end system\n")

    for (section, fields) in inp.sections
        println(io, section)
        for field in fields
            if field isa Pair
                fieldname, value = field
                println(io, "    ", fieldname, ": ", value)
            else
                println(io, "    ", field)
            end
        end
        println(io, "end ", section, "\n")
    end

    println(io, "geometry")
    println(io, "basis: ", inp.basis)
    print(io, Molecules.get_xyz(inp.molecule))
    println(io, "end geometry")
end

function add_fields!(inp::InputFile, args...)
    for (section, fields) in args
        if haskey(inp.sections, section)
            append!(inp.sections[section], fields)
        else
            inp.sections[section] = fields
        end
    end
end

export make_input_hf
function make_input_hf(molecule, basis, args...)
    inp = InputFile(molecule, basis)

    inp.sections["do"] = ["ground state"]
    inp.sections["method"] = ["hf"]

    add_fields!(inp, args...)

    inp
end
