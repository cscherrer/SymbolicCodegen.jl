# Convert a type into the SymbolicUtils type we'll use to represent it
# for example,
#     julia> SymbolicCodegen.sym(Int)
#     :(SymbolicCodegen.Sym{Int64})
#     
#     julia> SymbolicCodegen.sym(Int, :n)
#     :(SymbolicCodegen.Sym{Int64}(:n))
#
sym(T::Type) = :(SymbolicCodegen.Sym{$T})

sym(T::Type, s::Symbol) = :($(sym(T))($(QuoteNode(s))))



function atoms(t::Term)
    if hasproperty(t.f, :name) && t.f.name == :Sum
        return setdiff(atoms(t.arguments[1]), [t.arguments[2]])
    else
        return union(atoms(t.f), union(atoms.(t.arguments)...))
    end
end 
atoms(s::Sym) = Set{Sym}([s])

atoms(x) = Set{Sym}()
