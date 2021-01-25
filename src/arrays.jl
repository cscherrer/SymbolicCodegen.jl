
_codegen(a::AbstractArray) = a

function _codegen(::Type{T}, f::Function, args::Array{Sym}) where {T}
    ts = _codegen.(args)
    @q begin
        $f($(ts...))
    end
end

Base.getindex(a::Sym{A}, inds...) where {T, A <: AbstractArray{T}} = term(getindex, a, inds...)

SymbolicUtils.promote_symtype(::typeof(getindex), ::Type{A}, ::Type{<:Integer}...) where {T, A <: AbstractArray{T}} = T
