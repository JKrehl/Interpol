export LinearInterpolation

abstract LinearInterpolation <: AbstractInterpolation{1}

function generate_interpolation(interp::Type{LinearInterpolation}, var::Symbol)
	ivar = Symbol("i_", var)
	rvar = Symbol("r_", var)
	
	setups = Expr(:block, :($ivar = floor(Int64, $var)), :($rvar = $var-$ivar))
	coeffs = (:(1-$rvar), :($rvar))
	indices = (ivar, :($ivar+1))

	return setups, coeffs, indices
end
