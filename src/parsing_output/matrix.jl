function get_matrix_string(s, name)
    function make_find_matrix_reg(name)
        Regex(
            "$(replace(name, '(' => "\\(", ')' => "\\)"))\\n  =+\\n(.+?)=+",
            "s"
        )
    end

    match(make_find_matrix_reg(name), s).captures[1]
end

function parse_matrix(matstring)
    block_reg = r"(?: +\d+)+\n((?:.+\n)+)"
    index_reg = r" (\d+) "
    num_reg = r"-?\d+\.\d+"

    h = 0
    mat = Float64[]

    for m in eachmatch(block_reg, matstring)
        blockstring = m.captures[1]
        if iszero(h)
            h = parse(Int, last(collect(eachmatch(index_reg, blockstring))).captures[1])
        end

        numbers = [parse(Float64, m.match)
                   for m in eachmatch(num_reg, blockstring)]

        append!(mat, @view (reshape(numbers, length(numbers) ÷ h, h)')[:])
    end

    w = length(mat) ÷ h

    reshape(mat, h, w)
end

export get_matrix
function get_matrix(out::OutputFile, name)
    parse_matrix(get_matrix_string(out.contents["eT"], name))
end