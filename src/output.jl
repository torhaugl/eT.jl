export OutputFile

struct OutputFile
    contents::Dict{String,String}
    binaries::Dict{String,Vector{Float64}}

    function OutputFile(directory; kwargs...)
        contents = Dict{String,String}()
        binaries = Dict{String,Vector{Float64}}()

        for entry in readdir(directory)
            name, ext = splitext(entry)

            # Formatted output-files
            if ext == ".out"
                contents[name] = read(joinpath(directory, entry), String)
            elseif ext == ".molden"
                contents["eT.molden"] = read(
                    joinpath(directory, "eT.molden"), String
                )
            end

            # Binary output-files
            if (get(kwargs, :cholesky, false) == 1) && occursin(r"cholesky_MO_block_\d+", entry)
                binaries[name] = read_vector(joinpath(directory, entry), Float64)
            end
        end

        new(contents, binaries)
    end
end

function read_vector(fname, T::Type)
    x = open(fname, "r") do f
        x = Vector{T}(undef, stat(f).size ÷ sizeof(T))
        read!(f, x)
    end
    return x
end

function Base.show(io::IO, out::OutputFile)
    println(io, collect(keys(out.contents)))
end

include("parsing_output/energy.jl")
include("parsing_output/matrix.jl")
include("parsing_output/molecular_gradient.jl")
include("parsing_output/mo_information.jl")
include("parsing_output/geometry.jl")
include("parsing_output/polarizability.jl")
include("parsing_output/cholesky.jl")