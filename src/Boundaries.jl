import Base.size, Base.ndims, Base.getindex

export AbstractBoundary,
  BoundedArray

abstract AbstractBoundary

immutable BoundedArray{T, N, A<:AbstractArray, B<:AbstractBoundary} <: AbstractArray{T,N}
	arr::A
end
@generated function BoundedArray{A<:AbstractArray, B}(arr::A, ::Type{B})
	:($(Expr(:meta, :inline)); BoundedArray{$(eltype(A)), $(ndims(A)), $A, $B}(arr))
end

@inline size(BA::BoundedArray) = size(BA.arr)
@inline ndims{N}(BA::BoundedArray{TypeVar(:T), N}) = N
@inline getindex{N, B, IT}(barr::BoundedArray{TypeVar(:T), N, TypeVar(:A), B}, x::Vararg{IT,N}) = getindex(barr.arr, B, x...)
@inline inplaceadd!{N, B, IT}(barr::BoundedArray{TypeVar(:T), N, TypeVar(:A), B}, v, x::Vararg{IT,N}) = inplaceadd!(barr.arr, B, v, x...)
