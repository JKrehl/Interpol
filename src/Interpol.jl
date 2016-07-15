module Interpol

	export
		AbstractBoundaryCondition,
		AbstractInterpolation,
		BCArray,
		InterpArray

	import Base: size, getindex, linearindexing

	abstract AbstractBoundaryCondition
	abstract AbstractInterpolation

	immutable BCArray{T, N, A<:AbstractArray, BC<:AbstractBoundaryCondition} <: AbstractArray{T,N}
		arr::A
		bc::BC
	end

	size(bcarr::BCArray) = size(bcarr.arr)
	size(bcarr::BCArray, i::Integer) = size(bcarr.arr, i)
	linearindexing(bcarr::BCArray) = Base.LinearSlow()

	immutable  InterpArray{T, N, BCA<:BCArray, IN<:AbstractInterpolation} <: AbstractArray{T,N}
		bcarr::BCA
		interp::IN
	end

	InterpArray{BCA, IN}(bcarr::BCA, interp::IN) = InterpArray{eltype(bcarr), ndims(bcarr), BCA, IN}(bcarr, interp)

	size(iarr::InterpArray) = size(iarr.bcarr)
	linearindexing(bcarr::InterpArray) = Base.LinearSlow()

	include("utilities.jl")

	include("boundary_conditions/constant.jl")
	include("interpolations/linear.jl")

	include("getindex.jl")

end
