using SymbolicUtils: similarterm
using DataStructures: OrderedDict
export cse

# export notatomic

# notatomic(::Symbolic) = true
# notatomic(::Sym) = false
# notatomic(x) = false

function cse(s::Symbolic)
    vars = atoms(s)
    dict = OrderedDict()
    csestep(s, vars, dict)
    # r = @rule ~x => csestep(~x, vars, dict) 
    # final = RW.Postwalk(RW.PassThrough(r))(s)
    [[var=>ex for (ex, var) in pairs(dict)]...]
end

export csestep

csestep(s::Sym, vars, dict) = s

csestep(s, vars, dict) = s

function csestep(s::Symbolic, vars, dict)
    # Avoid breaking local variables out of their scope
    isempty(setdiff(atoms(s), vars)) || return x

    f = operation(s)
    args = [csestep(arg, vars, dict) for arg in arguments(s)]

    t = similarterm(s, f, args)

    if !haskey(dict, t) 
        dict[t] = Sym{symtype(t)}(gensym())
    end
    
    return dict[t]
end

# Base.:*(a::Int64, b::Symbol) = @show a,b
