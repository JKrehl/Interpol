using Base.Test

@testset "abstract base types" begin
	@test AbstractInterpolation() == AbstractInterpolation{1}
	@test AbstractInterpolation(3) == AbstractInterpolation{3}
	@test ndims(AbstractInterpolation{3}) == 3
	
	@test InterpolationContainer{3, Tuple{AbstractInterpolation{3}, AbstractInterpolation{4}}} <: AbstractInterpolation{3}
	@test InterpolationContainer(Tuple{AbstractInterpolation{2}, AbstractInterpolation{4}}) == InterpolationContainer{6, Tuple{AbstractInterpolation{2}, AbstractInterpolation{4}}}
	@test InterpolationContainer(AbstractInterpolation(), AbstractInterpolation{4}) == InterpolationContainer{5, Tuple{AbstractInterpolation{1}, AbstractInterpolation{4}}}
	@test ndims(InterpolationContainer{6, Tuple{AbstractInterpolation{2}, AbstractInterpolation{4}}}) == 6
end;
