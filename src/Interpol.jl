module Interpol

	include("inplaceadd.jl")

	include("Interpolation.jl")

	include("interpolations/linear.jl")
	include("interpolations/nearest.jl")

	include("Boundaries.jl")

	include("boundary_conditions/constant.jl")

	include("Compound.jl")

end
