# 3Hedp analysis
#
# purpose: Real  DATA
#
# - 5 parameters are assumed: Er, gamma_d^2, gamma_n^2 [e1, gin, gout]
#
# - uses the function sfactorHe3dp(obsx1[i], e1, gin, gout), which
#   is a C++ version of a Fortran code that includes Coulomb wave
#   function calculations; JAGS has been recompiled with this C++ function
#
######################################################################
# preparation: remove all variables from the work space
#rm(list=ls())
set.seed(123)
######################################################################
# data input
# format: obsx, obsy, errobsy; the latter are the individual statistical
# errors of each datum [i]
#
# energy is in units of MeV, and the S-factor in MeVb;

######################################################################
# import packages

require(RcppGSL);require(ggplot2);require(ggthemes)
require(nuclear);library(magrittr);library(wesanderson)
library(dplyr);require(gsl);library(latex2exp)
require(nimble)
######################################################################
## ARTIFICIAL DATA GENERATION


N <- 150

#obsx1 <- runif(N,0,0.7)
obsx1 <- exp(runif(N,log(1e-3),log(1)))
sd <- 0.5
obsy1 <- rnorm(N, sfactorHe3dp(obsx1,0.35779,1.0085,0.025425,6,5,0),sd=sd)

plot(obsx1,obsy1,log= "x")

M <- 150
xx <- seq(min(obsx1),max(obsx1),length.out = M)
model.data <- list(obsy = obsy1,    # Response variable
                   obsx =  obsx1
)
#

sfactorHe3dpNimble <- nimbleRcall(function(ecm = double(0),
                              e0 = double(0),gi = double(0),
                              gf = double(0),ri = double(0),
                              rf = double(0),ue = double(0)){},
                              Rfun = 'sfactorHe3dp',
                              returnType = double(0))


model <- nimbleCode({
   for (i in 1:150) {
    obsy[i] ~ dnorm(mu[i],sd)
     mu[i] <- sfactorHe3dpNimble(obsx[i], e1, gin, gout,6,5,0)

      }

  sd ~  dgamma(0.1,0.1)
  e1 ~  dgamma(0.1,0.1)
  gin ~  dgamma(0.1,0.1)
  gout ~ dgamma(0.1,0.1)
})
inits <- list(e1 = runif(1,0.01,1),gout=0.01,gin=runif(1,0.01,1),
              sd = runif(1,0.01,1))

Rmodel <- nimbleModel(code = model,data = model.data, inits = inits,check = FALSE)
compileNimble(Rmodel)

mcmcConf <- configureMCMC(Rmodel, monitors = c("e1", "gin", "gout","sd"))
mcmc_CL <- buildMCMC(mcmcConf)
CRmodel <- compileNimble(mcmc_CL,project = Rmodel)

mcmcChain <- runMCMC(CRmodel ,niter = 1000, nchains = 3, nburnin = 50,
                     setSeed=15,samplesAsCodaMCMC = TRUE)


S <- ggs(mcmcChain)

ggs_histogram(S)
ggs_traceplot(S)

mcmc.output <- nimbleMCMC(Rmodel, data = model.data, inits = inits,
                          monitors = c("e1", "gin", "gout","sd"), thin = 10,
                          niter = 20000, nburnin = 1000, nchains = 3,
                          summary = TRUE, WAIC = TRUE)





mcmcConf <- configureMCMC(Rmodel, monitors = c("e1", "gin", "gout","sd"))
mcmc_CL <- buildMCMC(mcmcConf)
samplesList <- runMCMC(mcmc_CL, niter = 50, nchains = 3, inits = inits)


Rmcmc <- buildMCMC(model)
Rmodel$setData(model.data)
Cmodel <- compileNimble(Rmodel)
Cmcmc <- compileNimble(Rmcmc, project = Rmodel)






