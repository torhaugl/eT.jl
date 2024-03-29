export InputFile, make_input_hf, add_fields!, run_input

global oldeT = false

struct InputFile
    molecule::Molecule{Atom}
    basis::String
    sections::Dict{String,Vector{String}}
end

function InputFile(molecule, basis)
    InputFile(
        molecule,
        basis,
        Dict{String,Vector{String}}()
    )
end

function Base.show(io::IO, inp::InputFile)
    if (~oldeT)
       print(io, "- ")
    end
    println(io, "system")
    println(io, "    charge: ", inp.molecule.charge)
    println(io, "    multiplicity: ", inp.molecule.multiplicity)
    for (section, fields) in inp.sections
        if section == "system"
            for field in fields
                println(io, "    ", field)
            end
        end
    end
    if (oldeT)
        println(io, "end system\n")
    end

    for (section, fields) in inp.sections
        if section == "system"
            continue
        end
        if (~oldeT)
            print(io, "- ")
        end
        println(io, section)
        for field in fields
            println(io, "    ", field)
        end
	if (oldeT)
            println(io, "end ", section, "\n")
	end
    end

    if (~oldeT)
       print(io, "- ")
    end
    println(io, "geometry")
    println(io, "basis: ", inp.basis)
    print(io, Molecules.get_xyz(inp.molecule))
    if (oldeT)
        println(io, "end geometry")
    end
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

function make_input_hf(molecule, basis, args...)
    inp = InputFile(molecule, basis)

    inp.sections["do"] = ["ground state"]
    inp.sections["method"] = ["hf"]

    add_fields!(inp, args...)

    inp
end

function run_input(inp::InputFile; kwargs...)
    mktempdir() do scratch
        inp_file = joinpath(scratch, "eT_jl.inp")

        open(inp_file, "w") do io
            print(io, inp)
        end

        try 
            omp = get(kwargs, :omp, 1)
	    eT_launch_path = get(kwargs, :eT_launch, eT_launch)
	    println("$eT_launch_path $inp_file --omp $omp -ks --scratch $scratch")
            run(`$eT_launch_path $inp_file --omp $omp -ks --scratch $scratch`)
        catch e
            display(e)
            ofile = joinpath(scratch, "eT.out")
            println(read(`cat $(ofile)`, String))
        end

        OutputFile(scratch; kwargs...)
    end
end
