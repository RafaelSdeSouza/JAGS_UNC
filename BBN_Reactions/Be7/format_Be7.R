# Read Dpg
require(ggplot2);require(ggthemes);require(dplyr);require(magrittr)

# Data of interest

## DATA SET 1: damone 2018;
##             includes 7Li ground and first excited state
obsx1    <- c( 1.7909E-08, 2.8383E-08, 4.4985E-08, 7.1296E-08, 1.1300E-07,
               1.7909E-07, 2.8383E-07, 4.4985E-07, 7.1296E-07, 1.1300E-06,
               1.7909E-06, 2.8383E-06, 4.4985E-06, 7.1296E-06, 1.1300E-05,
               1.7909E-05, 2.8383E-05, 4.4985E-05, 7.1296E-05, 1.1300E-04,
               1.7909E-04, 2.8383E-04, 4.4985E-04, 7.1296E-04, 1.1300E-03,
               1.7909E-03, 2.8383E-03, 4.4985E-03, 7.1296E-03, 1.1300E-02,
               1.7909E-02, 2.8383E-02 )
obsy1    <- c( 7.8092E+00, 7.8195E+00, 7.7802E+00, 7.7661E+00, 7.6519E+00,
               7.5714E+00, 7.5733E+00, 7.6167E+00, 7.5710E+00, 7.4976E+00,
               7.5745E+00, 7.5757E+00, 7.6668E+00, 7.5095E+00, 7.7362E+00,
               7.4136E+00, 7.7286E+00, 7.6756E+00, 7.5196E+00, 7.8341E+00,
               7.5144E+00, 7.2445E+00, 6.9702E+00, 6.8301E+00, 7.0019E+00,
               5.6533E+00, 5.3962E+00, 4.9763E+00, 5.1530E+00, 3.5495E+00,
               3.4931E+00, 3.8298E+00 )
errobsy1 <- c( 2.7114E-02, 1.6001E-02, 1.5102E-02, 1.7252E-02, 2.4333E-02,
               3.6717E-02, 4.5931E-02, 5.2407E-02, 5.9494E-02, 6.6445E-02,
               7.4939E-02, 8.3775E-02, 9.3976E-02, 1.0263E-01, 1.1767E-01,
               1.2603E-01, 1.4380E-01, 1.5864E-01, 1.7379E-01, 1.9866E-01,
               2.1469E-01, 2.5093E-01, 2.5641E-01, 2.7691E-01, 3.1250E-01,
               2.9929E-01, 3.3142E-01, 3.3659E-01, 3.9149E-01, 3.2201E-01,
               3.2915E-01, 4.1614E-01 )

Dam18 <- data.frame(obsx1,obsy1,errobsy1) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Dam18") %>%
  mutate(.,type="rel")


## DATA SET 2: gibbons & macklin 1959; data with Eplab>2371 keV excluded;
##             also excluded data below Encm=0.01 MeV; use relativistic
##             results;
##             includes only 7Li ground state
obsx2    <- c( 1.331079E-02, 1.855621E-02, 2.467585E-02,
               3.516666E-02, 4.478322E-02, 5.614824E-02, 6.663900E-02,
               7.800398E-02, 8.762049E-02, 9.374008E-02, 1.051050E-01,
               1.173442E-01, 1.278348E-01, 1.365771E-01, 1.496904E-01,
               1.636779E-01, 1.750427E-01, 1.942755E-01, 2.152566E-01,
               2.327408E-01, 2.467282E-01, 2.598413E-01, 2.720802E-01,
               2.729544E-01, 2.825707E-01, 2.948095E-01, 3.079225E-01,
               3.201614E-01, 3.324001E-01, 3.463873E-01, 3.551293E-01,
               3.708648E-01, 3.831035E-01, 3.970906E-01, 4.206937E-01 )
obsy2    <- c( 3.403512E+00, 3.025938E+00, 2.718642E+00,
               2.372191E+00, 2.154046E+00, 1.929502E+00, 1.795300E+00,
               1.670390E+00, 1.579014E+00, 1.537671E+00, 1.445473E+00,
               1.393007E+00, 1.342572E+00, 1.348650E+00, 1.302343E+00,
               1.286430E+00, 1.282212E+00, 1.300835E+00, 1.370100E+00,
               1.470022E+00, 1.480242E+00, 1.616691E+00, 1.663510E+00,
               1.698281E+00, 1.815184E+00, 1.906191E+00, 1.965685E+00,
               2.009236E+00, 1.967049E+00, 1.927036E+00, 1.787446E+00,
               1.703345E+00, 1.581327E+00, 1.505659E+00, 1.320614E+00 )
errobsy2 <- c( 3.403512E-02, 3.025938E-02, 2.718642E-02,
               2.372191E-02, 2.154046E-02, 1.929502E-02, 1.795300E-02,
               1.670390E-02, 1.579014E-02, 1.537671E-02, 1.445473E-02,
               1.393007E-02, 1.342572E-02, 1.348650E-02, 1.302343E-02,
               1.286430E-02, 1.282212E-02, 1.300835E-02, 1.370100E-02,
               1.470022E-02, 1.480242E-02, 1.616691E-02, 1.663510E-02,
               1.698281E-02, 1.815184E-02, 1.906191E-02, 1.965685E-02,
               2.009236E-02, 1.967049E-02, 1.927036E-02, 1.787446E-02,
               1.703345E-02, 1.581327E-02, 1.505659E-02, 1.320614E-02 )


Gib59 <- data.frame(obsx2,obsy2,errobsy2) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Gib59")  %>%
  mutate(.,type="rel")



## DATA SET 3: martin-hernandez 2018; absolute pn cross directly obtained
##             from author; converted to np using relativistic kinematics;
##             data below Encm=0.002 MeV are excluded because uncertainty
##             in 7Be mass impacts results;
##             includes only 7Li ground state
obsx3    <- c( 2.183971E-03, 2.385885E-03, 2.592686E-03,
               2.804365E-03, 3.020310E-03, 3.240364E-03, 3.463872E-03,
               3.690902E-03, 3.921238E-03, 4.154371E-03, 4.390563E-03,
               4.628933E-03, 4.869689E-03, 5.112692E-03, 5.357338E-03,
               5.603375E-03, 5.851169E-03, 6.100352E-03, 6.350480E-03,
               6.601578E-03, 6.853464E-03, 7.105873E-03, 7.359096E-03,
               7.612747E-03, 7.866494E-03, 8.120285E-03, 8.374636E-03,
               8.629143E-03, 8.882742E-03, 9.389572E-03  )
obsy3    <- c( 5.595375E+00, 5.456809E+00, 5.305795E+00,
               5.207356E+00, 5.052560E+00, 5.175160E+00, 4.925496E+00,
               4.805613E+00, 4.939230E+00, 5.024024E+00, 4.971533E+00,
               5.005326E+00, 4.567042E+00, 4.611864E+00, 4.691854E+00,
               4.420279E+00, 4.222387E+00, 4.694943E+00, 4.354219E+00,
               4.726389E+00, 4.137051E+00, 4.456333E+00, 4.135836E+00,
               4.159703E+00, 3.942435E+00, 4.362248E+00, 4.143442E+00,
               4.424349E+00, 4.026532E+00, 3.879684E+00  )
errobsy3 <- c( 8.382935E-02, 8.384005E-02, 8.433243E-02,
               8.552457E-02, 8.472940E-02, 9.031378E-02, 9.017204E-02,
               9.020569E-02, 9.367794E-02, 9.723094E-02, 9.851541E-02,
               1.041874E-01, 9.891482E-02, 1.026130E-01, 1.093601E-01,
               1.108938E-01, 1.076231E-01, 1.255085E-01, 1.199439E-01,
               1.345929E-01, 1.259839E-01, 1.447373E-01, 1.365988E-01,
               1.435971E-01, 1.551009E-01, 1.652441E-01, 1.539148E-01,
               1.872132E-01, 1.951334E-01, 1.964327E-01  )



Mar19 <- data.frame(obsx3,obsy3,errobsy3) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Mar19")  %>%
  mutate(.,type="rel")


## DATA SET 4: koehler 1988; for energies below 8e-5 MeV [constant reduced
##             cross section] data have been rebinned by adding 5 data points
##             and calculating weighted mean;
##             includes 7Li ground and first excited state

obsx4    <- c( 2.608865E-08, 3.456921E-08, 4.784085E-08, 6.119992E-08,
               7.321259E-08, 8.924697E-08, 1.108593E-07, 1.416341E-07,
               1.872718E-07, 2.552911E-07, 3.168407E-07, 3.888818E-07,
               4.887251E-07, 6.331569E-07, 8.503292E-07, 1.206513E-06,
               1.550981E-06, 1.734581E-06, 1.949655E-06, 2.208443E-06,
               2.521437E-06, 2.907871E-06, 3.390476E-06, 4.002475E-06,
               4.794577E-06, 5.854210E-06, 7.303774E-06, 9.377577E-06,
               1.243233E-05, 1.533495E-05, 1.829003E-05, 2.224180E-05,
               2.757494E-05, 3.509378E-05, 4.619720E-05, 6.356049E-05,
               9.279657E-05, 1.197770E-04, 1.320170E-04, 1.460055E-04,
               1.626169E-04, 1.827255E-04, 2.054569E-04, 2.343083E-04,
               2.684054E-04, 3.103710E-04, 3.637024E-04, 4.327709E-04,
               5.219479E-04, 6.425992E-04, 8.104618E-04, 1.057884E-03,
               1.425084E-03, 2.037083E-03, 3.138682E-03, 5.473022E-03,
               1.180284E-02 )
obsy4    <- c( 5.882701E+00, 5.757024E+00, 5.684058E+00, 5.719731E+00,
               5.695627E+00, 5.733079E+00, 5.664370E+00, 5.627097E+00,
               5.674665E+00, 5.712598E+00, 5.710666E+00, 5.800993E+00,
               5.654563E+00, 5.751555E+00, 5.819887E+00, 5.759546E+00,
               5.691495E+00, 5.839202E+00, 5.656230E+00, 5.707883E+00,
               5.675726E+00, 5.622623E+00, 5.676084E+00, 5.655390E+00,
               5.661571E+00, 5.659802E+00, 5.656776E+00, 5.761900E+00,
               5.723593E+00, 5.629112E+00, 5.681136E+00, 5.753711E+00,
               5.692271E+00, 5.612388E+00, 5.706071E+00, 5.671267E+00,
               5.432789E+00, 5.395524E+00, 5.584074E+00, 5.509973E+00,
               5.355897E+00, 5.407040E+00, 5.461165E+00, 5.342189E+00,
               5.488332E+00, 5.267588E+00, 5.244520E+00, 5.200786E+00,
               5.300314E+00, 5.145957E+00, 4.925070E+00, 4.895033E+00,
               4.794286E+00, 4.508892E+00, 4.123362E+00, 3.713790E+00,
               3.139722E+00 )
errobsy4 <- c( 1.330698E-01, 9.837351E-02, 1.169144E-01, 5.394071E-02,
               5.390683E-02, 5.417379E-02, 5.350609E-02, 5.307900E-02,
               5.327827E-02, 5.409253E-02, 5.380607E-02, 5.454583E-02,
               5.303551E-02, 5.467026E-02, 5.500018E-02, 5.470012E-02,
               5.386171E-02, 5.568360E-02, 5.435516E-02, 5.477597E-02,
               5.647405E-02, 7.140915E-02, 7.332296E-02, 7.231835E-02,
               7.209151E-02, 7.128335E-02, 7.257372E-02, 8.851526E-02,
               9.468445E-02, 1.589130E-01, 1.632504E-01, 1.682113E-01,
               1.643368E-01, 1.583425E-01, 1.784229E-01, 1.801364E-01,
               1.570300E-01, 3.611608E-01, 3.102263E-01, 2.899986E-01,
               2.932991E-01, 3.109048E-01, 3.153429E-01, 3.061426E-01,
               3.604278E-01, 3.347297E-01, 3.432777E-01, 3.328503E-01,
               3.426927E-01, 3.041945E-01, 2.846861E-01, 2.732111E-01,
               2.491519E-01, 2.166435E-01, 1.960838E-01, 1.553577E-01,
               2.172818E-01 )

Koe88 <- data.frame(obsx4,obsy4,errobsy4) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Koe88")  %>%
  mutate(.,type="rel")



### ABSOLUTE NORMALIZATIONS:

## DATA SET 10: koehler 1988; thermal cross section
obsx10    <- c( 2.21e-8 )
obsy10    <- c( 5.708 )
errobsy10 <- c( 0.057 )


Koe88b <- data.frame(obsx10 ,obsy10 ,errobsy10 ) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Koe88b")  %>%
  mutate(.,type="abs")

## DATA SET 11: damone 2018; thermal cross section
obsx11    <- c( 2.21e-8 )
obsy11    <- c( 7.775 )
errobsy11 <- c( 0.078 )


Dam18b <- data.frame(obsx11 ,obsy11,errobsy11) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Dam18b") %>%
  mutate(.,type="abs")



## DATA SET 12: gibbons 1959; lowest-energy data point
obsx12    <- c( 9.813847E-03 )
obsy12    <- c( 3.688387E+00 )
errobsy12 <- c( 3.688387E-02 )


Gib59b <- data.frame(obsx12,obsy12,errobsy12) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Gib59b")  %>%
  mutate(.,type="abs")



## DATA SET 13: hernandez 2019; lowest-energy data point
obsx13    <- c( 1.987364E-03 )
obsy13    <- c( 5.710998E+00 )
errobsy13 <- c( 8.205219E-02 )

Her19 <- data.frame(obsx13,obsy13,errobsy13) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Her19")  %>%
  mutate(.,type="abs")



## DATA SET 14: cervena 1989; thermal cross section
obsx14    <- c( 2.21e-8 )
obsy14    <- c( 6.818 )
errobsy14 <- c( 0.068 )

Cer89 <- data.frame(obsx14,obsy14,errobsy14) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Cer89")  %>%
  mutate(.,type="abs")


## DATA SET 15: tomandl 2019; thermal cross section
obsx15    <- c( 2.21e-8 )
obsy15    <- c( 6.482 )
errobsy15 <- c( 0.091 )

Tom19 <- data.frame(obsx15,obsy15,errobsy15) %>%
  set_colnames(c("E","S","Stat")) %>%
  mutate(.,dat="Tom19")  %>%
  mutate(.,type="abs")






Be7np <- rbind(Dam18,Gib59,Mar19,Koe88,Koe88b,Dam18b,Gib59b,Her19,Cer89,Tom19)

save(Be7np, file = "Be7np.RData")


#pdf("plot/3Hedp_data.pdf",height = 7,width = 8)
ggplot(Be7np,aes(x=E,y=S,group=dat,shape=type,color=dat))+
  geom_point(size=2)+
  geom_errorbar(show.legend = FALSE,aes(x=E,y=S,ymin=S-Stat,ymax=S+Stat),width=0.025)+
  scale_shape_stata(name="Dataset")+
  scale_color_stata(name="Dataset")+
  scale_x_log10() +
  #scale_y_log10() +
  theme_bw() + ylab(expression(paste(sqrt(E), sigma, " (", sqrt(MeV), "b)"))) + 
  xlab("Energy (MeV)") + 
  theme(legend.position = "top",
        legend.background = element_rect(colour = "white", fill = "white"),
        plot.background = element_rect(colour = "white", fill = "white"),
        panel.background = element_rect(colour = "white", fill = "white"),
        legend.key = element_rect(colour = "white", fill = "white"),
        axis.title = element_text(color="#666666", size=15),
        axis.text  = element_text(size=12),
        strip.text = element_text(size=10),
        strip.background = element_rect("gray85")) +
  coord_cartesian(xlim=c(1e-8,1),ylim=c(0,10))
#dev.off()

