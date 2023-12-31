# This file contains only utility functions that do NOT
# depend on BioSequences

const codons = [
    "AAA", "AAC", "AAG", "AAU",
    "ACA", "ACC", "ACG", "ACU",
    "AGA", "AGC", "AGG", "AGU",
    "AUA", "AUC", "AUG", "AUU",
    "CAA", "CAC", "CAG", "CAU",
    "CCA", "CCC", "CCG", "CCU",
    "CGA", "CGC", "CGG", "CGU",
    "CUA", "CUC", "CUG", "CUU",
    "GAA", "GAC", "GAG", "GAU",
    "GCA", "GCC", "GCG", "GCU",
    "GGA", "GGC", "GGG", "GGU",
    "GUA", "GUC", "GUG", "GUU",
    "UAA", "UAC", "UAG", "UAU",
    "UCA", "UCC", "UCG", "UCU",
    "UGA", "UGC", "UGG", "UGU",
    "UUA", "UUC", "UUG", "UUU",
    # translatable ambiguities in the standard code
    "CUN", "CCN", "CGN", "ACN",
    "GUN", "GCN", "GGN", "UCN"
]

function random_translatable_rna(n)
    probs = fill(1.0 / length(codons), length(codons))
    cumprobs = cumsum(probs)
    r = rand()
    x = Vector{String}(undef, n)
    for i in 1:n
        x[i] = codons[searchsorted(cumprobs, rand()).start]
    end

    return string(x...)
end

function get_bio_fmt_specimens()
    path = joinpath(dirname(@__FILE__), "BioFmtSpecimens")
    if !isdir(path)
        run(`git clone --depth 1 https://github.com/BioJulia/BioFmtSpecimens.git $(path)`)
    end
end

# The generation of random test cases...

function random_array(n::Integer, elements, probs)
    cumprobs = cumsum(probs)
    x = Vector{eltype(elements)}(undef, n)
    for i in 1:n
        x[i] = elements[searchsorted(cumprobs, rand()).start]
    end
    return x
end

# Return a random DNA/RNA sequence of the given length.
function random_seq(n::Integer, nts, probs)
    cumprobs = cumsum(probs)
    x = Vector{Char}(undef, n)
    for i in 1:n
        x[i] = nts[searchsorted(cumprobs, rand()).start]
    end
    return String(x)
end

function random_seq(::Type{A}, n::Integer) where {A<:Alphabet}
    # TODO: Resolve the use of symbols(A()).
    nts = symbols(A())
    probs = Vector{Float64}(undef, length(nts))
    fill!(probs, 1 / length(nts))
    return LongSequence{A}(random_seq(n, nts, probs))
end

function random_dna(n, probs=[0.24, 0.24, 0.24, 0.24, 0.04])
    return random_seq(n, ['A', 'C', 'G', 'T', 'N'], probs)
end

function random_rna(n, probs=[0.24, 0.24, 0.24, 0.24, 0.04])
    return random_seq(n, ['A', 'C', 'G', 'U', 'N'], probs)
end

function random_aa(len)
    return random_seq(len,
        ['A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I',
         'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V', 'X' ],
        push!(fill(0.049, 20), 0.02))
end

function intempdir(fn::Function, parent=tempdir())
    dirname = mktempdir(parent)
    try
        cd(fn, dirname)
    finally
        rm(dirname, recursive=true)
    end
end

function random_dna_kmer(len)
    return random_dna(len, [0.25, 0.25, 0.25, 0.25])
end

function random_rna_kmer(len)
    return random_rna(len, [0.25, 0.25, 0.25, 0.25])
end

function random_dna_kmer_nucleotides(len)
    return random_array(len, [DNA_A, DNA_C, DNA_G, DNA_T],
                        [0.25, 0.25, 0.25, 0.25])
end

function random_rna_kmer_nucleotides(len)
    return random_array(len, [RNA_A, RNA_C, RNA_G, RNA_U],
                        [0.25, 0.25, 0.25, 0.25])
end

function dna_complement(seq::AbstractString)
    seqc = Vector{Char}(undef, length(seq))
    complementer = Dict(zip("-ACGTSWYRKMDVHBN", "-TGCASWRYMKHBDVN"))
    for (i, c) in enumerate(seq)
        seqc[i] = complementer[c]
    end
    return String(seqc)
end

function rna_complement(seq::AbstractString)
    seqc = Vector{Char}(undef, length(seq))
    complementer = Dict(zip("-ACGUSWYRKMDVHBN", "-UGCASWRYMKHBDVN"))
    for (i, c) in enumerate(seq)
        seqc[i] = complementer[c]
    end
    return String(seqc)
end

function random_interval(minstart, maxstop)
    start = rand(minstart:maxstop)
    return start:rand(start:maxstop)
end