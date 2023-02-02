
export run_input
function run_input(inp::InputFile)
    mktempdir() do scratch
        inp_file = joinpath(scratch, "eT.inp")

        open(inp_file, "w") do io
            print(io, inp)
        end

        run(`$eT_launch $inp_file`)

        OutputFile(scratch)
    end
end
