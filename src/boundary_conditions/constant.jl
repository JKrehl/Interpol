export ConstantBoundary

abstract ConstantBoundary{V} <: AbstractBoundary
ConstantBoundary(V) = ConstantBoundary{V}

import Base.getindex

@generated function getindex{AT, N, CB<:ConstantBoundary, IT<:Number, IM<:Tuple}(arr::AbstractArray{AT, N}, ::Type{IM}, ::Type{CB}, x::Vararg{IT, N})
	if typeof(CB.parameters[1])==TypeVar
		v = zero(AT)
	else
		v = AT(CB.parameters[1])
	end

	quote
		$(Expr(:meta, :inline))

		@boundscheck if !checkbounds(Bool, arr, x...); return $v; end
		@inbounds return arr[$(IM.parameters...), x...]
	end
end

@inline getindex{AT, N, CB<:ConstantBoundary, IT<:Number}(arr::AbstractArray{AT, N}, ::Type{CB}, x::Vararg{IT, N}) = getindex(arr, Tuple{}, CB, x...)

@generated function inplaceadd!{AT, N, CB<:ConstantBoundary, VT, IT<:Number, IM<:Tuple}(arr::AbstractArray{AT, N}, ::Type{IM}, ::Type{CB}, v::VT, x::Vararg{IT, N})
	quote
		$(Expr(:meta, :inline))

		@boundscheck if !checkbounds(Bool, arr, x...); return end
		@inbounds inplaceadd!(arr, $(IM.parameters...), v, x...)
	end
end

@inline inplaceadd!{AT, N, CB<:ConstantBoundary, VT, IT<:Number}(arr::AbstractArray{AT, N}, ::Type{CB}, v::VT, x::Vararg{IT, N}) = inplaceadd!(arr, Tuple{}, CB, v, x...)
