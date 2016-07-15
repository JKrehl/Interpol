export LinearInterpolation

type LinearInterpolation <: AbstractInterpolation
end

function pointinterpolation1d(::Type{LinearInterpolation}, ic::Symbol, rc::Symbol, arr, ex::Expr=:())
	if ex == :()
		ex = Expr(:ref, arr)
	end
	return :((1-$rc)*$(appendtorefs(copy(ex), arr, ic))  + ($rc)*$(appendtorefs(copy(ex), arr, :($ic+1))))
end

function pointinterpolation(::Type{LinearInterpolation}, N, arr)
	reduce(|>, :(), [ex -> pointinterpolation1d(LinearInterpolation, symbol(:i, "_", string(i)), symbol(:r, "_", string(i)), arr, ex) for i in 1:N])
end
