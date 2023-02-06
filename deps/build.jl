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
        "gcc", "gfortran", "git", "tar"
    ]

    @warn "Assuming the following dependencies: $dependencies"

    for dep in dependencies
        @info "Checking if $dep exists"
        run(`$dep --version`)
    end

    @warn "Assuming installation of MKL is in environment"

    ninja_exe = "$(pwd())/ninja-build/ninja"

    @info "Installing ninja"
    begin
        mkdir("ninja-build")
        cd("ninja-build")

        download(
            "https://github.com/ninja-build/ninja/releases\
/download/v1.11.1/ninja-linux.zip",
            "ninja-linux.zip"
        )

        run(`unzip ninja-linux.zip`)

        cd("..")
    end

    cmake_exe = "$(pwd())/cmake-3.25.2-linux-x86_64/bin/"
    @info "Installing cmake"
    begin
        download(
            "https://github.com/Kitware/CMake/releases/download/v3.25.2/\
cmake-3.25.2-linux-x86_64.tar.gz",
            "cmake.tar.gz"
        )

        run(`tar xzf cmake.tar.gz`)
    end

    libcint_version = "5.1.9"
    libcint_install = "$eT_dir/libcint-$libcint_version/install/"
    @info "Installing libcint"
    libcint_task = @async begin
        download(
            "https://github.com/sunqm/libcint/\
archive/refs/tags/v$libcint_version.tar.gz",
            "libcint.tar.gz"
        )
        run(`tar xzf libcint.tar.gz`)
        cd("libcint-$libcint_version")

        mkdir("build")
        cd("build")

        run(`$cmake_exe/cmake .. -DBUILD_SHARED_LIBS=0 -DPYPZPX=1 \
-DCMAKE_INSTALL_PREFIX=$libcint_install -GNinja \
-DCMAKE_MAKE_PROGRAM=$ninja_exe`)

        run(`$cmake_exe/cmake --build . --target install`)
        cd("../..")
    end

    @info "Building eT"
    begin
        run(`git clone https://gitlab.com/eT-program/eT --recursive`)

        cd("eT")

        run(`git checkout development`)

        wait(libcint_task)

        run(`bash $orig_dir/envoke-setup.sh \
$libcint_install $cmake_exe $ninja_exe`)

        cd("build")

        run(`$ninja_exe`)

        eT_launch = "$(pwd())/eT_launch.py"

        cd("../..")
    end

    @info "eT_launch is now at $eT_launch"

    open(joinpath(eT_dir, "eT_path.txt"), "w") do io
        print(io, eT_launch)
    end

    cd(orig_dir)
end
