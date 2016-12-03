using Base.Test

@testset "linear interpolation base" begin
	@test getindex(LinearInterpolation, one(Float64)) == InterpolationSupport[(1.,1),(0.,2)]
	@test eltype(getindex(LinearInterpolation, one(Float32))) == InterpolationSupport{1, Float32, Int}
	@test getindex(LinearInterpolation, one(Int)) ==  InterpolationSupport[(1,1),(0,2)]
end;

@testset "nearest interpolation base" begin
	@test getindex(NearestInterpolation, one(Float64)) == InterpolationSupport{1, Float64, Int}[(1.,1)]
	@test getindex(NearestInterpolation, one(Float16)) == InterpolationSupport{1, Float16, Int}[(one(Float16),1)]
	@test getindex(NearestInterpolation, one(Int)) == InterpolationSupport{1, Int, Int}[(1,1)]
end;
