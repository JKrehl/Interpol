export ConstantBoundary

type ConstantBoundary{V} <: AbstractBoundaryCondition
end
ConstantBoundary(V) = ConstantBoundary{V}()
ConstantBoundary() = ConstantBoundary{0.}()

function generate_boundarycondition{T, N, A, V}(bcarr::Type{BCArray{T, N, A, ConstantBoundary{V}}})
	quote
		arr = bcarr.arr
		$(Expr(:block, [:($(symbol("x_", i)) = x[$i]) for i in 1:N]...))

		if !$(reduce((i,j) -> Expr(:||, i, j), vcat([[:(1 > $(symbol("x_", i))), :($(symbol("x_", i)) > size(arr, $i))] for i in 1:N]...)))
			#return getindex(arr, x...)
			res = $(Expr(:call, :getindex, :arr, [symbol("x_", i) for i in 1:N]...))
		else
			res = $(T(V))
		end
	end
end
