export append

import Base.checkbounds

append{T}(ex::Expr, app::T) = Expr(ex.head, ex.args..., app...)
append{T<:Union{Expr, Symbol}}(ex::Expr, app::T) = Expr(ex.head, ex.args..., app)

function appendtorefs(ex::Expr, sym::Union{Symbol, Expr}, tex::Union{Symbol, Expr})
	if ex.head == :ref && ex.args[1]==sym
		push!(ex.args, tex)
	else
		for e in ex.args
			if typeof(e)<:Expr
				appendtorefs(e, sym, tex)
			end
		end
	end
	return ex
end

@generated function checkbounds{T, N}(::Type{Bool}, arr::AbstractArray{T, N}, x::Integer...)
	quote
		$(Expr(:meta, :inline))
		$(Expr(:block, [:($(symbol("x_", i)) = x[$i]) for i in 1:N]...))
		return !$(reduce((i,j) -> Expr(:||, i, j), vcat([[:(1 > x[$i]), :(x[$i] > size(arr, $i))] for i in 1:N]...)))
	end
end
