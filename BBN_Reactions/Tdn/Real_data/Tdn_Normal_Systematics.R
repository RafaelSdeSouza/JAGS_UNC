# 3Hedp analysis
#
# purpose: Real  DATA
#
# - 3 parameters are assumed: Er, gamma_d^2, gamma_n^2 [e1, gin, gout]
#
# - uses the function sfactorTdn_fast(obsx1[i], e1, gin, gout), which
#   is a C++ version of a Fortran code that includes Coulomb wave
#   function calculations; JAGS has been recompiled with this C++ function
#
######################################################################
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
library(rjags);library(R2jags);library(mcmcplots)
require(RcppGSL);require(ggplot2);require(ggthemes)
require(nuclear);library(magrittr)
library(dplyr);require(ggsci)
source("https://raw.githubusercontent.com/johnbaums/jagstools/master/R/jagsresults.R")
## for block updating [we do not need to center predictor variables]
load.module("glm")
load.module("nuclear")


######################################################################
## Read DATA GENERATION
#ensamble <- read.csv("ensamble.csv",header = T,stringsAsFactors=FALSE)  %>%
#  mutate(Stat=replace(Stat,Stat==0,0.1)) %>%
#  mutate(dat=replace(dat,dat %in% c("gei99b","gei99d"),"Gei99")) %>%
#  mutate(dat=replace(dat,dat %in% c("Kra87m","Kra87b"),"Kra87")) %>%
#  mutate(dat=replace(dat,dat == "zhi77b","Zhi77")) %>%
 # filter(.,dat!="Lac05")  %>% droplevels(.) %>%
 # mutate(dat=as.factor(dat))

ensamble <- read.csv("ensamble_Tdn.csv",header = T) 

re <- as.numeric(ensamble$dat)
Nre <- length(unique(ensamble$dat))

# Radius
# r_i = 6
# r_f = 5

# Literature
#  0.35779   # resonance energy
#  1.0085    # reduced width incoming
#  0.025425   # reduced width outgoing


N <- nrow(ensamble)
obsy <- ensamble$S    # Response variable
obsx <-  ensamble$E   # Predictors
erry <- ensamble$Stat
set <- ensamble$dat
syst = unique(ensamble$Syst)
#syst <- syst[-3]

M <- 500
xx <- exp(seq(log(min(obsx)),log(max(obsx)),length.out = M))




model.data <- list(obsy = obsy,    # Response variable
                   obsx =  obsx,   # Predictors
                   erry = erry,
                   N = nrow(ensamble), # Sample size
                   syst = syst,
                   Nre = Nre,
                   re = re,
                   M = M,
                   xx = xx
)


######################################################################
Model <- "model{
# LIKELIHOOD
for (i in 1:N) {
obsy[i] ~ dnorm(y[i], pow(erry[i], -2))
y[i] ~ dnorm(scale[re[i]]*sfactorTdn(obsx[i], e1, gin, gout, ri, rf,0),pow(tau, -2))
}

# Predicted values

for (j in 1:M){
mux[j] <- sfactorTdn(xx[j], e1, gin, gout, ri, rf,0)
yx[j] ~ dnorm(mux[j],pow(tau,-2))
}



for (k in 1:Nre){
scale[k] ~ dlnorm(log(1.0),pow(log(1+syst[k]),-2))
}


# PRIORS
# e1, gin, gout are defined as in tdn.f (by Alain Coc):
# resonance energy, initial reduced width, final reduced
# width;

ri ~ dunif(2,8)
rf ~ dunif(2,8)

tau ~  dgamma(0.01,0.01)
e1 ~   dunif(0,10)
gin ~ dgamma(0.01,0.01)
gout ~ dgamma(0.01,0.01)


}"


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


inits <- function () { list(e1 = runif(1,0.15,1),gin=runif(1,1,5),gout=runif(1,0.01,1)) }
# "f": is the model specification from above;
# data = list(...): define all data elements that are referenced in the



# JAGS model with R2Jags;
Normfit <- jags(data = model.data,
                inits = inits,
                parameters = c("e1", "gin", "gout","tau","mux","yx","scale","ri","rf"),
                model = textConnection(Model),
                n.thin = 10,
                n.chains = 10,
                n.burnin = 2000,
                n.iter = 4000)


jagsresults(x=Normfit , params=c("e1", "gin", "gout","tau","ri","rf"),probs=c(0.005,0.025, 0.25, 0.5, 0.75, 0.975,0.995))


traplot(Normfit  ,c("e1", "gin", "gout","ri","rf"),style="plain")
denplot(Normfit  ,c("e1", "gin", "gout","ri","rf"),style="plain")
caterplot(Normfit,c("scale","tau"),style="plain")



# Plot
y <- jagsresults(x=Normfit , params=c('mux'),probs=c(0.005,0.025, 0.25, 0.5, 0.75, 0.975,0.995))
x <- xx
gdata <- data.frame(x =xx, mean = y[,"mean"],lwr1=y[,"25%"],lwr2=y[,"2.5%"],lwr3=y[,"0.5%"],upr1=y[,"75%"],
                    upr2=y[,"97.5%"],upr3=y[,"99.5%"])
gobs <- data.frame(obsx,obsy,erry,set)
gobs$set <- as.factor(gobs$set)


ggplot(gobs,aes(x=obsx,y=obsy))+
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr3, ymax=upr3,y= NULL),alpha=0.7,fill=c("gray70"),show.legend=FALSE)+
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr2, ymax=upr2,y=NULL),alpha=0.6,  fill = c("gray50"),show.legend=FALSE) +
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr1, ymax=upr1,y=NULL),alpha=0.4,fill=c("gray30"),show.legend=FALSE) +
  geom_point(data=gobs,aes(x=obsx,y=obsy,group=set,color=set,shape=set),size=2)+
  geom_errorbar(data=gobs,aes(x=obsx,y=obsy,ymin=obsy-erry,ymax=obsy+erry,group=set,color=set),width=0.005)+
  geom_line(data=gdata,aes(x=xx,y=mean),colour="white",linetype="dashed",size=1,show.legend=FALSE)+
  scale_colour_futurama(name="Dataset")+
  scale_shape(name="Dataset")+
  theme_wsj() + xlab("Energy (MeV)") + ylab("S-Factor (MeV b)") + scale_x_log10()  +
  theme(legend.position = "top",
        legend.background = element_rect(colour = "white", fill = "white"),
        plot.background = element_rect(colour = "white", fill = "white"),
        panel.background = element_rect(colour = "white", fill = "white"),
        legend.key = element_rect(colour = "white", fill = "white"),
        axis.title = element_text(family = "Trebuchet MS", color="#666666", face="bold", size=15),
        axis.text  = element_text(size=12),
        strip.text = element_text(size=10),
        strip.background = element_rect("gray85")) +
  ggtitle(expression(paste("t(d,n)",NULL^"4","He")))
