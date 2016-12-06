export ConstantBoundary

abstract ConstantBoundary{V} <: AbstractBoundary
ConstantBoundary(V) = ConstantBoundary{V}

import Base.getindex

@generated function getindex{AT, N, CB<:ConstantBoundary, IT}(arr::AbstractArray{AT, N}, bc::Type{CB}, x::Vararg{IT, N})
	if typeof(CB.parameters[1])==TypeVar
		v = zero(AT)
	else
		v = AT(CB.parameters[1])
	end

	quote
		$(Expr(:meta, :inline))

		@boundscheck if !checkbounds(Bool, arr, x...); return $v; end
		@inbounds return arr[x...]
	end
end

@generated function inplaceadd!{AT, N, CB<:ConstantBoundary, VT, IT}(arr::AbstractArray{AT, N}, bc::Type{CB}, v::VT, x::Vararg{IT, N})
	quote
		$(Expr(:meta, :inline))

		@boundscheck if !checkbounds(Bool, arr, x...); return end
		@inbounds inplaceadd!(arr, v, x...)
	end
end
