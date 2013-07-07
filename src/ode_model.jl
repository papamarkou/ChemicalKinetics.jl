typealias NSE Union(Number, Symbol, Expr)
typealias SE Union(Symbol, Expr)

type OdeModel
  file::String
  
  states::Dict{ASCIIString, Float64}
  parameters::Dict{ASCIIString, Float64}
  odes::Dict{ASCIIString, NSE}
end

OdeModel(file::String) = parse_model(file::String)
