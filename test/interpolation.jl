using Base.Test

@testset "getindex compoundinterpolation" begin
	@test CompoundInterpolation(LinearInterpolation, NearestInterpolation)[1.25, 2.2] == InterpolationSupport[(.75,(1,2)), (.25,(2,2))]
end;

@testset "getindex array compoundinterpolation" begin
	@test rand(10,10,10)[CompoundInterpolation(LinearInterpolation, NearestInterpolation, LinearInterpolation), 1.1, 1.25, 2.2] < 1
end;
