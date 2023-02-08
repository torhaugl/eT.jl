
export OutputFile
struct OutputFile
    contents::Dict{String,String}

    function OutputFile(directory)
        contents = Dict{String,String}()

        for entry in readdir(directory)
            name, ext = splitext(entry)

            if ext == ".out"
                contents[name] = read(joinpath(directory, entry), String)
            elseif ext == ".molden"
                contents["eT.molden"] = read(
                    joinpath(directory, "eT.molden"), String
                )
            end
        end

        new(contents)
    end
end

function Base.show(io::IO, out::OutputFile)
    println(io, collect(keys(out.contents)))
end

include("parsing_output/energy.jl")
include("parsing_output/matrix.jl")
include("parsing_output/molecular_gradient.jl")
include("parsing_output/mo_information.jl")
include("parsing_output/geometry.jl")
