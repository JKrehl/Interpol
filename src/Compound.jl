import Base.getindex

@inline getindex{A<:AbstractArray, IM1<:AbstractIndexManipulator, IM2<:AbstractIndexManipulator}(arr::A, ::Type{IM1}, ::Type{IM2}, x::Number...) = getindex(arr, Tuple{IM1}, IM2, x...)

@inline inplaceadd!{A<:AbstractArray, IM1<:AbstractIndexManipulator, IM2<:AbstractIndexManipulator}(arr::A, ::Type{IM1}, ::Type{IM2}, v::Number, x::Number...) = inplaceadd!(arr, Tuple{IM1}, IM2, v, x...)
