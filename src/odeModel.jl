typealias NSE Union(Number, Symbol, Expr)

type OdeModel
  file::String
  
  states::Dict{ASCIIString, Float64}
  parameters::Dict{ASCIIString, Float64}
  odes::Dict{ASCIIString, NSE}
end

OdeModel(file::String) =
  OdeModel(file, Dict{ASCIIString, Float64}(), Dict{ASCIIString, Float64}(), Dict{ASCIIString, NSE}())
