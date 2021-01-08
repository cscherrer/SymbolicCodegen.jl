module SymbolicCodegen

using SymbolicUtils
using SymbolicUtils: Sym, Term, Symbolic
using DataStructures
const RW = SymbolicUtils.Rewriters
const MaybeSym{T} = Union{T, Symbolic{T}}

RULES = [
    @acrule (~a + ~b)*(~c) => (~a) * (~c) + (~b) * (~c)
]

export rewrite

function rewrite(s)
    simplify(s; polynorm=true) |> RW.Fixpoint(RW.Prewalk(RW.Chain(RULES))) |> simplify
end
