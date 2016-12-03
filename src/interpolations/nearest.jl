import Base.getindex

export NearestInterpolation

abstract NearestInterpolation <: AbstractInterpolation{1}

function getindex{T<:Real}(interp::Type{NearestInterpolation}, x::T)
	return InterpolationSupport{1,T,Int}[(one(T), (round(Int, x),))]
end
