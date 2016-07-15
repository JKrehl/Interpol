export ConstantBoundary

type ConstantBoundary{T} <: AbstractBoundaryCondition
	val::T
end

ConstantBoundary() = ConstantBoundary{Float64}(0.)
BCArray{T, N, T2}(arr::AbstractArray{T,N}, CB::ConstantBoundary{T2}) = BCArray{T, N, typeof(arr), ConstantBoundary{T}}(arr, ConstantBoundary{T}(T(CB.val)))

# to change to vararg{Int, N} when .5 becomes available
@generated function getindex{T, N, A}(bcarr::BCArray{T, N, A, ConstantBoundary{T}}, x::Integer...)
	macroexpand(quote
		$(Expr(:meta, :inline))
		$(Expr(:boundscheck, false))
		if $(Expr(:||, [:((x[$i]<1) || (x[$i]>size(bcarr, $i))) for i in 1:N]...))
			return res = bcarr.bc.val
		else
			res = getindex(bcarr.arr, x...)
		end
		$(Expr(:boundscheck, :pop))
		return res
	end)
end
