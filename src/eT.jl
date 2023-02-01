module eT

using Molecules
using GaussianBasis

export run_ccsd, run_cholesky

include("inputs.jl")
include("read_cholesky.jl")

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

end
