typealias NSE Union{Number, Symbol, Expr}
typealias SE Union{Symbol, Expr}

type OdeModel
  file::AbstractString

  states::Dict{AbstractString, Float64}
  parameters::Dict{AbstractString, Float64}
  odes::Dict{AbstractString, NSE}
end

OdeModel(file::AbstractString) = parse_model(file::AbstractString)
