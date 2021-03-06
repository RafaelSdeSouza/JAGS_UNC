plot_Sfactor <- function(Normfit){

# Plot

y <- jagsresults(x=Normfit , params=c('mux1'),probs=c(0.0015,0.025, 0.16, 0.5, 0.84, 0.975,0.9985))




x <- xx
gdata <- data.frame(x =xx, mean = y[,"mean"],lwr1=y[,"16%"],lwr2=y[,"2.5%"],lwr3=y[,"0.15%"],upr1=y[,"84%"],
                    upr2=y[,"97.5%"],upr3=y[,"99.85%"])
gobs <- data.frame(obsx,obsy,erry,set,lab)
gobs$set <- as.factor(gobs$set)



y2 <- jagsresults(x=Normfit , params=c('mux2'),probs=c(0.0015,0.025, 0.16, 0.5, 0.84, 0.975,0.9985))
gdata2 <- data.frame(x =xx, mean = y2[,"mean"],lwr1=y2[,"16%"],lwr2=y2[,"2.5%"],lwr3=y2[,"0.15%"],upr1=y2[,"84%"],
                     upr2=y2[,"97.5%"],upr3=y2[,"99.85%"])


y0 <- jagsresults(x=Normfit , params=c('mux0'),probs=c(0.0015,0.025, 0.16, 0.5, 0.84, 0.975,0.9985))

gdata0 <- data.frame(x =xx, mean = y0[,"mean"],lwr1=y0[,"16%"],lwr2=y0[,"2.5%"],lwr3=y0[,"0.15%"],upr1=y0[,"84%"],
                     upr2=y0[,"97.5%"],upr3=y0[,"99.85%"])



gg <- ggplot(gobs,aes(x=obsx,y=obsy))+
  geom_rect(aes(xmin=0.045, xmax=0.356, ymin=-1, ymax=22), fill="gray90",alpha=0.4) +


  # red
  #  geom_ribbon(data=gdata2,aes(x=xx,ymin=lwr3, ymax=upr3,y= NULL),fill=c("#fdd0a2"),show.legend=FALSE)+
  geom_ribbon(data=gdata2,aes(x=xx,ymin=lwr2, ymax=upr2,y=NULL),  fill = c("#fdae6b"),show.legend=FALSE) +
  geom_ribbon(data=gdata2,aes(x=xx,ymin=lwr1, ymax=upr1,y=NULL),fill=c("#d94801"),show.legend=FALSE) +

  #  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr3, ymax=upr3,y= NULL),fill=c("#B1BBCF"),show.legend=FALSE)+
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr2, ymax=upr2,y=NULL),  fill = c("gray70"),show.legend=FALSE) +
  geom_ribbon(data=gdata,aes(x=xx,ymin=lwr1, ymax=upr1,y=NULL),fill=c("gray30"),show.legend=FALSE) +

  #  Bare
  #  geom_ribbon(data=gdata0,aes(x=xx,ymin=lwr3, ymax=upr3,y= NULL),fill=c("#dadaeb"),show.legend=FALSE)+
  geom_ribbon(data=gdata0,aes(x=xx,ymin=lwr2, ymax=upr2,y=NULL),  fill = c("#9e9ac8"),show.legend=FALSE) +
  geom_ribbon(data=gdata0,aes(x=xx,ymin=lwr1, ymax=upr1,y=NULL),fill=c("#984ea3"),show.legend=FALSE) +
  #
  #

  geom_point(data=gobs,aes(x=obsx,y=obsy,group=set,color=set,shape=set),size=2.75,alpha=0.75)+
  geom_errorbar(show.legend=FALSE,data=gobs,aes(x=obsx,y=obsy,ymin=obsy-erry,ymax=obsy+erry,group=set,color=set),
                width=0.01,alpha=0.4)+
  #  geom_line(data=gdata,aes(x=xx,y=mean),linetype="dashed",size=0.75,show.legend=FALSE)+
  #  geom_line(data=gdata2,aes(x=xx,y=mean),linetype="dashed",size=0.75,show.legend=FALSE)+
  scale_colour_manual(name="",values=c("black","#7f0000","#7f0000","black","black",
                                       "black","black"))+
  scale_shape_manual(values=c(0,19,8,10,4,17,3),name="")+
  coord_cartesian(xlim=c(4.7e-3,0.6),ylim=c(0.2,19)) +
  theme_bw() + 
  xlab("Energy (MeV)") + 
  ylab("S-Factor (MeV b)") +
  scale_x_log10(breaks = c(0.001,0.01,0.1,1),labels=c("0.001","0.01","0.1","1"))  +
#annotation_logticks(short = unit(0.2, "cm"), mid = unit(0.25, "cm"), long = unit(0.3, "cm"),
#                      sides = "b",size = 0.45) +
# annotation_logticks(base=2.875,
#  short = unit(0.2, "cm"), mid = unit(0.25, "cm"), long = unit(0.3, "cm"),sides = "l",size = 0.45) +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.position = c(0.925,0.7),
        legend.background = element_rect(colour = "white", fill = "white"),
        legend.text = element_text(size=14,colour = set),
        plot.background = element_rect(colour = "white", fill = "white"),
        panel.background = element_rect(colour = "white", fill = "white"),
        legend.key = element_rect(colour = "white", fill = "white"),
        axis.title = element_text(size=22),
        axis.text  = element_text(size=18),
        axis.ticks = element_line(size = 0.45),
#        axis.line = element_line(size = 0.45, linetype = "solid"),
      axis.text.y = element_text(size = 20, margin = unit(c(t = 0, r = 5, b = 0, l = 0), "mm")),
  #axis.text.x = element_text(size = 20, margin = unit(c(t = 5, r = 0, b = 0, l = 0), "mm")),
        axis.ticks.length = unit(-3, "mm"),
axis.title.x=element_blank(),
axis.text.x=element_blank(),
axis.ticks.x=element_blank()) 


return(gg)
}
