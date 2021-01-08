
codegen(a::AbstractArray) = a

function codegen(::Type{T}, f::Function, args::Array{Sym}) where {T}
    ts = codegen.(args)
    @q begin
        $f($(ts...))
    end
end

Base.getindex(a::Sym{A}, inds...) where {T, A <: AbstractArray{T}} = term(getindex, a, inds...; type=T)
