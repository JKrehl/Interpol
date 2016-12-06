using BenchmarkTools

using Interpolations
using Interpol

Atest = rand((10^2, 10^2, 10^2));

@benchmark @inbounds($(Atest)[LinearInterpolation, x,y,z]) setup = (x=$(1+99*rand()); y=$(1+99*rand()); z=$(1+99*rand()))
@benchmark @inbounds($(Atest)[x,y,z]) setup = (x=$(round(Int, 1+99*rand())); y=$(round(Int, 1+99*rand())); z=$(round(Int, 1+99*rand())))
@benchmark @inbounds(inplaceadd($(Atest), LinearInterpolation, 1., x,y,z)) setup = (x=$(1+99*rand()); y=$(1+99*rand()); z=$(1+99*rand()))
@benchmark $(interpolate(Atest, BSpline(Linear()), OnGrid()))[x,y,z] setup = (x=$(1+99*rand()); y=$(1+99*rand()); z=$(1+99*rand()))


@benchmark for (x,y,z) in xyz @inbounds(@inbounds($(Atest)[LinearInterpolation, x,y,z])) end setup = (xyz=$(zip((1+99*rand(1000)), (1+99*rand(1000)), (1+99*rand(1000)))))
@benchmark for (x,y,z) in xyz @inbounds($(interpolate(Atest, BSpline(Linear()), OnGrid()))[x,y,z]) end setup = (xyz=$(zip((1+99*rand(1000)), (1+99*rand(1000)), (1+99*rand(1000)))))

@benchmark for (x,y) in xy; ($Atest[ConstantBoundary, x,y]) end setup = (xy=$(zip(round(Int, -1000+2000*rand(1000)), round(Int, -1000+2000*rand(1000)))))
