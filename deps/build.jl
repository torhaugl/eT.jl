function find_eT()
    if haskey(ENV, "eT")
        ENV["eT"]
    else
        try
            out = Pipe()
            err = Pipe()
            run(pipeline(`which eT_launch.py`, stdout=out, stderr=err))
            close(out.in)
            close(err.in)
            chomp(String(read(out)))
        catch _
            @info "eT not found!"
            ""
        end
    end
end

const eT_dir = abspath(first(DEPOT_PATH), "eT")

rm(eT_dir; force=true, recursive=true)
mkpath(eT_dir)

eT_launch = find_eT()

if !isempty(eT_launch)
    @info "Found eT at $eT_launch"
    open(joinpath(eT_dir, "eT_path.txt"), "w") do io
        print(io, eT_launch)
    end
else
    @info "Installing eT"
    orig_dir = pwd()
    cd(eT_dir)

    dependencies = [
        "ninja", "cmake", "gcc", "gfortran", "git"
    ]

    @warn "Assuming the following dependencies: $dependencies"

    for dep in dependencies
        @info "Checking if $dep exists"
        run(`$dep --version`)
    end

    @warn "Assuming installation of MKL is in environment"

    @info "Installing libcint"

    begin
        run(`git clone --depth 1 --branch v5.1.9 \
https://github.com/sunqm/libcint`)
        cd("libcint")

        mkdir("build")
        cd("build")

        run(`cmake .. -DBUILD_SHARED_LIBS=0 -DPYPZPX=1 \
-DCMAKE_INSTALL_PREFIX=../install/ -GNinja`)

        run(`cmake --build . --target install`)
        cd("../..")
    end

    @info "Building eT"

    begin
        run(`git clone https://gitlab.com/eT-program/eT --recursive`)

        cd("eT")

        run(`git checkout development`)

        run(`./setup.py -clean -lc $eT_dir/libcint/install/`)

        cd("build")

        run(`ninja`)

        eT_launch = "$(pwd())/eT_launch.py"
    end

    @info "eT_launch is now at $eT_launch"

    cd(orig_dir)
end
