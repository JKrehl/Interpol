export
	InterpContainer,
	InterpArray,
	getindex_coeff

import Base: size, getindex, linearindexing

abstract AbstractInterpolation

immutable InterpContainer{T<:Tuple{Vararg{AbstractInterpolation}}}
end
InterpContainer{T}(::T) = InterpContainer{T}()
InterpContainer(va::AbstractBoundaryCondition...) = InterpContainer{typeof(va)}()

immutable  InterpArray{T, N, BCA<:BCArray, INC<:InterpContainer} <: AbstractArray{T,N}
	bcarr::BCA
	interp::INC
end

InterpArray{BCA, INC<:InterpContainer}(bcarr::BCA, interp::INC) = InterpArray{eltype(BCA), ndims(BCA), BCA, INC}(bcarr, interp)
InterpArray(bcarr::BCArray, intp::AbstractInterpolation) = InterpArray(bcarr, InterpContainer(ntuple(i->intp, ndims(bcarr))))

size(iarr::InterpArray) = size(iarr.bcarr)
size(iarr::InterpArray, i::Integer) = size(iarr.bcarr, i)
linearindexing(bcarr::InterpArray) = Base.LinearSlow()

@generated function getindex{T, N, BCA, INC}(iarr::InterpArray{T, N, BCA, INC}, x::Number...)
	interpols = INC.parameters[1].parameters

	setup, coeffs, indices = Expr(:block), [], []
	for (i,intp) in enumerate(interpols)
		setup, coeffs, indices = generate_base_interpolation(iarr, i, intp, :x, setup, coeffs, indices)
	end

	quote
		$(Expr(:meta, :inline))
		bcarr = iarr.bcarr
		$(setup)
		return $(Expr(:call, :+, [:($co*$(Expr(:ref, :(bcarr), id...))) for (co, id) in zip(coeffs, indices)]...))
	end
end

@generated function getindex_coeff{T, N, BCA, INC}(iarr::InterpArray{T, N, BCA, INC}, x::Number...)
	interpols = INC.parameters[1].parameters

	setup, coeffs, indices = Expr(:block), [], []
	for (i,intp) in enumerate(interpols)
		setup, coeffs, indices = generate_base_interpolation(iarr, i, intp, :x, setup, coeffs, indices)
	end

	quote
		$(Expr(:meta, :inline))
		$(setup)
		return $(Expr(:typed_vcat, T, coeffs...)), $(Expr(:typed_vcat, Int64, [Expr(:row, indi...) for indi in indices]...))
	end
end
