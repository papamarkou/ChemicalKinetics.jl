function replace(exprn::Expr, dict::Dict{Union{Symbol, Expr}, Union{Symbol, Expr}})
  queue = Array(Union{Number, Symbol, Expr}, 0)
  unshift!(queue, exprn)

  while length(queue) != 0
    node = shift!(queue)

    for i in 2:length(node.args)
      if isa(node.args[i], Expr)
        if haskey(dict, node.args[i]) && get(dict, node.args[i], :()) != :()
          node.args[i] = dict[node.args[i]]
        else
          unshift!(queue, node.args[i])
        end
      elseif isa(node.args[i], Symbol) && haskey(dict, node.args[i]) && get(dict, node.args[i], :()) != :()
        node.args[i] = dict[node.args[i]]
      end
    end
  end
end
