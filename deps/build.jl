using Conda

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

    Conda.add(
        ["git", "tar", "unzip", "gcc", "gxx", "gfortran", "cmake", "ninja"]
    )
    pref = Conda.BINDIR

    libcint_version = "5.1.9"
    libcint_install = "$eT_dir/libcint-$libcint_version/install/"
    @info "Installing libcint"
    libcint_task = @async begin
        download(
            "https://github.com/sunqm/libcint/\
archive/refs/tags/v$libcint_version.tar.gz",
            "libcint.tar.gz"
        )
        run(`$pref/tar xzf libcint.tar.gz`)

        run(`bash $orig_dir/build-libcint.sh \
libcint-$libcint_version $pref`)
    end

    mkl_root = "$eT_dir/mkl_apt/"
    @info "Installing mkl"
    mkl_task = @async begin
        download(
            "https://folk.ntnu.no/marcustl/mkl/mkl_apt.tar.xz",
            "mkl_apt.tar.xz"
        )

        run(`$pref/tar xf mkl_apt.tar.xz`)
    end

    eT_launch = "$eT_dir/eT/build/eT_launch.py"
    @info "Building eT"
    begin
        run(`$pref/git clone https://gitlab.com/eT-program/eT --recursive`)

        wait(mkl_task)
        wait(libcint_task)

        run(`bash $orig_dir/build-eT.sh \
$libcint_install $mkl_root $pref`)
    end

    @info "eT_launch is now at $eT_launch"

    open(joinpath(eT_dir, "eT_path.txt"), "w") do io
        print(io, eT_launch)
    end

    cd(orig_dir)
end
