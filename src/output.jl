
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

const hf_energy_regex::Regex =
    r"Total energy: +(-?\d+\.\d+)"

export get_hf_energy
function get_hf_energy(out::OutputFile)
    parse(Float64, match(hf_energy_regex, out.contents["eT"]).captures[1])
end

include("parsing_output/matrix.jl")

export get_molecular_gradient
function get_molecular_gradient(out::OutputFile)
    g = Float64[]
    file = Iterators.Stateful(
        eachsplit(out.contents["eT.molecular_gradient"], '\n')
    )

    # Skip first 5 lines
    for _ in 1:5
        popfirst!(file)
    end

    for l in file
        s = split(l)

        if isone(length(s))
            break
        end

        append!(g, parse(Float64, n) for n in s[3:end])
    end

    reshape(g, 3, length(g) ÷ 3)
end

export write_molden
function write_molden(io::IO, out::OutputFile)
    write(io, out.contents["eT.molden"])
end
