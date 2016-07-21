export LinearInterpolation

immutable LinearInterpolation <: AbstractInterpolation{1}
end

function generate_base_interpolation(interp::Type{LinearInterpolation}, x::Symbol)
	ix = symbol("i_", x)
	rx = symbol("r_", x)
	ax = symbol("a_", x)

	setup = Expr(:block, :($ix = floor(Int64, $x)), :($rx = $x - $ix), :($ax = 1 - $rx))
	coeffs = (ax, rx)
	indices = (ix, :($ix+1))

	return setup, coeffs, indices
end
generate_base_interpolation(interp::Type{LinearInterpolation}, x::Tuple{Symbol}) = generate_base_interpolation(interp, x[1])
