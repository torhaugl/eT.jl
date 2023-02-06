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

    ninja_exe = "$eT_dir/ninja"

    ninja_task = @async begin
        download(
            "https://github.com/ninja-build/ninja/releases\
/download/v1.11.1/ninja-linux.zip",
            "ninja-linux.zip"
        )
        run(`unzip ninja-linux.zip`)
    end

    cmake_exe = "$eT_dir/cmake-3.25.2-linux-x86_64/bin/"
    @info "Installing cmake"
    cmake_task = @async begin
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

        wait($ninja_task)
        wait($cmake_task)

        run(`bash $orig_dir/build-libcint.sh \
libcint-$libcint_version $cmake_exe $ninja_exe`)
    end

    mkl_root = "$eT_dir/mkl_apt/"
    @info "Installing mkl"
    mkl_task = @async begin
        download(
            "https://folk.ntnu.no/marcustl/mkl/mkl_apt.tar.xz",
            "mkl_apt.tar.xz"
        )

        run(`tar xf mkl_apt.tar.xz`)
    end

    eT_launch = "$eT_dir/eT/build/eT_launch.py"
    @info "Building eT"
    begin
        run(`git clone https://gitlab.com/eT-program/eT --recursive`)

        wait(mkl_task)
        wait(libcint_task)

        run(`bash $orig_dir/build-eT.sh \
$libcint_install $cmake_exe $ninja_exe $mkl_root`)
    end

    @info "eT_launch is now at $eT_launch"

    open(joinpath(eT_dir, "eT_path.txt"), "w") do io
        print(io, eT_launch)
    end

    cd(orig_dir)
end
