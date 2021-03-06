# He3dp analysis
#
# purpose: ARTIFICIAL DATA
#
# - 3 parameters are assumed: Er, gamma_d^2, gamma_n^2 [e1, gin, gout]
#
# - uses the function sfactorTdn_fast(obsx1[i], e1, gin, gout), which
#   is a C++ version of a Fortran code that includes Coulomb wave
#   function calculations; JAGS has been recompiled with this C++ function 
#
# Fortran code tdn_plot.f is needed in this R script for plotting the
# S-factor only
#
######################################################################
# preparation: remove all variables from the work space
#rm(list=ls())
#set.seed(123)
######################################################################
# data input
# format: obsx, obsy, errobsy; the latter are the individual statistical 
# errors of each datum [i]
#
# energy is in units of MeV, and the S-factor in MeVb; 
######################################################################
######################################################################                 
# import jags package 
library(rjags);library(R2jags);library(mcmcplots)
require(RcppGSL);require(ggplot2);require(ggthemes)
require(nuclear)
source("https://raw.githubusercontent.com/johnbaums/jagstools/master/R/jagsresults.R")
## for block updating [we do not need to center predictor variables]
load.module("glm")  
load.module("nuclear")  


######################################################################
## ARTIFICIAL DATA GENERATION 

N <- 100

#obsx1 <- runif(N,0,0.7)
obsx1 <- exp(runif(N,log(5e-2),log(1)))
errobsy1 <- runif(N,0.5,1)
obsy1 <- rnorm(N, sfactor3Hedp(obsx1 ,0.35779,1.0085,0.025425),errobsy1)

M <- 150
xx <- seq(min(obsx1),max(obsx1),length.out = M)
model.data <- list(obsy = obsy1,    # Response variable
                   obsx =  obsx1,   # Predictors
                   erry = errobsy1,
                   N = N, # Sample size
                   M = M, 
                   xx = xx
)






# 
######################################################################                 
cat('model {
    
    # LIKELIHOOD
    for (i in 1:N) {
    obsy[i] ~ dnorm(y1[i], pow(erry[i], -2))
    #  y1[i] ~ dnorm(sfactorTdn(obsx[i], e1, gin, gout),pow(tau,-2))  
    y1[i] <- sfactor3Hedp(obsx[i], e1, gin, gout)  
    }
    
    # Predicted values
    
    for (j in 1:M){
    mux[j] <- sfactor3Hedp(xx[j], e1, gin, gout)
    #yx[j] ~ dnorm(mux[j],pow(tau,-2))
    }
    
    # PRIORS
    # e1, gin, gout are defined as in tdn.f (by Alain Coc):
    # resonance energy, initial reduced width, final reduced 
    # width;
    
    ## Physical priors:
    # Hyperpriors
    
    ##
    
    
    #  tau ~dgamma(0.01,0.01)
    
    e1 ~ dnorm(0,0.1)T(0,)
    gin ~ dunif(0,10) 
    gout ~ dunif(0,10)
    
    # e1 ~   dgamma(sh0,ra0)
    # sh0 <- pow(m0,2) / pow(sd0,2)
    # ra0 <- m0/pow(sd0,2)
    # m0  <- 0.1
    #sd0 ~  dunif(0.1,1) 
    
    # gin ~ dgamma(0.01,0.01)
    #   gin ~ dgamma(sh2,ra2)
    #    sh2 <- pow(m2,2) / pow(sd2,2)
    #    ra2 <- m2/pow(sd2,2)
    #   m2 <- 3 
    #   sd2 <- 1
    
    #gout ~ dgamma(0.01,0.01)
    #   gout ~ dnorm(sh,ra)
    #   sh <- pow(m,2) / pow(sd,2)
    #    ra <- m/pow(sd,2)
    #   m  <- 0.1
    #   sd <- 1 
    
    }', file={f <- tempfile()})
######################################################################
# n.adapt:  number of iterations in the chain for adaptation (n.adapt) 
#           [JAGS will use to choose the sampler and to assure optimum 
#           mixing of the MCMC chain; will be discarded] 
# n.udpate: number of iterations for burnin; these will be discarded to 
#           allow the chain to converge before iterations are stored
# n.iter:   number of iterations to store in the final chain as samples 
#           from the posterior distribution 
# n.chains: number of mcmc chains
# n.thin:   store every n.thin element [=1 keeps all samples]

n.burnin  <- 7000   
n.iter   <- 15000  
n.chains <- 4
n.thin   <- 5
inits <- function () { list(e1 = runif(1,0.1,0.75),gin=runif(1,2,10),gout=runif(1,0.01,1)) }
# "f": is the model specification from above; 
# data = list(...): define all data elements that are referenced in the 



# JAGS model with R2Jags;
out <- jags(data = model.data,
            inits = inits,
            parameters = c("e1", "gin", "gout","mux"),
            model.file = f,
            n.thin = n.thin,
            n.chains = n.chains,
            n.burnin = n.burnin,
            n.iter = n.iter)


traplot(out ,c("e1", "gin", "gout"),style="plain")
denplot(out ,c("e1", "gin", "gout"),style="plain")


# Plot
y <- jagsresults(x=out, params=c('mux'),probs=c(0.005,0.025, 0.25, 0.5, 0.75, 0.975,0.995))
x <- xx
gdata <- data.frame(x =xx, mean = y[,"mean"],lwr1=y[,"25%"],lwr2=y[,"2.5%"],lwr3=y[,"0.5%"],upr1=y[,"75%"],
                    upr2=y[,"97.5%"],upr3=y[,"99.5%"])
gobs <- data.frame(obsx1,obsy1,errobsy1)



ggplot(gobs,aes(x=obsx1,y=obsy1))+
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr3, ymax=upr3,y=NULL), fill=c("#BF9663"),show.legend=FALSE) +
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr2, ymax=upr2,y=NULL), alpha=0.75, fill = c("#7BA696"),show.legend=FALSE) +
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr1, ymax=upr1,y=NULL), alpha=0.45, fill=c("#2D5873"),show.legend=FALSE) +
  geom_point()+
  geom_errorbar(data=gobs,mapping=aes(x=obsx1,y=obsy1,ymin=obsy1-errobsy1,ymax=obsy1+errobsy1),alpha=0.85,
                colour="#dd0100",width=0.005)+
  geom_line(data=gdata,aes(x=xx,y=mean),colour="#ffffff",linetype="dashed",size=1,show.legend=FALSE)+
  theme_wsj() + xlab("Energy (MeV)") + ylab("S-Factor (MeV b)") + scale_x_log10()  +
  theme(legend.position = "none",
        plot.background = element_rect(colour = "white", fill = "white"),
        panel.background = element_rect(colour = "white", fill = "white"),
        legend.key = element_rect(colour = "white", fill = "white"),
        axis.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=15),
        axis.text  = element_text(size=12),
        strip.text = element_text(size=10),
        strip.background = element_rect("gray85")) +
  ggtitle(expression(paste(NULL^"3","He(d,p)",NULL^"4","He")))