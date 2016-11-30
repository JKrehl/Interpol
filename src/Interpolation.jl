export
	AbstractInterpolation,
	InterpolationContainer

import Base: ndims, getindex

abstract AbstractInterpolation{N}
AbstractInterpolation(N=1) = AbstractInterpolation{N}

ndims{N}(::Type{AbstractInterpolation{N}}) = N
ndims{I<:AbstractInterpolation}(::Type{I}) = ndims(I.super)

abstract InterpolationContainer{N, INS<:Tuple{Vararg{AbstractInterpolation}}} <: AbstractInterpolation{N}
InterpolationContainer{INS<:Tuple{Vararg{AbstractInterpolation}}}(::Type{INS}) = InterpolationContainer{sum(map(ndims, INS.parameters)), INS}

InterpolationContainer(ins...) = InterpolationContainer(Tuple{ins...})
ndims{INC<:InterpolationContainer}(::Type{INC}) = INC.parameters[1]

generate_interpolation{I<:AbstractInterpolation{1}}(interp::Type{I}, x::Tuple{Symbol}) = begin bs,bc,bi = generate_interpolation(interp, x[1]); return bs, bc, [(ibi,) for ibi in bi]; end

function generate_interpolation{N, INS}(interps::Type{InterpolationContainer{N, INS}}, vars::NTuple{N, Symbol})
	NS = map(ndims, INS.parameters)
	assert(N == sum(NS))
	base_setups = Expr[]
	base_coeffs = Tuple[]
	base_indices = Array[]
	
	dvars = tuple([(vars[be:be+n-1]...) for (be, n) in zip(cumsum(NS), NS)]...)
	
	for (ivar, interp) in zip(dvars, INS.parameters)
		bs, bc, bi = generate_interpolation(interp, ivar)
		push!(base_setups, bs)
		push!(base_coeffs, bc)
		push!(base_indices, bi)
	end
	
	setup = Expr(:block, base_setups...)
	coeffs = combine_coeffs(base_coeffs)
	indices = combine_indices(base_indices)
	
	return setup, coeffs, indices
end

@generated function getindex{AI<:AbstractInterpolation}(interp::Type{AI}, x::Real...)
	N = ndims(AI)
	@assert N == length(x)
	vars = ([Symbol("x_", i) for i in 1:N]...)
	setup, coeffs, indices = generate_interpolation(AI, vars)
	
	quote
		$(Expr(:meta, :inline))
		$(Expr(:block, [Expr(:(=), Symbol("x_", i), Expr(:ref, :x, i)) for i in 1:N]...))
		$(setup)

		return $(Expr(:vect, coeffs...)), $(Expr(:vect, [Expr(:vect, indi...) for indi in indices]...))
	end
end

@generated function getindex{AA<:AbstractArray ,AI<:AbstractInterpolation}(array::AA, interp::Type{AI}, x::Real...)
	@assert ndims(AI) == length(x)
	quote
		$(Expr(:meta, :inline))
		coeffs, indices = getindex(interp, x...)
		return sum(c*array[i...] for c in coeffs, i in indices)
	end
end
