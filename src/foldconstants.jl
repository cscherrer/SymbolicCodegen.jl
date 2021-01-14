"""
    foldconstants(s, dict)

Substitute into a symbolic expression `s` using dictionary `dict`

```
julia> s = x + y*z
x + y*z

julia> foldconstants(s, Dict(:z => 3))
x + 3y
```
"""
function foldconstants(s, dict)
    known = Set(keys(dict))

    p(x) = (symtype(x) <: Number) && (getproperty.(atoms(x), :name) ⊆ known)

    r = @rule ~x::p => toconst(~x, dict)

    RW.Prewalk(RW.PassThrough(r))(s) |> simplify
end

toconst(s::Number, dict) = s

toconst(s::Sym, dict) = dict[s.name]

function toconst(s::Term, dict)
    f = operation(s)
    args = (toconst(arg, dict) for arg in arguments(s))
    f(args...)
end

function toconst(s::Symbolic, dict)
    # First, here's the main body of the code
    f_expr = @q begin $(codegen(s)) end

    @gensym dictname

    # Now prepend the variable assignments we'll need
    for v in atoms(s)
        v = v.name
        vname = QuoteNode(v)
        pushfirst!(f_expr.args, :($v = $dictname[$vname]))
    end

    # Make it a function
    f_expr = @q begin function f($dictname) $f_expr end end
        
    # Tidy up the blocks
    f_expr = MacroTools.flatten(f_expr)
        
    # ...and generate!
    f = @RuntimeGeneratedFunction f_expr
    
    f(dict)
end
