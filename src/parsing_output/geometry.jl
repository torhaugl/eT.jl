const geometry_reg1 = r"Geometry \(angstrom\)\s+=+.+?=+.+?\n(.+?)\n +=+"s
const geometry_reg2 = r"\d+ +(\w\w? +(?:-?\d+\.\d+ +){3})\d+"

export get_geometry
function get_geometry(out::OutputFile)
    geo_string = match(geometry_reg1, out.contents["eT"]).captures[1]

    io = IOBuffer()

    for m in eachmatch(geometry_reg2, geo_string)
        println(io, m.captures[1])
    end

    Molecule(String(take!(io)))
end
