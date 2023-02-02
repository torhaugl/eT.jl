
export OutputFile
struct OutputFile
    contents::Dict{String,String}

    function OutputFile(directory)
        contents = Dict{String,String}()

        for entry in readdir(directory)
            name, ext = splitext(entry)

            if ext == ".out"
                contents[name] = read(joinpath(directory, entry), String)
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
