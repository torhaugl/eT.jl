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

# Good luck reading these:
const mo_coeff_regex1 = r"- Molecular orbital coefficients\s+(.+)"s
const mo_coeff_regex2 = r"AO +Center +l +m_l +(.+?\n\s+-+.+?-{2,})"s
const mo_coeff_regex3 = r"(.+?)\n\s+-+\n(.+?)\n\s+-{2,}"s
const mo_coeff_regex4 = r"(\d+) +\d+ +\w\w? +\w +(?:-?\d+ )? *(.+)"

export get_mo_coeff
function get_mo_coeff(out::OutputFile)
    d = Dict{Tuple{Int,Int},Float64}()

    mo_coeff_string = match(
        mo_coeff_regex1, out.contents["eT.mo_information"]
    ).captures[1]

    for m1 in eachmatch(mo_coeff_regex2, mo_coeff_string)
        m2 = match(mo_coeff_regex3, m1.captures[1])
        columns = [parse(Int, n) for n in eachsplit(m2.captures[1])]

        for l in eachsplit(m2.captures[2], '\n')
            m3 = match(mo_coeff_regex4, l)
            row_n = parse(Int, m3.captures[1])

            for (i, c) in enumerate(eachsplit(m3.captures[2]))
                d[(row_n, columns[i])] = parse(Float64, c)
            end
        end
    end

    h = maximum(i for (i, _) in keys(d))
    w = maximum(j for (_, j) in keys(d))

    C = zeros(h, w)

    for ((i, j), c) in d
        C[i, j] = c
    end

    C
end
