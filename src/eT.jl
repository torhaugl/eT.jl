module eT

using Molecules

export run_ccsd, run_cholesky, run_hf, run_ccsd_polarizability

include("input.jl")
include("inputs.jl")
include("read_cholesky.jl")

eT_launch = "eT_launch.py"

function set_eT_path(new_path)
    global eT_launch
    eT_launch = new_path
end

function run_input(fname, ofname, omp)
    scratch = joinpath(splitpath(fname)[begin:end-1])
    eT_exe = joinpath(ENV["HOME"], "opt/eT/build/eT_launch.py")

    if !isfile(eT_exe)
        error("Did not find eT executable at $eT_exe")
    end

    try
        run(`python3 $eT_exe -nt -ks --scratch $scratch --omp $omp $fname -of $ofname`)
    catch e
        println(read(`cat $ofname`, String))
        display(e)
    end
end

function read_orbital_energies(fname)
    # Read binary file with orbital energies and orbital coefficients
    ϵ = open(fname, "r") do f
        nao = read(f, Int64);
        nmo = read(f, Int64);
        @assert nao == nmo

        x = Vector{Float64}(undef, nmo);
        read!(f, x)
    end
    return ϵ
end


function run_hf(mol::Vector{Atom}, bset::String; kwargs...)
    omp = get(kwargs, :omp, 1)

    input_file = input_hf(mol, bset; kwargs...)

    E, ϵ = mktempdir() do scratch
        fname = joinpath(scratch, "hf.inp")
        ofname = joinpath(scratch, "hf.out")
        open(fname, "w") do file
            write(file, input_file)
        end
        run_input(fname, ofname, omp)

        E_HF = parse(Float64, split(read(`grep 'Total energy' $ofname`, String), ':')[2][1:end-2])
        ϵ = read_orbital_energies(joinpath(scratch, "orbital_coefficients"))
        E_HF, ϵ
    end # delete scratch

    return E, ϵ
end

function run_ccsd(mol::Vector{Atom}, bset::String; kwargs...)
    omp = get(kwargs, :omp, 1)

    input_file = input_ccsd(mol, bset; kwargs...)

    E = mktempdir() do scratch
        fname = joinpath(scratch, "ccsd.inp")
        ofname = joinpath(scratch, "ccsd.out")
        open(fname, "w") do file
            write(file, input_file)
        end
        run_input(fname, ofname, omp)

        # Read CCSD energy
        parse(Float64, split(read(`grep 'Final ground' $ofname`, String), ':')[2][1:end-2])
    end # delete scratch

    return E
end

function run_cholesky(mol::Vector{Atom}, bset::String; kwargs...)
    omp = get(kwargs, :omp, 1)

    input_file = input_ccsd(mol, bset; ccsd_threshold=1e8, cholesky_storage="disk", kwargs...)

    L_pqJ, norb = mktempdir() do scratch
        fname = joinpath(scratch, "ccsd.inp")
        ofname = joinpath(scratch, "ccsd.out")
        open(fname, "w") do file
            write(file, input_file)
        end
        run_input(fname, ofname, omp)

        read_cholesky(scratch)
    end # delete scratch

    return L_pqJ, norb
end

function run_ccsd_polarizability(mol::Vector{Atom}, bset::String, frequency; kwargs...)
    omp = get(kwargs, :omp, 1)

    input_file = input_ccsd_polarizability(mol, bset, frequency; kwargs...)

    polarizability_vec = mktempdir() do scratch
        fname = joinpath(scratch, "ccsd.inp")
        ofname = joinpath(scratch, "ccsd.out")
        open(fname, "w") do file
            write(file, input_file)
        end
        run_input(fname, ofname, omp)

        # Read polarizability
        -parse.(Float64, split(read(pipeline(`grep '<< ' $ofname`, `cut -d: -f2`), String), '\n')[begin:end-1])
    end # delete scratch

    n = 0
    polarizability_matrix = zeros(Float64, (3,3,length(frequency)))
    for freq = 1:length(frequency), i = 1:3, j=1:i
        n += 1
        polarizability_matrix[i,j,freq] = polarizability_matrix[j,i,freq] = polarizability_vec[n]
    end

    return polarizability_matrix
end

end
