function read_f64(fname)
    x = open(fname, "r") do f
        x = Vector{Float64}(undef, stat(f).size ÷ sizeof(Float64))
        read!(f, x)
    end
    return x
end

function read_cholesky(scratch)
    ofname = scratch * "/eT.out"
    no=0; nv=0; nmo=0; nJ=0;
    for line in readlines(ofname)
        m = match(r"Number of occupied orbitals:\ *(\d+)", line)
        if !isnothing(m); no = parse(Int, m.captures[1]); end
        m = match(r"Number of virtual orbitals:\ *(\d+)", line)
        if !isnothing(m); nv = parse(Int, m.captures[1]); end
        m = match(r"Number of molecular orbitals:\ *(\d+)", line)
        if !isnothing(m); nmo = parse(Int, m.captures[1]); end
        m = match(r"Final number of Cholesky vectors:\ *(\d+)", line)
        if !isnothing(m); nJ = parse(Int, m.captures[1]); end
    end

    UJoo = reshape(read_f64(joinpath(scratch, "cholesky_MO_block_0001")), nJ, no, no)
    UJov = reshape(read_f64(joinpath(scratch, "cholesky_MO_block_0002")), nJ, no, nv)
    UJvo = reshape(read_f64(joinpath(scratch, "cholesky_MO_block_0003")), nJ, nv, no)
    UJvv = reshape(read_f64(joinpath(scratch, "cholesky_MO_block_0004")), nJ, nv, nv)

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
