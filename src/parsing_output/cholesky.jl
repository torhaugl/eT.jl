export read_cholesky

function read_cholesky(out :: OutputFile)
    nmo = parse(Int, match(r"Number of molecular orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    no = parse(Int, match(r"Number of occupied orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    nv = parse(Int, match(r"Number of virtual orbitals:\ *(\d+)", out.contents["eT"]).captures[1])
    nJ = parse(Int, match(r"Final number of Cholesky vectors:\ *(\d+)", out.contents["eT"]).captures[1])

    UJoo = reshape(out.binaries["cholesky_MO_block_0001"], nJ, no, no)
    UJov = reshape(out.binaries["cholesky_MO_block_0002"], nJ, no, nv)
    UJvo = reshape(out.binaries["cholesky_MO_block_0003"], nJ, nv, no)
    UJvv = reshape(out.binaries["cholesky_MO_block_0004"], nJ, nv, nv)

    LpqJ = zeros(nmo, nmo, nJ)
    for J = 1:nJ, p = 1:nmo, q = 1:nmo
        if p <= no
            if q <= no
                LpqJ[p,q,J] = UJoo[J,p,q]
            else
                LpqJ[p,q,J] = UJov[J,p,q-no]
            end
        else
            if q <= no
                LpqJ[p,q,J] = UJvo[J,p-no,q]
            else
                LpqJ[p,q,J] = UJvv[J,p-no,q-no]
            end
        end
    end
    return reshape(LpqJ, nmo^2, nJ), (nmo=nmo, no=no, nv=nv, nJ=nJ)
end
