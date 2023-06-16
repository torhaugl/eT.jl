const hf_energy_regex::Regex =
    r"Total energy: +(-?\d+\.\d+)"
const cc_energy_regex::Regex =
    r"Final ground state energy \(a.u.\): +(-?\d+\.\d+)"
const mp2_energy_regex::Regex =
    r"MP2 energy: +(-?\d+\.\d+)"
const cc_es_energy_regex::Regex =
    r"Energy \(Hartree\): +(-?\d+\.\d+)"
const fci_energy_regex::Regex =
    r"Energy \(Hartree\): +(-?\d+\.\d+)"

export get_hf_energy
export get_mp2_energy
export get_cc_energy, get_cc_es_energies
export get_fci_energy, get_fci_energies

function get_hf_energy(out::OutputFile)
    parse(Float64, match(hf_energy_regex, out.contents["eT"]).captures[1])
end

function get_mp2_energy(out::OutputFile)
    parse(Float64, match(mp2_energy_regex, out.contents["eT"]).captures[1])
end

function get_cc_energy(out::OutputFile)
    parse(Float64, match(cc_energy_regex, out.contents["eT"]).captures[1])
end

function get_cc_es_energies(out::OutputFile)
    parse.(Float64, match(cc_es_energy_regex, out.contents["eT"]).captures)
end

function get_fci_energy(out::OutputFile)
    parse(Float64, match(fci_energy_regex, out.contents["eT"]).captures[1])
end

function get_fci_energies(out::OutputFile)
    parse.(Float64, match(fci_energy_regex, out.contents["eT"]).captures)
end
