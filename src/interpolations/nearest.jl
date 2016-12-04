import Base.getindex

export NearestInterpolation,
	getindex,
	getindex_symbolic

abstract NearestInterpolation <: AbstractInterpolation{1}

@inline function getindex{T<:Real}(interp::Type{NearestInterpolation}, x::T)
	return ((one(T), round(Int, x)),)
end

function getindex_symbolic(interp::Type{NearestInterpolation}, x::Union{Symbol, Expr})
	@gensym a b
	return :(), ((:(1), :(round(Int, $x))),)
end
