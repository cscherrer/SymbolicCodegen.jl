_codegen(s::T) where T <: Number = s

_codegen(s::Symbol) = s
_codegen(ex::Expr) = ex

function _codegen(s::Symbolic{T}) where {T}
    f = operation(s)
    args = _codegen.(arguments(s))
    _codegen(T, f, args...)
end

function _codegen(s::Sym{T}) where {T}
    s.name
end

function _codegen(::Type{T}, f::Function, args...) where {T}
    fsym = gensym(Symbol(f))
    argsyms = gensym.(Symbol.(:arg_, 1:length(args)))
    ex = @q begin end

    for (arg, argsym) in zip(args, argsyms)
        t = _codegen(arg)
        push!(ex.args, :($argsym = $t))
    end
        
    push!(ex.args, :($fsym = $f($(argsyms...))))
        
    ex
end
