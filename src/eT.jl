module eT

using Molecules
using Conda

include("input.jl")
include("output.jl")

eT_launch = "eT_launch.py"

eT_path_file = abspath(first(DEPOT_PATH), "eT/eT_path.txt")

if isfile(eT_path_file)
    eT_launch = chomp(read(eT_path_file, String))
else
    throw("eT.jl not setup properly! Running `]build eT` might fix the issue.")
end

function set_eT_path(new_path)
    global eT_launch
    eT_launch = new_path
end

function run_ctest(jobs)
    build_dir = splitdir(abspath(eT_launch))[1]

    old_dir = pwd()
    cd(build_dir)

    run(`$(Conda.BINDIR)/ctest -j$jobs`)

    cd(old_dir)
end

end
