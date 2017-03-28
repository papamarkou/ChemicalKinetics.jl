module ChemicalKinetics
  using Distributions
  using Sundials

  include("ode_model.jl")
  include("ode_solver.jl")
  include("parser.jl")
  include("symbolic.jl")

  export
    NSE,
    SE,
    OdeModel,
    CkCvode,
    parse_model,
    replace
end
