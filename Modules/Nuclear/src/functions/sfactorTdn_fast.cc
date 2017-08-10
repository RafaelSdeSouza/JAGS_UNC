#include "sfactorTdn_fast.h"#include <config.h>#include <cmath>// isScalar()#include <util/dim.h>const double cs_pi = 0.31415926535897932384626433832795028e+01;const double cs_2pi = 2.e0*cs_pi;using std::vector;namespace jags {namespace nuclear {/** * @short Matrix- or array-valued function * * Array-valued functions are the most general class of function. The * arguments of an array-valued function, and the value may be a * scalar, vector, or array. * * We use ArrayFunction here because there is no more specific class * that accepts scalars and returns vectors */  //to change number of parameters, sfactorTdn_fast::sfactorTdn_fast() : ArrayFunction("sfactorTdn_fast",4)    {    }/** * Evaluates the function. * * @param value array of doubles which contains the result of * the evaluation on exit * @param args Vector of arguments. * @param dims Respective dimensions of each element of args. */ // TODO :make this run with different r_i, r_f as input valuesvoid sfactorTdn_fast::evaluate (double *value, 			std::vector<double const *> const &args,			std::vector<std::vector<unsigned int> > const &dims) const{		//here E is the observed energy (i.e. obsx1)	double E  = args[0][0];	//int length = dims[0].size();	// for(int i=0; i<length; i++) E[i] = args[0][i];	// parameters to be tested    double e1 = args[1][0];    double gi = args[2][0];    double gf = args[3][0];        //TODO: make E an entire vector, so that all Es are calculate at once        //these are some parameters	//their meanings are shrouded in mystery	double hm = 20.9;	double ai=6, af=5;	//initial and final angular momenta	double li=0, lf=2;	//initial atomic mass, nuclear charge, target and projectile	double a1i=3, a2i=2, z1i=1, z2i=1;	//final atomic mass, nuclear charge, target and projectile	double a1f=4, a2f=1, z1f=2, z2f=0;	//Q-factor (energy gained in reaction)	double q = 17.59;		//these calculations seem like they can be combined into a single one	double rmui = a1i*a2i/(a1i+a2i);	double rmuf = a1f*a2f/(a1f+a2f);	double hmi = hm/rmui;	double hmf = hm/rmuf;	//float eta0i = 1.44*z1i*z2i/(2*hmi);	//float eta0f = 1.44*z1f*z2f/(2*hmf);	double eta0i = 1.44*z1i*z2i/( 2*hmi );	double eta0f = 1.44*z1f*z2f/( 2*hmf );        //calculate some more stuff	double xki=sqrt(e1/hmi);    double xkf=sqrt((e1+q)/hmf);    double pli, plf, bi, bf;        //now we call coul(), which calculates coulomb barrier    //the output is to be stored in  pl1, bi, plf, bf    coul(li, xki*ai, eta0i/xki, pli, bi);    coul(lf, xkf*af, eta0f/xkf, plf, bf);        	//open(unit=11,file='tdn.out',status='unknown')		//open(unit=12,file='tdn.in',status='unknown')	        double si, sf;    double gitot, gftot, del, sdp2, sigma;        //for all energies    //for(int i = 0; i<length; i++){				//calculate based on tested energy		xki=sqrt(E/hmi);		xkf=sqrt((E+q)/hmf);		//find the coulomb barrier		coul(li,xki*ai,eta0i/xki,  pli,si);		coul(lf,xkf*af,eta0f/xkf,  plf,sf);		gitot=2*gi*pli;	//incoming width		gftot=2*gf*plf;	//outgoing width				del=-gi*(si-bi)-gf*(sf-bf);		sdp2=gitot*gftot/( pow(e1+del-E, 2)+0.25*pow(gitot+gftot,2) );		sigma = 0.02*cs_pi*sdp2/(3.0*xki*xki);		value[0] = sigma * exp(cs_2pi*eta0i/xki) * E;    //}        //TODO: Get this to output VECTORS and not just single elements    }void sfactorTdn_fast::coul(int MAXL, double RHO, double ETA, double& pl,double &sl) const {	double FC, GC, FCP, GCP;	int MINL = MAXL;	double K,K1,K2,K3,K4,M1,M2,M3,M4, H;	double W, G, GP, F, FP, TF, TFP;	double ETAR;	double PL, PMX;	double D, DEL;	double P, Q, AR, AI, BR, BI, WI, DR, DI, DP, DQ, T;	double H2, R3, ETAH, H2LL, S, RH2, RH;	int I2;			//original code doubly-defined these in two variables for no reason	double ACC= 1.0e-7, PACE=100.0e0;	//RHO is used again only once later.  Not sure if mistake	double R = RHO; 	//KTR is a kind of flag, and I'm not sure what it's for	bool KTR = false; 	int LMAX = MAXL; //LMAX and MAXL may not both be necessary	int LMIN1 = MINL+1;  	double XLL1 = MINL*LMIN1;	double ETA2 = ETA*ETA; 	double TURN = ETA+sqrt(ETA2+XLL1);	if(R < TURN & fabs(ETA) >= 1.e-6) KTR = true;	bool KTRP = KTR;	//I don't think KTRP is necssary by itself	//I can't find a pretty way to get rid of a goto leading here	//you will see this at the if(KTRP=-1) @ line 216	theBeginning:	PL = LMAX+1.0e0;	PMX = PL+0.5e0;  	while(true){		ETAR = ETA*R;		if(PL*PL+PL+ETAR != 0.0) break;		R = R*1.0000001e0; 	}	//calculation of FP, K moved below	F = 1;	FP = ETA/PL+PL/R + DEL;	K = (PL*PL-PL+ETAR)*(PL+PL-1);	D   = 0.0;	DEL = 0.0;			//partThree	do {		H = (PL*PL+ETA2)*(1-PL*PL)*R*R;		K = K + ETAR+ETAR + PL*PL*6.0;		D = 1.0/(D*H+K); 		DEL = DEL*(D*K-1.0);		if(PL < PMX) DEL = -R*(PL*PL+ETA2)*(PL+1)*D/PL;		PL = PL+1.0; 		FP = FP+DEL;		if (D < 0.0) F = -F;	//apparently F keeps track of signs?		if (PL > 20000.0e0) goto partEleven;	} while (fabs(DEL/FP) >= ACC); //originaly an if with goto top	FP = F*FP;        	if (KTRP){		//the following statements were at the GO TO		R = TURN;		//this seems to be the only thing worth caring about		TF = F;					TFP = FP;				LMAX = MINL; 	//this is already true, but interesting anyway		KTRP = false;	//this ensures this won't happen again		//the code then continued and repeated everything else				goto theBeginning;	}			P = 0;	Q = R-ETA;	PL = 0;	AR = -(ETA2+XLL1);	AI = ETA;	BR = Q+Q;	BI = 2;	//WI = ETA+ETA; seems unnecessary	DR = BR/(BR*BR+BI*BI); 	DI = -BI/(BR*BR+BI*BI);	DP = -(AR*DI+AI*DR);	DQ = AR*DR-AI*DI;      		//partSix:	do {		//these variables increase simply      	P = P+DP;      	Q = Q+DQ;      	PL = PL+2.0;      	AR = AR+PL;      	AI = AI + ETA + ETA; //+WI;      	BI = BI+2.0;      	//      	      	//more complicated update      	D = AR*DR-AI*DI+BR;      	DI = AI*DR+AR*DI+BI;       	T = 1.0/(D*D+DI*DI);      	DR = T*D;      	DI = -T*DI;      	H = BR*DR-BI*DI-1;      	K = BI*DR+BR*DI;      	T = DP*H-DQ*K;      	DQ = DP*K+DQ*H;        	DP = T;      	if(PL > 46000.0e0) goto partEleven;	} while(fabs(DP)+fabs(DQ) >= (fabs(P)+fabs(Q))*ACC);// goto partSix;      	     		P = P/R;	Q = Q/R;	G = (FP-P*F)/Q;  		//note, we had to recalculate FP to get G, GP, W	GP = P*G-Q*F;	W = 1.0/sqrt(FP*G-F*GP); //there is a squareroot here, but not later...	G = W*G; 	GP = W*GP; 	if (KTR){ //originally if(!KTR) goto partEight; which would skip all this		//recall original F, FP values		F = TF;		FP = TFP;				//return LMAX to full range (we don't need to do this...		LMAX = MAXL; 		//now we calculate... stuff...		if(RHO < 0.2e0*TURN) PACE = 999.0e0;		R3=1.0e0/3.0e0;  		H = (RHO-TURN)/(PACE+1.0); 		H2 = H/2.0;		//this seems really, really dumb		I2 = int(PACE+0.001e0);  //I2 = INT(PACE+0.001D0)		ETAH = ETA*H;		H2LL = H2*XLL1;		S = (ETAH+H2LL/R)/R-H2;      			//partSeven:		//this can be simplified to fewer variables with algebra		do {  	    	RH2 = R+H2;		//= R + 0.5*H  		  	T = (ETAH+H2LL/RH2)/RH2-H2;//= (ETA*H + 0.5*H*XLL1/(R+0.5H))/(R+0.5H) - 0.5H 			K1 = H2*GP; //=0.5*H*GP			M1 = S*G;				K2 = H2*(GP+M1); //=0.5*H*GP + 0.5*H*S*G			M2 = T*(G+K1); //=T*G + T*0.5*H*GP			K3 = H*(GP+M2); //=H*GP + H*T*G + H*T*0.5*H*GP 			M3 = T*(G+K2); //=T*G+ T*0.5*H*GP + T*0.5*H*S*G			M3 = M3+M3; //=2*T*G + T*H*GP + T*H*S*G			K4 = H2*(GP+M3); //=0.5*H*GP + 0.5*H*2*T*G + 0.5*H*T*H*GP + 0.5*H*T*H*S*G			RH = R+H;			S = (ETAH+H2LL/RH)/RH-H2; //=Z			M4 = S*(G+K3); //=Z*G + Z*H*GP + Z*H*T*G + Z*H*T*0.5*H*GP			G = G+(K1+K2+K2+K3+K4)*R3;			//=G + 0.5*H*(GP + GP + S*G + 2*GP + 2*T*G + T*H*GP + GP + 2*T*G + T*H*GP + T*H*S*G)*R3			//=G + 0.5*H*(5.0*GP + S*G + 4*T*G + 2.0*T*H*GP + T*H*S*G)*R3			//G + G*(0.5*H*S + 0.5*H*$*T + 0.5*H*T*S*S)*R3 + GP*(5 + 2.0*T*H)*R3			GP = GP+(M1+M2+M2+M3+M4)*R3;			//=GP+ (S*G + T*G + T*0.5*H*GP +  2*T*G + T*H*GP + T*H*S*G + Z*G + Z*H*GP + Z*H*T*G + Z*H*T*0.5*H*GP )			//=GP+ G*(S + T+ 2*T + T*H*S + Z + Z*H*T)*R3 + GP*(0.5*H*T + T*H + Z*H + Z*H*T*0.5*H)*R3			R = RH;			I2 = I2-1; 			if(fabs(GP) > 1.e35) goto partEleven;       	} while(I2 >= 0);  //if(I2 >= 0) goto partSeven;        	//here.  this is the only statement needing initial F, FP   		W = 1.0/(FP*G-F*GP);	} //endif	//this means we end properly	//partEight:	GC = G;	GCP = GP;     FC  = W*F;    FCP = W*FP;    pl=RHO/( pow(FC,2) + pow(GC,2) );    sl=pl*( FC*FCP + GC*GCP );    return;          //end early due to overflow    //several places where this could happen: parts three, six, seven    partEleven:      	//W = 0; G = 0; GP = 0;  //all variables go to zero      	 FC = 0;	GC = 0;      	FCP = 0;	GCP = 0;        pl=RHO/( pow(FC,2) + pow(GC,2) );    	sl=pl*( FC*FCP + GC*GCP );      	return;    	} /** * Checks whether dimensions of the function parameters are correct. * * @param dims Vector of length npar denoting the dimensions of * the parameters, with any redundant dimensions dropped. */bool sfactorTdn_fast::checkParameterDim(std::vector<std::vector<unsigned int> > const &dims) const {    //the first argument should be a vector    // the last three arguments should be scalars    return isScalar(dims[0])&& isScalar(dims[1]) && isScalar(dims[2]) && isScalar(dims[3]);}/** * Checks whether the parameter values lie in the domain of the * function. The default implementation returns true. */bool sfactorTdn_fast::checkParameterValue(std::vector<double const *> const &args,                             std::vector<std::vector<unsigned int> > const &dims) const{        // TODO: should any parameters be eg strictly positive?        return true;}/** * Calculates what the dimension of the return value should be, * based on the arguments. * * @param dims Vector of Indices denoting the dimensions of the     * parameters. This vector must return true when passed to     * checkParameterDim.     *     * @param values Vector of pointers to parameter values.     */std::vector<unsigned int> sfactorTdn_fast::dim(std::vector <std::vector<unsigned int> > const &dims,                 std::vector <double const *> const &values) const {        // the size of the table that the fortran code calculates is length of E (input)        vector<unsigned int> ans(1);                ans[0] = 1;        return ans;}}} //end namespaces