import Base.getindex

@inline getindex{A<:AbstractArray, BC<:AbstractBoundary, IN<:Interpol.AbstractInterpolation}(arr::A, bound::Type{BC}, interp::Type{IN}, x::Real...) = BoundedArray(arr, BC)[IN, x...]

@inline inplaceadd!{A<:AbstractArray, BC<:AbstractBoundary, IN<:Interpol.AbstractInterpolation}(arr::A, bound::Type{BC}, interp::Type{IN}, v, x::Real...) = inplaceadd!(BoundedArray(arr, BC), IN, v, x...)
