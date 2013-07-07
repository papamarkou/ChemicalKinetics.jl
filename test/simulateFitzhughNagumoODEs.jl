using ChemicalKinetics

odeModel = OdeModel("fitzhughNagumoModel.txt")

# ckCvode = CkCvode(odeModel, [i for i in 0:1.:25], 1e-4, [1e-8, 1e-14, 1e-6])
ckCvode = CkCvode(odeModel, [i for i in 0:1.:25])

simulation = ckCvode.simulate_odes()

println(simulation)
