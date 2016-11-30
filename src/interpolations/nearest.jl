export NearestInterpolation

abstract NearestInterpolation <: AbstractInterpolation{1}

function generate_interpolation(interp::Type{NearestInterpolation}, var::Symbol)
	setups = Expr(:block)
	coeffs = (:(1),)
	indices = (:(round(Int, $var)),)

	return setups, coeffs, indices
end
