export write_molden
function write_molden(io::IO, out::OutputFile)
    write(io, out.contents["eT.molden"])
end

# TODO: parse mo_information file
