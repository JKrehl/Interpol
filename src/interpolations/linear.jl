export LinearInterpolation

type LinearInterpolation <: AbstractInterpolation
end

function generate_base_interpolation{T}(iarr::Type{T}, i::Integer, interp::Type{LinearInterpolation}, x::Symbol, setup::Expr = Expr(:block), coeffs=[], indices=[])
	x_i = :($x[$i])
	i_i = symbol("i_", i)
	r_i = symbol("r_", i)
	a_i = symbol("a_", i)

	setup = Expr(setup.head, setup.args..., :($(i_i) = floor(Int, $(x_i))), :($(r_i) = $(x_i) - $(i_i)), :($(a_i) = 1-$(r_i)))
	if coeffs == []
		coeffs = [:(($(a_i))), :($(r_i))]
		indices = [(:($(i_i)),), (:($(i_i)+1),)]
	else
		coeffs = [[:(($(a_i))*$(ex)) for ex in coeffs]..., [:($(r_i)*$(ex)) for ex in coeffs]...]
		indices = [[(idx..., i_i) for idx in indices]..., [(idx..., :($(i_i)+1)) for idx in indices]...]
	end
	return setup, coeffs, indices
end
