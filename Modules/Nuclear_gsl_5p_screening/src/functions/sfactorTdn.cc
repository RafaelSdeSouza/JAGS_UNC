#include "sfactorTdn.h"#include <config.h>#include <cmath>// isScalar()#include <util/dim.h>//from gsl#include <iostream>#include </usr/local/include/gsl/gsl_sf_exp.h>#include </usr/local/include/gsl/gsl_errno.h>#include </usr/local/include/gsl/gsl_sf_coulomb.h>#include <stdlib.h>const double cs_pi = 0.31415926535897932384626433832795028e+01;using std::vector;namespace jags {namespace nuclear {/** * @short Matrix- or array-valued function * * Array-valued functions are the most general class of function. The * arguments of an array-valued function, and the value may be a * scalar, vector, or array. * * We use ArrayFunction here because there is no more specific class * that accepts scalars and returns vectors */ // This line here tells JAGS two things://		1. the name of the fun function - "sfactorTdn"//		2. the number of parameters it takes// to change either, just change this line// new parameters added to fuction can be accessed with args[i][j] array in evaluatesfactorTdn::sfactorTdn() : ArrayFunction("sfactorTdn",7)    {    } // This is the function that actually runs when sfactorTdn is called;// note the parameters to this function are not the actual arguments given to sfactorTdn// the arguments that we give to sfactorTdn are stored instead in the args arrayvoid sfactorTdn::evaluate (double *value, 			std::vector<double const *> const &args,			std::vector<std::vector<unsigned int> > const &dims) const{	//C     -----------------------------------------------------	//C     USER INPUT; S-FACTOR IS CALCULATED FOR A SINGLE ENERGY ONLY	double E  = args[0][0];		//energy at which S-factor is to be calculated    double e1 = args[1][0];		//resonant energy    double gi = args[2][0];		//partial width of incoming channel    double gf = args[3][0];		//partial width of outgoing channel    double ri = args[4][0];		//radius of incoming channel    double rf = args[5][0];		//radius of of outgoing channel    double ue = args[6][0];		//electron screening potential	//C     -----------------------------------------------------		// gi and gf are reduced widths: \gamma^2    		//C     -----------------------------------------------------	//C     INPUT: for T(d,n)	//C     -----------------------------------------------------	double m1_i = 3.01550, m2_i = 2.01355;	//masses (amu) of t and d	double m1_f = 4.00151, m2_f = 1.008664;	//masses (amu) of n and 4He	double z1_i = 1, z2_i = 1;				//charges of t and d	double z1_f = 2, z2_f = 0;				//charges of n and 4He	//TODO: make channel radii input parameters from sfactorTdn	double jt=0.5, jp=1.0, jr=1.5;			//spins of target, projectile, resonance	double Q = 17.589293;					//reaction Q-value (MeV)	int    la = 0, lb = 2;					//orbital angular momenta of d and n		//C     ------------------------------------       	//C     DEFINITIONS	//C     ------------------------------------	double mue_i=(m1_i*m2_i)/(m1_i+m2_i);	double mue_f=(m1_f*m2_f)/(m1_f+m2_f);	double pek = 6.56618216e-1/mue_i;	double omega = (2*jr+1)/( (2*jt+1)*(2*jp+1) );	double s1, s2;	double F,FP, G,GP;	//C     ----------------------------------------------------	//C     PENETRABILITY AND SHIFT FUNCTION AT ER	//C     ----------------------------------------------------	double ga, pr_i, sr_i;	double gb, pr_f, sr_f;	//cccc  ...call PenFactor here...	//cccc  input is: er, La, m1_i, m2_i, z1_i, z2_i	//cccc  return Pr_i, Sr_i	PenFactor(e1, la, ri, mue_i, z1_i*z2_i, pr_i, sr_i);	ga=2.e0*gi*pr_i;	//cccc  ...call PenFactor here...	//cccc  input is: er+Q, Lb, m1_f, m2_f, z1_f, z2_f	//cccc  return Pr_f, Sr_f	PenFactor(e1+Q, lb, rf, mue_f, z1_f*z2_f, pr_f, sr_f);	gb=2.e0*gf*pr_f;	//C     ----------------------------------------------------	//C     CALCULATE S-FACTOR FOR EACH ENERGY	//C     ---------------------------------------------------	double etpe_i=exp( 0.98951013e0*z1_i*z2_i*sqrt(mue_i/E) );		double prat_i, p_i, s_i;	double prat_f, p_f, s_f;	double tapp;	//cccc  ...call PenFactor here...	//cccc  input is: en, La, m1_i, m2_i, z1_i, z2_i	//cccc  return P_i, S_i	PenFactor(E, la, ri, mue_i, z1_i*z2_i, p_i, s_i);	prat_i=p_i/pr_i;	//cccc  ...call PenFactor here...	//cccc  input is: en+Q, Lb, m1_f, m2_f, z1_f, z2_f	//cccc  return P_f, S_f	PenFactor(E+Q, lb, rf, mue_f, z1_f*z2_f, p_f, s_f);	prat_f=p_f/pr_f;	tapp=(s_i-sr_i)*gi+(s_f-sr_f)*gf;        // level shift	//C     ---------------------------------------------------	//C     PUTTING EVERYTHING TOGETHER	//C     ----------------------------------------------------	s1=pek*etpe_i*omega*prat_i*prat_f*ga*gb;	s2=( pow(e1-E-tapp,2) )+0.25e0*( pow(ga*prat_i+gb*prat_f,2) );	//C     ---------------------------------------------------	//C     OUTPUT	//C     ---------------------------------------------------	// we output the S-factor by storing it in value[0]	value[0] = exp( 0.5*0.98951013e0*z1_i*z2_i*sqrt(mue_i)*ue*pow(E,-1.5) )*s1/s2;}//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~// Function to calcuate the penetration factor// INPUT: E, L, Mass0, Mass1, Charge0, Charge1// OUTPUT: P, Svoid sfactorTdn::PenFactor(const double E, const double L, const double R,			const double mue,			const double qQ,			double& P, double& S) const {	// Turn off the GSL error handler, which aborts the program	// if G or F go out of range.	gsl_set_error_handler_off();	gsl_sf_result F,Fp,G,Gp;	double exp_F,exp_G;//,P,S;	double rho = 0.218735*R*sqrt(mue*E);	double eta = 0.1574854*qQ*sqrt(mue/E);	//this needs eta, rho, L	//everything above this is just to calculate eta, rho	int status = gsl_sf_coulomb_wave_FG_e (eta, rho, L, 0, &F, &Fp, &G,					 &Gp, &exp_F, &exp_G);	// Check to see if this failed. If it's out of range, set P=0,	// if not, print an error and exit	if(status){	if(status == GSL_EOVRFLW){		//ErrorFlag = true;		//PenZeroCount++;		P = 0.0;		S = 0.0;		return;	}	else {		exit(1);		std::cout << "\nERROR: Something went wrong in coulomb wavefunction!" << "\n\tGSL Error: " << gsl_strerror (status)<< std::endl;		std::cout << "The Energy was " << E*1e3 << " keV." << std::endl;		abort();	}	}	gsl_set_error_handler (NULL);	// Just in case there is an overflow, multiply by exponential	// (See GSL documentation for more info)	double F_l = F.val*exp(exp_F);	double G_l = G.val*exp(exp_G);	P = rho/( pow(F_l,2) + pow(G_l,2) );	S = rho*( F_l * Fp.val + G_l*Gp.val)/	  (pow(F_l,2) + pow(G_l,2));    return;}/** * Checks whether dimensions of the function parameters are correct. * * @param dims Vector of length npar denoting the dimensions of * the parameters, with any redundant dimensions dropped. */bool sfactorTdn::checkParameterDim(std::vector<std::vector<unsigned int> > const &dims) const {    //the first argument should be a vector    // the last three arguments should be scalars    return isScalar(dims[0])&& isScalar(dims[1]) && isScalar(dims[2]) && isScalar(dims[3])                             && isScalar(dims[4]) && isScalar(dims[5]  && isScalar(dims[6]);}/** * Checks whether the parameter values lie in the domain of the * function. The default implementation returns true. */bool sfactorTdn::checkParameterValue(std::vector<double const *> const &args,                             std::vector<std::vector<unsigned int> > const &dims) const{        // TODO: should any parameters be eg strictly positive?        return true;}/** * Calculates what the dimension of the return value should be, * based on the arguments. * * @param dims Vector of Indices denoting the dimensions of the     * parameters. This vector must return true when passed to     * checkParameterDim.     *     * @param values Vector of pointers to parameter values.     */std::vector<unsigned int> sfactorTdn::dim(std::vector <std::vector<unsigned int> > const &dims,                 std::vector <double const *> const &values) const {        // the size of the table that the fortran code calculates is length of E (input)        vector<unsigned int> ans(1);                ans[0] = 1;        return ans;}}} //end namespaces