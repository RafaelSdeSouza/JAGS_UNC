# preparation: remove all variables from the work space
rm(list=ls())
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
require(nuclear);library(magrittr);require(gsl)
library(dplyr);require(lessR);library(BayesianTools);
<<<<<<< HEAD
require(truncnorm)
=======
require(truncnorm);require(msm)
source("SfacTdn.R")


######################################################################
## Read DATA
ensamble <- read.csv("ensamble_Tdn_extra.csv",header = T)
#%>%  filter(E <= 0.5)
#filter(dat!= "Mag75")
#%>% filter(E <= 0.5) %>%   filter(dat!= "Arn53") %>%
# droplevels(ensamble$dat)


re <- as.numeric(ensamble$dat)
Nre <- length(unique(ensamble$dat))
Nik <- length(unique(ensamble$invK))

# Radius
# r_i = 6
# r_f = 5


N <- nrow(ensamble)
obsy <- ensamble$S    # Response variable
obsx <-  ensamble$E   # Predictors
erry <- ensamble$Stat
errx <- ensamble$E_stat
set <- ensamble$dat
lab <- ensamble$invK
syst = c(unique(ensamble$Syst))
systx <- c(0.000075,0.000009,0.0002,0.000006,0.0032)


likelihood <- function(par){
  e0 = par[1]
  gin = par[2]
  gout = par[3]
  sigma_scat = par[4:8]
  scale = par[9:13]
  xrand = par[14:18]
  ue = par[19]
  y = par[20:(N + 19)]
  xtrue = par[(N + 20):(2*N + 19)]

  llxrand = sum(dnorm(xrand,mean=0,sd=systx,log=T))
  llRandom = sum(dlnorm(scale,meanlog = log(1), sdlog = log(1 + syst^2), log = T))
  llx <- sum(dnorm(obsx,mean = xtrue + xrand[re],sd=errx,log=T))
  lly <- sum(dnorm(y,mean = scale[re]*SfacTdn(xtrue, e0,e0,gin, gout,6,5,ue), sd = sigma_scat,  log = T))
  llobs = sum(dnorm(obsy,mean = y,sd = erry,log = T))


  return(llRandom + llobs + lly + llx + llxrand)
}

low <- c(1e-3,1e-3,1e-3,rep(1e-4,5),rep(0.8,5),rep(-0.9,5),0,obsy - 2*abs(erry),obsx - abs(errx))
up <- c(1,6,6,rep(1,5),rep(1.2,5),rep(0.1,5),50,obsy + 2*abs(erry),obsx + abs(errx))



density = function(par){
  d1 = dnorm(par[1], mean = 0, sd = 1, log = TRUE)
  d2 = sum(log(dtruncnorm(par[2:3], mean = 0, sd = 3)))
  d3 = sum(log(dtruncnorm(par[4:8], 0, 2)))
  d4 = sum(dlnorm(par[9:13],1,log(1 + syst^2),log = TRUE))
  d5 = sum(dnorm(par[14:18],0,sd=systx,log = TRUE))
  d6 = dunif(par[19], 0, 1000)
  d7 = sum(dnorm(par[20:(N + 19)],mean=obsy,sd=erry,log = TRUE))
  d8 = sum(dunif(par[(N + 20):(2*N + 19)],0.001,0.3,log = TRUE))
  return(d1 + d2 + d3 + d4 + d5 + d6 + d7 +d8)
}


sampler = function(){
  d <- list()
  d[1] = runif(1, 0,  1)
  d[2:3] = rtruncnorm(2, mean= 0, sd=3)
  d[4:8] = rtruncnorm(5, 0, 2)
  d[9:13] = runif(5, 0.8, 1.2)
  d[14:18] = rnorm(5, 0, systx)
  d[19] = runif(1, 0, 100)
  d[20:(N + 19)] = rnorm(N,obsy, erry)
  d[(N + 20):(2*N + 19)] = runif(N,0.001,0.3)
  return(as.numeric(d))
}


#prior <- createPrior(density = density,
#                    lower = low, upper = up, best = NULL)


setup <- createBayesianSetup(likelihood = likelihood, prior=prior, sampler=sampler,lower = low, upper = up,
names = c("e0","gd2","gn2",to("sigma_scat", 5),to("scale", 5),to("xnorm", 5),"ue",
          to("y", N),to("x", N)))

settings <- list(iterations = 700000,adaptation = 0.4,
                 burnin = 350000, message = T,nrChains = 1)
res <- runMCMC(bayesianSetup = setup, settings = settings,sampler = "DREAMzs")

  yscat = par[4:8]
  ynorm = par[9:13]
  xscat = par[14:18]
  xnorm = par[19:23]
  ue = par[24]
  y = par[25:(N + 24)]
  xx = par[(N + 25):(2*N + 24)]
 # xtrue = par[(2*N + 25):(3*N + 24)]

  llxnorm = sum(dnorm(xnorm,mean=0,sd=systx,log = T))
  llynorm = sum(dlnorm(ynorm,meanlog = log(1), sdlog = log(1 + syst^2), log = T))
  llxscat <- sum(dnorm(xscat,mean = 0,sd=0.01,log = T))
  llxx <- sum(dnorm(obsx,mean = xx + xnorm[re],sd = (errx + xscat[re]),log = T))
  lly <- sum(dnorm(y,mean = ynorm[re]*SfacTdn(xx, e0,e0,gin, gout,6,5,ue), sd = yscat[re],  log = T))
  llobs = sum(dnorm(obsy,mean = y,sd = erry,log = T))
  return(llynorm + llobs + lly + llxx  + llxnorm + llxscat)
}

low <- c(1e-3,rep(1e-3,2),rep(1e-4,5),rep(0.8,5),rep(1e-5,5), rep(-0.02,5),1e-3,obsy - 2*abs(erry),obsx - 2*errx)
up <- c(1,rep(6,2),rep(1,5),rep(1.2,5),rep(0.03,5),rep(0.02,5),100,obsy + 2*abs(erry),obsx + 2*errx)




 createTdnPrior <- function(lower, upper, best = NULL){
    density = function(par){
    d1 = dnorm(par[1], mean = 0, sd = 1, log = TRUE)
    d2 = sum(dtnorm(par[2:3], mean = 0, sd = 3,log = TRUE))
    d3 = sum(dunif(par[4:8], 0, 1,log = TRUE))
    d4 = sum(dlnorm(par[9:13],log(1),log(1 + syst^2),log = TRUE))
    d5 = sum(dtnorm(par[14:18],0, 0.01,log = TRUE))
    d6 = sum(dnorm(par[19:23],0,sd = systx,log = TRUE))
    d7 = dgamma(par[24], 1, 0.05,log = TRUE)
    d8 = sum(dunif(par[25:(N + 24)],obsy - 2*erry,obsy + 2*erry,log = TRUE))
    d9 = sum(dunif(par[(N + 25):(2*N + 24)],obsx - 2*errx,obsx + 2*errx,log = TRUE))
#    d10 = sum(dnorm(par[(2*N + 25):(3*N + 24)],obsx,erry,log = TRUE))
    return(d1 + d2 + d3 + d4 + d5 + d6 + d7 + d8 + d9)
    }
     sampler = function(){
      c(runif(1,1e-3, 2),
        runif(2,1e-3, 6),
        runif(5,1e-4, 1),
        rlnorm(5, log(1), log(1 + syst^2)),
        runif(5, 1e-5, 0.01),
        rnorm(5, 0, systx),
        rgamma(1, 1, 0.05),
        runif(N, obsy - erry,obsy + erry),
        runif(N,obsx - errx,obsx + errx)
        #        runif(N,obsx - abs(errx),obsx + abs(errx))
      )
    }

  out <- createPrior(density = density, sampler = sampler, lower = lower, upper = upper, best = best)
  return(out)
}

prior <- createTdnPrior(lower = low, upper = up)

setup <- createBayesianSetup(likelihood = likelihood, prior = prior,
names = c("e0","gd2","gn2",to("yscat", 5),to("ynorm", 5),to("xscat", 5),
        to("xnorm", 5),"ue", to("y", N),to("x", N)))

settings <- list(iterations = 6000,adaptation = 0.4,
                 burnin = 2000, message = T,nrChains = 1,thin=10)

res <- runMCMC(bayesianSetup = setup, settings = settings,sampler = "DREAMzs")



tracePlot(sampler = res, start = 10000, whichParameters = c(1,2,3))


mcmc_out <- function(out = out, vars = vars){
  as.data.frame(do.call(rbind, out$chain[,vars]))
}


mo <- mcmc_out(res,vars=c("e0","gd2","gn2",to("yscat", 5),to("ynorm", 5),to("xscat", 5),
                          to("xnorm", 5),"ue"))[100000:900003,]

index <- sample(1:nrow(mo),50000,replace=F)
short_mo <- mo[index ,]

write.matrix(short_mo,"BT_Tdn_caseI.dat")



bayesianSetup <- createBayesianSetup(likelihood = ll, prior = newPrior)

settings = list(iterations = 1000,  message = FALSE)
out <- runMCMC(bayesianSetup = bayesianSetup, settings = settings)


out2 <- DREAMzs(res,settings = settings)




summary(res)

tracePlot(sampler = res, start = 100000, whichParameters = c(1,2,3,19))



tracePlot(sampler = res, start = 100000, whichParameters = c(14:18))


plot(mo$gd2,mo$gn2,type="l")


correlationPlot(res )


tracePlot(sampler = res, thin = 10, start = 5000, whichParameters = c(1,2,3,4,5,6,7,8,9))




sampler = function(){
  d <- list()
  d[1] = runif(1, 0,  1)
  d[2:3] = rtnorm(2, 0,  3,low=0)
  d[4:8] = rtnorm(5, 0, 1,low=0)
  d[9:13] = rtnorm(5, 1, log(1 + syst^2))
  d[14:18] = rtnorm(5, 0, 0.01,low=0)
  d[19:23] = rnorm(5, 0, systx)
  d[24] = rtnorm(1, 0, 100,low=0)
  d[25:(N + 24)] = rnorm(N, obsy, erry)
  d[(N + 25):(2*N + 24)] = runif(N,0.001,0.3)
  d[(2*N + 25):(3*N + 24)] = runif(N,0.001,0.3)
  return(as.numeric(d))
}




density = function(par){
  d1 = dnorm(par[1], 0.001,1, log =TRUE)
  d2 = dunif(par[2], 0.001,3, log =TRUE)
  d3 = dunif(par[3], 0.001,3, log =TRUE)
  return(d1 + d2 + d3)
}

sampler = function(n=1){
  d1 = rnorm(n, 0.001,1)
  d2 = rnorm(n, 0.001,1)
  d3 = rnorm(n, 0.001,1)
  return(cbind(d1,d2,d3))
}
prior <- createPrior(density = density, sampler = sampler,
                     lower = c(0.001,0.001,0.001), upper = c(10,10,10), best = NULL)


codaObject = getSample(res, start = 500, coda = TRUE)

as.mcmc(codaObject)
getmcmc_var <- function(outjags=outjags,vars = vars){
  as.data.frame(do.call(rbind, outjags[,vars]))
}
getmcmc_var(codaObject,vars = c("par 1","par 2","par 3","par 4"))

