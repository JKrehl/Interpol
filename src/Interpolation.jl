export
	AbstractInterpolation,
	InterpolationContainer

import Base: ndims, getindex

abstract AbstractInterpolation{N}
ndims{N}(::AbstractInterpolation{N}) = N
ndims{T<:AbstractInterpolation}(::Type{T}) = ndims(T())

immutable InterpolationContainer{N, INS<:Tuple{Vararg{AbstractInterpolation}}} <: AbstractInterpolation{N}
end
InterpolationContainer{INS}(::INS) = InterpolationContainer{sum(map(ndims, INS.parameters)), INS}()

function generate_interpolation(interp::AbstractInterpolation, x::Symbol)
	return generate_base_interpolation(typeof(interp), symbol(x, "_1"))
end

function generate_interpolation{N, IN}(interps::InterpolationContainer{N, IN}, x::Symbol)
	assert(N == ndims(interps))
	setup_bases = Expr[]
	coeffs_bases = Tuple[]
	indices_bases = Tuple[]

	vars = Symbol[]
	i = 1

	for interp in IN.parameters
		ni = ndims(interp)

		if ni == 1
			ivar = symbol(x, "_", i)
		else
			ivar = tuple([symbol(x, "_", j) for j in i:i+ni-1])
		end
		i += ni
		push!(vars, ivar)

		bs, bc, bi = generate_base_interpolation(interp, ivar)
		push!(setup_bases, bs)
		push!(coeffs_bases, bc)
		push!(indices_bases, bi)
	end

	setup = Expr(:block, setup_bases...)

	coeffs = eval(Expr(:comprehension, :(Expr(:call, :*, $(vars...))), [Expr(:(=), var, bc) for (var, bc) in zip(vars, coeffs_bases)]...))[:]
	indices = eval(Expr(:comprehension, Expr(:tuple, vars...), [Expr(:(=), var, bc) for (var, bc) in zip(vars, indices_bases)]...))[:]

	return setup, coeffs, indices
end

generate_interpolation{T<:AbstractInterpolation}(::Type{T}, x) = generate_interpolation(T(), x)

@generated function getindex{AI<:AbstractInterpolation}(interp::AI, x::Real...)
	N = ndims(interp)
	setup, coeffs, indices = generate_interpolation(interp, :x)

	quote
		$(Expr(:meta, :inline))
		$(Expr(:block, [Expr(:(=), symbol("x_", i), Expr(:ref, :x, i)) for i in 1:N]...))
		$(setup)

		return $(Expr(:vect, coeffs...)), $(Expr(:vcat, [Expr(:row, indi...) for indi in indices]...))
	end
end
