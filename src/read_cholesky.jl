function read_cholesky_file(fname)
    f = open(fname);
    y = Vector{Float64}(undef, stat(f).size ÷ sizeof(Float64));
    read!(f, y);
    close(f);
    return y
end

function read_cholesky(scratch_path)
    out_file_path = scratch_path * "/eT.out"
    no=0; nv=0; nmo=0; nJ=0;
    for line in readlines(out_file_path)
        m = match(r"Number of occupied orbitals:\ *(\d+)", line)
        if !isnothing(m); no = parse(Int, m.captures[1]); end
        m = match(r"Number of virtual orbitals:\ *(\d+)", line)
        if !isnothing(m); nv = parse(Int, m.captures[1]); end
        m = match(r"Number of molecular orbitals:\ *(\d+)", line)
        if !isnothing(m); nmo = parse(Int, m.captures[1]); end
        m = match(r"Final number of Cholesky vectors:\ *(\d+)", line)
        if !isnothing(m); nJ = parse(Int, m.captures[1]); end
    end

    UJoo = reshape(read_cholesky_file(scratch_path*"/cholesky_MO_block_0001"), nJ, no, no)
    UJov = reshape(read_cholesky_file(scratch_path*"/cholesky_MO_block_0002"), nJ, no, nv)
    UJvo = reshape(read_cholesky_file(scratch_path*"/cholesky_MO_block_0003"), nJ, nv, no)
    UJvv = reshape(read_cholesky_file(scratch_path*"/cholesky_MO_block_0004"), nJ, nv, nv)

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
