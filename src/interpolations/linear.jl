import Base.getindex

export LinearInterpolation,
	getindex,
	getindex_symbolic

abstract LinearInterpolation <: SimpleInterpolation

@inline function getindex{T<:Real}(interp::Type{LinearInterpolation}, x::T)
	ix = floor(Int, x)
	rx = x-ix
	return ((1-rx, ix,), (rx, ix+1,))
end

function getindex_symbolic(interp::Type{LinearInterpolation}, x::Union{Symbol, Expr})
	@gensym a b
	return :($a = floor($x); $b = floor(Int,$x)), ((:($a+1-$x), :($b)), (:($x-$a), :($b+1)))
end
