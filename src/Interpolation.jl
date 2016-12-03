import Base.ndims, Base.*, Base.==, Base.convert, Base.getindex

export
	AbstractInterpolation,
	CompoundInterpolation,
	InterpolationSupport,
	inplaceadd


abstract AbstractInterpolation{N}
AbstractInterpolation(N=1) = AbstractInterpolation{N}
ndims{N}(::Type{AbstractInterpolation{N}}) = N
ndims{I<:AbstractInterpolation}(::Type{I}) = ndims(I.super)

abstract CompoundInterpolation{N, INS<:Tuple{Vararg{AbstractInterpolation}}} <: AbstractInterpolation{N}
CompoundInterpolation{INS<:Tuple{Vararg{AbstractInterpolation}}}(::Type{INS}) = CompoundInterpolation{sum(map(ndims, INS.parameters)), INS}
CompoundInterpolation(ins...) = CompoundInterpolation(Tuple{ins...})
ndims{INC<:CompoundInterpolation}(::Type{INC}) = INC.parameters[1]

immutable InterpolationSupport{N, CT, IT}
	coeff::CT
	indices::NTuple{N, IT}
end

InterpolationSupport(coeff, indices) = InterpolationSupport(coeff, promote(indices...))
convert{N, CT, IT}(::Type{InterpolationSupport}, t::Tuple{CT, NTuple{N, IT}}) = InterpolationSupport{N, CT, IT}(t[1], t[2])
convert{N, CT, IT}(::Type{InterpolationSupport{N, CT, IT}}, t::Tuple{CT, NTuple{N, IT}}) = InterpolationSupport{N, CT, IT}(t[1], t[2])

import Base.getindex
getindex{N, CT, IT}(::Type{InterpolationSupport}, x::Vararg{Tuple{CT, Vararg{IT, N}}}) = map(InterpolationSupport, [x...])
ndims{N}(::InterpolationSupport{N}) = N

*(a::InterpolationSupport, b::InterpolationSupport) = InterpolationSupport(a.coeff*b.coeff, (a.indices..., b.indices...))
*(a, b::InterpolationSupport) = InterpolationSupport(a*b.coeff, b.indices)
*(a::InterpolationSupport, b) = b*a
==(a::InterpolationSupport, b::InterpolationSupport) = a.coeff==b.coeff && a.indices==b.indices

using Base.Cartesian
@generated function getindex{N, INS}(interps::Type{CompoundInterpolation{N, INS}}, x::Vararg{TypeVar(:T), N})
	bsym = [Symbol("b_", i) for i in 1:N]
	ibsym = [Symbol("ib_", i) for i in 1:N]
	
	bsymdefs = Expr(:block, [Expr(:(=), bsym[i], :(getindex($(INS.parameters[i]), x[$i]))) for i in 1:N]...)
	
	flesh = :($(Expr(:call, :*, ibsym...)))	
	flesh = Expr(:generator, flesh, [Expr(:(=), ibsym[i], bsym[i]) for i in 1:N]...)
	
	quote
		$bsymdefs
		return vec($(Expr(:comprehension, flesh)))
	end
end

Base.@propagate_inbounds @generated function getindex{AT, N, INS}(aa::AbstractArray{AT,N}, interps::Type{CompoundInterpolation{N, INS}}, x::Vararg{TypeVar(:T), N})
	bsym = [Symbol("b_", i) for i in 1:N]
	ibsym = [Symbol("ib_", i) for i in 1:N]
	cbsym = [Symbol("cb_", i) for i in 1:N]
	
	bsymdefs = Expr(:block, [Expr(:(=), bsym[i], :(getindex($(INS.parameters[i]), x[$i]))) for i in 1:N]...)
	
	flesh = :(re += $(cbsym[1]).coeff * aa[$(cbsym[1]).indices...])
	for i in 1:N
		flesh = :(for $(ibsym[i]) in $(bsym[i])
			$(i!=N ? :($(cbsym[i]) =  $(ibsym[i])*$(cbsym[i+1])) : :($(cbsym[i]) = $(ibsym[i])))
			$flesh
		end)
	end
	
	quote
		re = zero($(promote_type(AT, x...)))
		$bsymdefs
		$flesh
		return re
	end
end

Base.@propagate_inbounds @generated function getindex{AT, N, IN<:AbstractInterpolation{1}}(aa::AbstractArray{AT,N}, interps::Type{IN}, x::Vararg{TypeVar(:T), N})
	bsym = [Symbol("b_", i) for i in 1:N]
	ibsym = [Symbol("ib_", i) for i in 1:N]
	cbsym = [Symbol("cb_", i) for i in 1:N]
	
	bsymdefs = Expr(:block, [Expr(:(=), bsym[i], :(getindex($(IN), x[$i]))) for i in 1:N]...)
	
	flesh = :(re += $(cbsym[1]).coeff * aa[$(cbsym[1]).indices...])
	for i in 1:N
		flesh = :(for $(ibsym[i]) in $(bsym[i])
			$(i!=N ? :($(cbsym[i]) =  $(ibsym[i])*$(cbsym[i+1])) : :($(cbsym[i]) = $(ibsym[i])))
			$flesh
		end)
	end
	
	quote
		re = zero($(promote_type(AT, x...)))
		$bsymdefs
		$flesh
		return re
	end
end

Base.@propagate_inbounds @generated function inplaceadd{AT, N, INS, VT}(aa::AbstractArray{AT,N}, interps::Type{CompoundInterpolation{N, INS}},  v::VT, x::Vararg{TypeVar(:T), N})
	bsym = [Symbol("b_", i) for i in 1:N]
	ibsym = [Symbol("ib_", i) for i in 1:N]
	cbsym = [Symbol("cb_", i) for i in 1:N]
	
	bsymdefs = Expr(:block, [Expr(:(=), bsym[i], :(getindex($(INS.parameters[i]), x[$i]))) for i in 1:N]...)
	
	flesh = :(aa[$(cbsym[1]).indices...] += $(cbsym[1]).coeff * v)
	for i in 1:N
		flesh = :(for $(ibsym[i]) in $(bsym[i])
			$(i!=N ? :($(cbsym[i]) =  $(ibsym[i])*$(cbsym[i+1])) : :($(cbsym[i]) = $(ibsym[i])))
			$flesh
		end)
	end
	
	quote
		$bsymdefs
		$flesh
	end
end

Base.@propagate_inbounds @generated function inplaceadd{AT, N, IN<:AbstractInterpolation{1}, VT}(aa::AbstractArray{AT,N}, interp::Type{IN},  v::VT, x::Vararg{TypeVar(:T), N})
	bsym = [Symbol("b_", i) for i in 1:N]
	ibsym = [Symbol("ib_", i) for i in 1:N]
	cbsym = [Symbol("cb_", i) for i in 1:N]
	
	bsymdefs = Expr(:block, [Expr(:(=), bsym[i], :(getindex($(IN), x[$i]))) for i in 1:N]...)
	
	flesh = :(aa[$(cbsym[1]).indices...] += $(cbsym[1]).coeff * v)
	for i in 1:N
		flesh = :(for $(ibsym[i]) in $(bsym[i])
			$(i!=N ? :($(cbsym[i]) =  $(ibsym[i])*$(cbsym[i+1])) : :($(cbsym[i]) = $(ibsym[i])))
			$flesh
		end)
	end
	
	quote
		$bsymdefs
		$flesh
	end
end
