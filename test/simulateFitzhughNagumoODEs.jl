using ChemicalKinetics

odeModel = OdeModel("fitzhughNagumoModel.txt")

# ckCvode = CkCvode(odeModel, [i for i in 0:1.:25], 1e-4, [1e-8, 1e-14, 1e-6])
ckCvode = CkCvode(odeModel, [i for i in 0:1.:25])

# ode_simulation = ckCvode.simulate_odes()
# println("Simulated values of kinetic equations:")
# println(ode_simulation)

# Simulate data from kinetic equations with noise variance = 0.25
ode_simulation, data_simulation = ckCvode.simulate_data(0.25)
println("Simulated values of kinetic equations:")
println(ode_simulation)
println("\nSimulated data:")
println(data_simulation)
