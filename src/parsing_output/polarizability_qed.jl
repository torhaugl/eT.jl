const polarizability_qed_regex::Regex =
    r"<< mu_[xyz] \(b \+ b\^\+\), mu_[xyz] \(b \+ b\^\+\) >>\(-?\d+.\d+[eE][-+]?\d+\): +(-?\d+.\d+)"
export get_qed_polarizability

function get_qed_polarizability(out::OutputFile)
    polarizability_vector = -parse.(Float64, [x.captures[1] for x in eachmatch(polarizability_qed_regex, out.contents["eT"])])
    @show polarizability_vector

    # TODO Following line does not always work,
    # for instance when n_frequencies = 3 and n_polarization = 3
    # Can fix this by matching operators and frequencies in regex
    #if length(polarizability_vector) % 9 == 0
        #return polarizability_vector
    #end

    n = 0
    n_freq = length(polarizability_vector) ÷ 6
    polarizability_matrix = zeros(Float64, (3,3,n_freq))
    for freq = 1:n_freq, i = 1:3, j=1:i
        n += 1
        polarizability_matrix[i,j,freq] = polarizability_matrix[j,i,freq] = polarizability_vector[n]
    end

    return polarizability_matrix
end
