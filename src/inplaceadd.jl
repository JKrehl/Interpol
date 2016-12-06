export inplaceadd!

@inline function inplaceadd!(arr::AbstractArray, v, x...)
	arr[x...] += v
end
