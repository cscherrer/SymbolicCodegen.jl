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

export atoms

function atoms(t::Symbolic)
    f = operation(t)
    args = arguments(t)

    if hasproperty(f, :name) && f.name == :Sum
        return setdiff(atoms(args[1]), [args[2]])
    else
        return union(atoms(f), union(atoms.(args)...))
    end
end 

atoms(s::Sym) = Set{Sym}([s])

atoms(x) = Set{Sym}()
