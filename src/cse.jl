using DataStructures: OrderedDict
export cse

# export notatomic

# notatomic(::Symbolic) = true
# notatomic(::Sym) = false
# notatomic(x) = false

function cse(s::Symbolic)
    vars = atoms(s)
    dict = OrderedDict()
    r = @rule ~x => csestep(~x, vars, dict) 
    final = RW.Postwalk(RW.PassThrough(r))(s)
    [[var=>ex for (ex, var) in pairs(dict)]...]
end

export csestep

csestep(s::Sym, vars, dict) = s

csestep(s, vars, dict) = s

function csestep(x::S, vars, dict) where {S <: Symbolic}
    @show x
    # Avoid breaking local variables out of their scope
    isempty(setdiff(atoms(x), vars)) || return x

    if !haskey(dict, x) 
        dict[x] = Sym{symtype(x)}(gensym())
    end

    return dict[x]
end

# Base.:*(a::Int64, b::Symbol) = @show a,b
