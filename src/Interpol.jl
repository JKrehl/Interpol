module Interpol

	include("Interpolation.jl")

	include("interpolations/linear.jl")
	include("interpolations/nearest.jl")

end
