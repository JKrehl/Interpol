export LinearInterpolation

abstract LinearInterpolation <: AbstractInterpolation{1}
LinearInterpolation() = LinearInterpolation
ndims(::Type{

function generate_base_interpolation(interp::Type{LinearInterpolation}, x::Symbol)
	ix = Symbol("i_", x)

	setup = :($ix = floor(Int64, $x))
	coeffs = (:($ix+1-$x), :($x-$ix))
	indices = (ix, :($ix+1))

	return setup, coeffs, indices
end
generate_base_interpolation(interp::Type{LinearInterpolation}, x::Tuple{Symbol}) = generate_base_interpolation(interp, x[1])
