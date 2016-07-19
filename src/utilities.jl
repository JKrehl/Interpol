export append

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
