using Base.Test

@testset "abstract base types" begin
	@test AbstractInterpolation() == AbstractInterpolation{1}
	@test AbstractInterpolation(3) == AbstractInterpolation{3}
	@test ndims(AbstractInterpolation{3}) == 3
	
	@test CompoundInterpolation{3, Tuple{AbstractInterpolation{3}, AbstractInterpolation{4}}} <: AbstractInterpolation{3}
	@test CompoundInterpolation(Tuple{AbstractInterpolation{2}, AbstractInterpolation{4}}) == CompoundInterpolation{6, Tuple{AbstractInterpolation{2}, AbstractInterpolation{4}}}
	@test CompoundInterpolation(AbstractInterpolation(), AbstractInterpolation{4}) == CompoundInterpolation{5, Tuple{AbstractInterpolation{1}, AbstractInterpolation{4}}}
	@test ndims(CompoundInterpolation{6, Tuple{AbstractInterpolation{2}, AbstractInterpolation{4}}}) == 6
end;

@testset "interpolation support point type" begin
	@test typeof(InterpolationSupport(one(Float32), ((one(Int8), one(Int))))) == InterpolationSupport{2, Float32, Int}
	@test ndims(InterpolationSupport(one(Float32), ((one(Int8), one(Int))))) == 2
	
	@test eltype(InterpolationSupport{1,Float64,Int64}[(1.,(1,)),(0.,(2,))]) == InterpolationSupport{1,Float64,Int64}
	@test eltype(InterpolationSupport{1,Float64,Int64}[(1.,1),(0.,2)]) == InterpolationSupport{1,Float64,Int64}
	@test eltype(InterpolationSupport[(1.,(1,)),(0.,(2,))]) == InterpolationSupport{1,Float64,Int64}
	@test eltype(InterpolationSupport[(1.,1),(0.,2)]) == InterpolationSupport{1,Float64,Int64}
	
	@test InterpolationSupport(1., (1,))*InterpolationSupport(2., (2,)) == InterpolationSupport(1.*2., (1,2))
	@test 3*InterpolationSupport(2., (2,)) == InterpolationSupport(3.*2., (2,))
	@test InterpolationSupport(1., (1,))*3 == InterpolationSupport(1.*3., (1,))
	@test typeof(InterpolationSupport[(1., (2, 1)), (2., (3, 4))]) == Array{InterpolationSupport{2,Float64,Int}, 1}
	@test typeof(InterpolationSupport[(1., 2, 1), (2., 3, 4)]) == Array{InterpolationSupport{2,Float64,Int}, 1}
end;
