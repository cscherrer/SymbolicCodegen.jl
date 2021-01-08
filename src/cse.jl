
function csestep(x, vars, dict)
    # Avoid breaking local variables out of their scope
    isempty(setdiff(atoms(x), vars)) || return x

    if !haskey(dict, x) 
        dict[x] = gensym()
    end

    return dict[x]
end

function cse(s <: Symbolic)
    vars = atoms(s)
    dict = OrderedDict()
    r = @rule ~x::(x -> x isa Term) => csestep(~x, vars, dict) 
    final = Postwalk(RW.Chain([r]))(s)
    [[var=>ex for (ex, var) in pairs(dict)]...] #, final]
end
