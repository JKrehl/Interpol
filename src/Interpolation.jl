import Base.ndims, Base.*, Base.==, Base.convert, Base.getindex

export
	AbstractInterpolation,
	CompoundInterpolation,
	InterpolationSupport


abstract AbstractInterpolation{N}
AbstractInterpolation(N=1) = AbstractInterpolation{N}
ndims{N}(::Type{AbstractInterpolation{N}}) = N
ndims{I<:AbstractInterpolation}(::Type{I}) = ndims(I.super)

abstract CompoundInterpolation{N, INS<:Tuple{Vararg{AbstractInterpolation}}} <: AbstractInterpolation{N}
CompoundInterpolation{INS<:Tuple{Vararg{AbstractInterpolation}}}(::Type{INS}) = CompoundInterpolation{sum(map(ndims, INS.parameters)), INS}
CompoundInterpolation(ins...) = CompoundInterpolation(Tuple{ins...})
ndims{INC<:CompoundInterpolation}(::Type{INC}) = INC.parameters[1]

using Base.Cartesian
@generated function getindex{N, INS}(interps::Type{CompoundInterpolation{N, INS}}, x::Vararg{TypeVar(:T), N})
	bsym = [Symbol("b_", i) for i in 1:N]
	ibsym = [Symbol("ib_", i) for i in 1:N]

	bsymdefs = Expr(:block, [Expr(:(=), bsym[i], :(getindex($(INS.parameters[i]), x[$i]))) for i in 1:N]...)

	flesh = Expr(:tuple, Expr(:call, :*, [:($i[0]) for i in ibsym]...), [:($i[1]) for i in ibsym]...)
	flesh = Expr(:generator, flesh, [Expr(:(=), ibsym[i], bsym[i]) for i in 1:N]...)

	quote
		$bsymdefs
		return vec($(Expr(:comprehension, flesh)))
	end
end

@generated function getindex{AT, N, INS, IT}(arr::AbstractArray{AT,N}, interps::Type{CompoundInterpolation{N, INS}}, x::Vararg{IT, N})
	symbolic = [getindex_symbolic(INS.parameters[i], :(x[$i])) for i in 1:N]

	ibsym = [[Symbol("ib_", i, "_", j) for j in 1:length(symbolic[i][2])] for i in 1:N]
	cbsym = [[Symbol("cb_", i, "_", j) for j in 1:length(symbolic[i][2])] for i in 1:N]

	setups = Expr(:block, [symbolic[i][1] for i in 1:N]...)
	bsymdefs = Expr(:block, [Expr(:block, [Expr(:block, Expr(:(=), cbsym[i][j], symbolic[i][2][j][1]), Expr(:(=), ibsym[i][j], symbolic[i][2][j][2])) for j in 1:length(symbolic[i][2])]...) for i in 1:N]...)

	indices_prod = Base.product(ibsym...)
	indices = map(a -> Expr(:ref, :arr, IM.parameters..., a...), indices_prod)

	for i in 1:N
		indices = mapslices(a->Expr(:call, :+, [Expr(:call, :*, ic, ia) for (ic,ia) in zip(cbsym[i], a)]...), indices, i)
	end

	quote
		$(Expr(:meta, :inline))
		$setups
		$bsymdefs
		return $(indices[1])
	end
end

@inline getindex{AT, N, IT<:Number, IN<:SimpleInterpolation, IM<:Tuple}(arr::AbstractArray{AT, N}, ::Type{IM}, ::Type{IN}, x::Vararg{IT, N}) = getindex(arr, IM, CompoundInterpolation{N, NTuple{N, IN}}, x...)
@inline getindex{AT, N, IT<:Number, IN<:AbstractInterpolation}(arr::AbstractArray{AT,N}, ::Type{IN}, x::Vararg{IT, N}) = getindex(arr, Tuple{}, IN, x...)

@generated function inplaceadd!{AT, N, INS, VT, IT<:Number, IM<:Tuple}(arr::AbstractArray{AT,N}, ::Type{IM}, ::Type{CompoundInterpolation{N, INS}},  v::VT, x::Vararg{IT, N})
	symbolic = [getindex_symbolic(INS.parameters[i], :(x[$i])) for i in 1:N]

	ibsym = [[Symbol("ib_", i, "_", j) for j in 1:length(symbolic[i][2])] for i in 1:N]
	cbsym = [[Symbol("cb_", i, "_", j) for j in 1:length(symbolic[i][2])] for i in 1:N]

	setups = Expr(:block, [symbolic[i][1] for i in 1:N]...)
	bsymdefs = Expr(:block, [Expr(:block, [Expr(:block, Expr(:(=), cbsym[i][j], symbolic[i][2][j][1]), Expr(:(=), ibsym[i][j], symbolic[i][2][j][2])) for j in 1:length(symbolic[i][2])]...) for i in 1:N]...)


	coeff_prod = Base.product(cbsym...)
	indices_prod = Base.product(ibsym...)

	flesh = Expr(:block, map((c,i) -> Expr(:call, :inplaceadd!, :arr, IM.parameters..., Expr(:call, :*, c..., :v), i...), coeff_prod, indices_prod)...)

	quote
		$(Expr(:meta, :inline))
		$setups
		$bsymdefs
		$flesh
		return
	end
end

@inline inplaceadd!{AT, N, IN<:SimpleInterpolation, VT, IM<:Tuple}(arr::AbstractArray{AT,N}, ::Type{IM}, ::Type{IN},  v::VT, x::Vararg{TypeVar(:T), N})  = inplaceadd!(arr, IM, CompoundInterpolation{N, NTuple{N, IN}}, v, x...)
@inline inplaceadd!{AT, N, IN<:AbstractInterpolation, VT}(arr::AbstractArray{AT,N}, ::Type{IN},  v::VT, x::Vararg{TypeVar(:T), N})  = inplaceadd!(arr, Tuple{}, IN, v, x...)
