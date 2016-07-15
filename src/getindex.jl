using Base.Cartesian

# to change to vararg{Int, N} when .5 becomes available
@generated function getindex{T, N, BCA, IN}(iarr::InterpArray{T, N, BCA, IN}, x::Real...)
	quote
		$(Expr(:meta, :inline))
		@nexprs $N j -> i_j = floor(Int64, x[j])
		@nexprs $N j -> r_j = $T(x[j] - i_j)

		@inbounds res = $(pointinterpolation(IN, N, :(iarr.bcarr)))
		return res
	end
end
