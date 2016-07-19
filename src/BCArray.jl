export
	BCArray

import Base: size, getindex, linearindexing

abstract AbstractBoundaryCondition

# immutable BCContainer{T<:Tuple{Vararg{AbstractBoundaryCondition}}}
# end
# BCContainer{T}(::T) = BCContainer{T}()
# BCContainer(va::AbstractBoundaryCondition...) = BCContainer{typeof(va)}()
#
# immutable BCArray{T, N, A<:AbstractArray, BCC<:BCContainer} <: AbstractArray{T,N}
# 	arr::A
# 	bcc::BCC
# end
#
# BCArray{A, BCC<:BCContainer}(arr::A, bcc::BCC) = BCArray{eltype(A), ndims(A), A, BCC}(arr, bcc)
# BCArray(arr::AbstractArray, bc::AbstractBoundaryCondition) = BCArray(arr, BCContainer(ntuple(i-> bc, ndims(arr))))

immutable BCArray{T, N, A<:AbstractArray, BC<:AbstractBoundaryCondition} <: AbstractArray{T,N}
	arr::A
	bc::BC
end

BCArray{A, BC<:AbstractBoundaryCondition}(arr::A, bc::BC) = BCArray{eltype(A), ndims(A), A, BC}(arr, bc)


size(bcarr::BCArray) = size(bcarr.arr)
size(bcarr::BCArray, i::Integer) = size(bcarr.arr, i)
linearindexing(bcarr::BCArray) = Base.LinearSlow()

@generated function getindex{T, N, A, BC}(bcarr::BCArray{T, N, A, BC}, x::Integer...)
	quote
		$(Expr(:meta, :inline))
		@inbounds $(generate_boundarycondition(bcarr))
		return res
	end
end
