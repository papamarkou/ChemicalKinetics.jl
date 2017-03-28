## Overview of package's scope

[![Build Status](https://travis-ci.org/scidom/ChemicalKinetics.jl.png)](https://travis-ci.org/scidom/ChemicalKinetics.jl)
[![ChemicalKinetics](http://pkg.julialang.org/badges/ChemicalKinetics_0.5.svg)](http://pkg.julialang.org/?pkg=ChemicalKinetics&ver=0.5)

This package provides tools for simulation and statistical analysis of systems
modelled by kinetic equations. Reaction kinetics can be expressed as systems of
ordinary differential equations (ODEs), thus allowing Bayesian estimation of
the involved system parameters, such as reaction rates and transition states,
and Bayesian selection among candidate models of the unerlying chemical
processes or pathways.

At the moment, the package implements the simulation of time courses of the
kinetic equations, as well as the simulation of data of the states. Bayesian
inference and model selection will be implemented as soon as the prerequired
population MCMC algorithms are set up in a parallel fashion.

## Tutorial

As a short tutorial, the states and their initial conditions, the model
parameters and their values needed for simulation, and the system of ODEs
defining the kinetic equations are all provided in a file. An example is
available in `test/simulateFitzhughNagumoODEs.jl`, which demonstrates how to
define the Fitzhugh Nagumo differential equations. The file's sections are
marked as `*** MODEL STATES ***`, `*** MODEL PARAMETERS ***` and
`*** MODEL ODES ***`. The first three stars indicate that the line represents a
title and the sections are distinguished by using one of the self-explantory
strings `MODEL STATES`, `MODEL PARAMETERS` or `MODEL ODES`. Any other trailing
characters are optional.

To parse the file, use

    using ChemicalKinetics
    odeModel = OdeModel("fitzhughNagumoModel.txt")

and to set up the tailored CVODE Sundials solver in order to simulate a time
course of 25 minutes run

    ckCvode = CkCvode(odeModel, [i for i in 0:1.:25])

Then simulate the ODE system and generate data from it with noise variance
equal to 0.1:

    ode_simulation, data_simulation = ckCvode.simulate_data(0.1)

The following plot shows an example of such simulation:

![plot results](https://github.com/scidom/ChemicalKinetics.jl/blob/master/test/fitzhugh_nagumo_simulation.png?raw=true "Fitzhugh Nagumo simulation")
https://github.com/scidom/ChemicalKinetics.jl/blob/master/test/fitzhugh_nagumo_simulation.png
