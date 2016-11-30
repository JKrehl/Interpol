module Interpol

	include("utilities.jl")

	include("Interpolation.jl")

	include("interpolations/linear.jl")
	include("interpolations/nearest.jl")

end
