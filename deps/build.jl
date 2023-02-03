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
            ""
        end
    end
end

const eT_dir = abspath(first(DEPOT_PATH), "eT")

mkpath(eT_dir)

eT_launch = find_eT()

if !isempty(eT_launch)
    open(joinpath(eT_dir, "eT_path.txt"), "w") do io
        print(io, eT_launch)
    end
else
    # TODO: install eT
    throw("Havent implemented installing eT yet")
end
