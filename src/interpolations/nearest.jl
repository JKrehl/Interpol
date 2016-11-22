export NearestInterpolation

abstract NearestInterpolation <: AbstractInterpolation{1}
NearestInterpolation() = NearestInterpolation

function generate_base_interpolation(interp::Type{NearestInterpolation}, x::Symbol)
	setup = :()
	coeffs = (:(1))
	indices = (:(round($x)))

	return setup, coeffs, indices
end
generate_base_interpolation(interp::Type{NearestInterpolation}, x::Tuple{Symbol}) = generate_base_interpolation(interp, x[1])
