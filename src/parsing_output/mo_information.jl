export write_molden
function write_molden(io::IO, out::OutputFile)
    write(io, out.contents["eT.molden"])
end

const mo_energy_regex1 = r"- Molecular orbital energies\s+-+\n(.+?)\n  -+"s
const mo_energy_regex2 = r"(\d+) +(-?\d+\.\d+)"

export get_mo_energy
function get_mo_energy(out::OutputFile)
    d = Dict{Int,Float64}()

    mo_energy_string = match(
        mo_energy_regex1, out.contents["eT.mo_information"]
    ).captures[1]

    for m in eachmatch(mo_energy_regex2, mo_energy_string)
        n = parse(Int, m.captures[1])
        e = parse(Float64, m.captures[2])

        d[n] = e
    end

    energies = zeros(length(d))

    for (n, e) in d
        energies[n] = e
    end

    energies
end
