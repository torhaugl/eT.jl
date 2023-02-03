const hf_energy_regex::Regex =
    r"Total energy: +(-?\d+\.\d+)"

export get_hf_energy
function get_hf_energy(out::OutputFile)
    parse(Float64, match(hf_energy_regex, out.contents["eT"]).captures[1])
end
