using MLStyle

function foldast(leaf, branch; kwargs...)
    function go(ast)
        MLStyle.@match ast begin
            Expr(head, args...) => branch(head, map(go, args); kwargs...)
            x                   => leaf(x; kwargs...)
        end
    end

    return go
end


function matchcall(expr)
    @match expr begin
        Expr(:call, f, Expr(:parameters, kwargs...), args...) => (f, args, kwargs)
        Expr(:call, f, args...) => (f,args, [])
        _ => @error "matchcall called on $expr, not a function call"
    end
end

function callify(expr; call=:call)
    leaf(x) = x
    branch(head, newargs) = begin
        expr = Expr(head, newargs...)

        # If it's not a function call, just return it as-is
        head == :call || return expr
            
        (f, args, kwargs) = matchcall(expr)

        isempty(kwargs) && return Expr(:call, call, f, args...)

        return Expr(:call, call, Expr(:parameters, kwargs...), f, args...)
    end

    foldast(leaf, branch)(expr)
end


# julia> callify(:(f(g(x,y))))
# :(call(f, call(g, x, y)))

# julia> callify(:(f(x; a=3)))
# :(call(f, x; a = 3))

# julia> callify(:(a+b))
# :(call(+, a, b))

# julia> callify(:(call(f,3)))
# :(call(f, 3))

function call(f, args...; kwargs...)
    hasmethod(f, typeof.(args), keys(kwargs)) && return f(args...; kwargs...)

    # else build a term
end
