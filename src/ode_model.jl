typealias NSE Union(Number, Symbol, Expr)
typealias SE Union(Symbol, Expr)

type OdeModel
  file::String
  
  states::Dict{String, Float64}
  parameters::Dict{String, Float64}
  odes::Dict{String, NSE}
end

OdeModel(file::String) = parse_model(file::String)
