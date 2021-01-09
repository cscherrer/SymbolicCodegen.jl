
@syms Sum(t::Number, i::Int, a::Int, b::Int)::Number

# get it?
function gensum(t,i,a,b)
    new_i = Sym{Int}(gensym(:i))
    new_t = substitute(t, Dict(i => new_i))
    return Sum(new_t, new_i, a, b)
end



function _codegen(::Type{T},s::SymbolicUtils.Sym{SymbolicUtils.FnType{Tuple{E,Int64,Int64,Int64},X}}, args...) where {T, E<: Number, X <: Number}
    @assert s.name == :Sum

    @gensym sum
    @gensym Δsum
    @gensym lo
    @gensym hi
        
    (summand, ix, ixlo, ixhi) = _codegen.(args)


    ex = @q begin
        $Δsum = $summand
        $sum += $Δsum
    end

    # Originally this part was in a `for` loop to allow for nested sums
    ex = @q begin
        $lo = $(ixlo)
        $hi = $(ixhi)
        @inbounds @fastmath for $(ix) in $lo:$hi
            $ex
        end
    end

    ex = @q begin
        $sum = 0.0
        $ex
        $sum
    end

    return ex
end


function tryfactor(sumfactors,i,a,b)
    d = Dict([t => i ∈ atoms(t) for t in sumfactors])
    # Which factors are independent of the index?
    indep = filter(t -> !d[t], sumfactors) 
    isempty(indep) && return nothing

    # Start by factoring out the independent factors
    result = prod(indep)

    # Which factors depend on the index?
    dep = filter(t -> d[t], sumfactors)
    # Maybe none do, so we're already done
    isempty(dep) && return result * (b - a + 1)

    # Otherwise, multiply those to the result
    result *= gensum(prod(dep), i, a, b)

    return result
end

SUMRULES = [
    @rule Sum(+(~~x), ~i, ~a, ~b) => sum([gensum(t, ~i, ~a, ~b) for t in (~~x)])
    @rule Sum(*(~~x), ~i, ~a, ~b) => tryfactor(~~x, ~i, ~a, ~b) # ifelse(!_contains(~x,~i) || !_contains(~y,~i), Sum(~x, ~i, ~a, ~b) * Sum(~y, ~i, ~a, ~b), nothing)
    @rule Sum(~x, ~i, ~a, ~b) => ifelse(~i ∈ atoms(~x), nothing, ((~b) - (~a) + 1) * (~x))
]
