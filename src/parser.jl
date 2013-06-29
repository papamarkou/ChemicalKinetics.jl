function parse_model(file::String)
  odeModel = OdeModel(file)

  s = open(file)

  while !eof(s)
    line = readline(s)
    if isempty(line) || iscomment(line)
      continue
    elseif istitle(line)
      title = get_title_type(line)
    else
      parse_line(line, title, odeModel)
    end
  end
  
  close(s)
  
  return odeModel
end

isempty(line::ASCIIString) = !ismatch(r"[^\s\t\n\r]+", line)

iscomment(line::ASCIIString) = ismatch(r"^#", line)

istitle(line::ASCIIString) = ismatch(r"^\*\*\*(.*)MODEL (STATES|PARAMETERS|ODES)", line)

function get_title_type(line::ASCIIString)
  if ismatch(r"^\*\*\*(.*)MODEL STATES(.*)", line)
    return "state"
  elseif ismatch(r"^\*\*\*(.*)MODEL PARAMETERS(.*)", line)
    return "parameter"  
  elseif ismatch(r"^\*\*\*(.*)MODEL ODES(.*)", line)
    return "ode"
  else
    throw(ParseError("Unknown title \""*line*"\" type in model specification"))
  end
end

function parse_line(line::ASCIIString, linetype::ASCIIString, model::OdeModel)  
  if linetype == "state"
    nTokens = parse_state_line(line, model.states)
  elseif linetype == "parameter"
    nTokens = parse_parameter_line(line, model.parameters)
  elseif linetype == "ode"
    nTokens = parse_ode_line(line, model.odes)
  else
    throw(ParseError("Unknown title \""*line*"\" type in model specification"))
  end
  
  return nTokens
end

function parse_state_line(line::ASCIIString, dict::Dict{ASCIIString, Float64})
  tokens = split(line, '=')
  nTokens = length(tokens)
  
  if nTokens != 2
    throw(ParseError("Line \""*line*"\" has wrong format"))
  end

  name, value = [strip(i) for i in tokens]  
  
  haskey(dict, name) ? throw(KeyError("\""*name*"\" specified more than once")) : (dict[name] = float64(value))
  
  return nTokens
end

function parse_parameter_line(line::ASCIIString, dict::Dict{ASCIIString, Float64})
  tokens = split(line, '=')
  nTokens = length(tokens)
  
  if nTokens == 1
    dict[strip(tokens)] = NaN
  elseif nTokens == 2
    name, value = [strip(i) for i in tokens]  
  
    haskey(dict, name) ? throw(KeyError("\""*name*"\" specified more than once")) : (dict[name] = float64(value))
  else
    throw(ParseError("Line \""*line*"\" has wrong format"))    
  end
  
  return nTokens  
end

function parse_ode_line(line::ASCIIString, dict::Dict{ASCIIString, NSE})
  tokens = split(line, '=')
  nTokens = length(tokens)
  
  if nTokens != 2
    throw(ParseError("Line \""*line*"\" has wrong format"))
  end

  name, value = [strip(i) for i in tokens]

  haskey(dict, name) ? throw(KeyError("\""*name*"\" specified more than once")) : (dict[name] = parse(value))
  
  return nTokens
end
