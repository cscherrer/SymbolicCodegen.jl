codegen(s::T) where T <: Number = s

codegen(s::Symbol) = s
codegen(ex::Expr) = ex

function codegen(s::Term{T}) where {T}
    args = codegen.(s.arguments)
    codegen(T, s.f, args...)
end

function codegen(s::Sym{T}) where {T}
    s.name
end

function codegen(::Type{T}, f::Function, args...) where {T}
    fsym = gensym(f.name)
    argsyms = gensym.(Symbol.(:arg_, 1:length(args)))
    ex = @q begin end

    for (arg, argsym) in zip(args, argsyms)
        t = codegen(arg)
        push!(ex.args, :($argsym = $t))
    end
        
    push!(ex.args, :($fsym = $f($(argsyms...))
        
    ex
end


function codegen(::Type{T},::typeof(*), args...) where {T <: Number}
    @gensym mul
    ex = @q begin
        $mul = 1.0
    end
    for arg in args
        t = codegen(arg)
        push!(ex.args, :($mul *= $t))
    end
    push!(ex.args, mul)
    return ex
end

function codegen(::Type{T},::typeof(+), args...) where {T <: Number}
    @gensym add
    ex = @q begin
        $add = 0.0
    end
    for arg in args
        t = codegen(arg)
        push!(ex.args, :($add += $t))
    end
    push!(ex.args, add)
    return ex
end
