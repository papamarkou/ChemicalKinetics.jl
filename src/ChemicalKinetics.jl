module ChemicalKinetics  
  include("odeModel.jl")
  include("parser.jl")
  
  export
    OdeModel,
    parse_model
end
