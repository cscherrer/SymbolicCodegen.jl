module SymbolicCodegen

using SymbolicUtils
using SymbolicUtils: Sym, Term, Symbolic, operation, arguments, symtype
const RW = SymbolicUtils.Rewriters
const MaybeSym{T} = Union{T, Symbolic{T}}
using MacroTools
using MacroTools: @q

include("utils.jl")
include("base.jl")
include("sums.jl")
include("arrays.jl")
include("cse.jl")

export codegen

function codegen(s::Symbolic{T}) where {T}
    assignments = cse(s)

    q = @q begin end

    for a in assignments
        x = a[1]
        rhs = _codegen(a[2])
        push!(q.args, @q begin $x = $rhs end)
    end

    MacroTools.flatten(q)
end


# RULES = [
#     @acrule (~a + ~b)*(~c) => (~a) * (~c) + (~b) * (~c)
# ]

# export rewrite

# function rewrite(s)
#     simplify(s; polynorm=true) |> RW.Fixpoint(RW.Prewalk(RW.Chain(RULES))) |> simplify
# end

end
