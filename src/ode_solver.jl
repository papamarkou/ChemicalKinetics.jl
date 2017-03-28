type CkCvode
  initStates::Array{Float64, 1}
  parameters::Array{Float64, 1}
  time::Array{Float64, 1}
  relTol::Float64
  absTol::Array{Float64, 1}

  odes::Function
  simulate_odes::Function
  simulate_data::Function

  CkCvode(odeModel::OdeModel, time, relTol, absTol) = begin
    instance = new()

    instance.initStates = collect(values(odeModel.states))
    instance.parameters = collect(values(odeModel.parameters))
    instance.time = time
    instance.relTol = relTol
    instance.absTol = absTol

    instance.odes = make_ck_cvode_odes(odeModel)
    instance.simulate_odes = (() -> simulate_ck_cvode_odes(odeModel, instance))
    instance.simulate_data = (noiseVar::Float64 -> simulate_ck_cvode_data(odeModel, instance, noiseVar))

    instance
  end
end

CkCvode(odeModel::OdeModel, time) = CkCvode(odeModel::OdeModel, time, 1e-4, [1e-8, 1e-14, 1e-6])

function codegen_ck_cvode_odes(odeModel::OdeModel)
  state_keys = collect(keys(odeModel.states))
  i = 0; state_dict = Dict{SE,SE}(Symbol(j)=>Expr(:ref, :_y, i+=1) for j in state_keys)
  i = 0; ode_dict = Dict{SE,SE}(Symbol(j)=>Expr(:ref, :_ydot, i+=1) for j in state_keys)
  i = 0; parameter_dict = Dict{SE,SE}(Symbol(j)=>Expr(:ref, :_p, i+=1) for j in keys(odeModel.parameters))

  scratch_odes = copy(odeModel.odes)
  for i in values(scratch_odes)
    replace(i, state_dict)
    replace(i, parameter_dict)
  end

  body = []
  for i in state_keys
    push!(body, :($(ode_dict[Symbol(i)]) = $(scratch_odes[i])))
  end

  @gensym ck_cvode_odes
  quote
    function $ck_cvode_odes(_t, _y, _ydot, _p)
      $(body...)
    end
  end
end

make_ck_cvode_odes(odeModel::OdeModel) = eval(codegen_ck_cvode_odes(odeModel))

function ck_cvode_ode_wrapper(t, y, ydot, user_data)
  y = Sundials.asarray(y)
  ydot = Sundials.asarray(ydot)

  user_data[1](t, y, ydot, user_data[2])

  return Int32(0)
end

function simulate_ck_cvode_odes(odeModel::OdeModel, ckCvode::CkCvode)
  nStates = length(ckCvode.initStates)
  nTimePoints = length(ckCvode.time)

  cvode_mem = Sundials.CVodeCreate(Sundials.CV_BDF, Sundials.CV_NEWTON)
  flag = Sundials.CVodeInit(cvode_mem, cfunction(ck_cvode_ode_wrapper, Int32, (Sundials.realtype, Sundials.N_Vector,
    Sundials.N_Vector, Array{Any, 1})), ckCvode.time[1], Sundials.nvector(ckCvode.initStates))
  flag = Sundials.CVodeSetUserData(cvode_mem, [ckCvode.odes, ckCvode.parameters])
  flag = Sundials.CVodeSVtolerances(cvode_mem, ckCvode.relTol, ckCvode.absTol)
  flag = Sundials.CVDense(cvode_mem, nStates)

  y = Array(Float64, nTimePoints-1, nStates)

  for i in 2:nTimePoints
    flag = Sundials.CVode(cvode_mem, (ckCvode.time)[i], ckCvode.initStates, [(ckCvode.time)[1]], Sundials.CV_NORMAL)

    if flag != Sundials.CV_SUCCESS
      throw(KeyError("SUNDIALS_ERROR: CVODE failed with flag = ", flag))
    end

    y[i-1, :] = ckCvode.initStates
  end;

  y
end

function simulate_ck_cvode_data(odeModel::OdeModel, ckCvode::CkCvode, noiseVar::Float64)
  nStates = length(ckCvode.initStates)

  simulated_odes = simulate_ck_cvode_odes(odeModel, ckCvode)
  noise = rand(MultivariateNormal(zeros(nStates), noiseVar*eye(nStates)), length(ckCvode.time)-1)'

  return simulated_odes, simulated_odes+noise
end
