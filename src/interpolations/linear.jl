import Base.getindex

export LinearInterpolation

abstract LinearInterpolation <: AbstractInterpolation{1}

function getindex{T<:Real}(interp::Type{LinearInterpolation}, x::T)
	ix = floor(Int, x)
	rx = x-ix
	return InterpolationSupport{1,T,Int}[(1-rx, (ix,)), (rx, (ix+1,))]
end
