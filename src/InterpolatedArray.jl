export InterpolatedArray

import Base: size, linearindexing, getindex

immutable InterpolatedArray{T, N, A<:AbstractArray, IN<:AbstractInterpolation} <: AbstractArray{T,N}
	arr::A
	interp::IN
end
InterpolatedArray{A<:AbstractArray, IN<:AbstractInterpolation}(arr::A, interp::IN) = ndims(A)==ndims(I) ? InterpolatedArray{eltype(A), ndims(A), A, IN}(arr, interp) : throw(AssertionError("interpolation and array need to have the same number of dimensions"))

@inline size(iarr::InterpolatedArray) = size(iarr.arr)
@inline size(iarr::InterpolatedArray, i::Integer) = size(iarr.arr, i)
@inline linearindexing(::InterpolatedArray) = Base.LinearSlow()

@generated function getindex{T, N, A, IN}(iarr::InterpolatedArray{T, N, A, IN}, x::Real...)
	setup, coeffs, indices = generate_interpolation(IN, :x)
	quote
		$(Expr(:meta, :inline))
		$(Expr(:boundscheck, :false))
		$(Expr(:block, Expr(:(=), :arr, :(iarr.arr)), [Expr(:(=), symbol("x_", i), Expr(:ref, :x, i)) for i in 1:N]...))
		$(setup)
		re= $(Expr(:call, :+, [:($co*$(Expr(:ref, :(arr), id...))) for (co, id) in zip(coeffs, indices)]...))
		$(Expr(:boundscheck, :pop))
		return re
	end
end
