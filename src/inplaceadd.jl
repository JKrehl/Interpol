export inplaceadd!

@inline function inplaceadd!{AT, IT, N}(arr::AbstractArray{AT, N}, v, x::Vararg{IT, N})
	arr[x...] += v
end
