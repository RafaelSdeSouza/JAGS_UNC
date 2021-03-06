#ifndef SFACTORTDN3_H_
#define SFACTORTDN3_H_

#include <function/ArrayFunction.h>

namespace jags {
namespace nuclear {

/**
 * @short Astrophysical S Factors
 * sfactorTdn3 returns the astrophysical S-factor as a function of energy.
 * <pre>
 * obsy1 = sfactorTdn3(obsx1, e1, ex, gi, gf, ri, rf, ue)
 * </pre>
 */

class sfactorTdn3 : public ArrayFunction {
    public:
	sfactorTdn3();
	
    void evaluate(double *x, std::vector<double const *> const &args,
                    std::vector<std::vector<unsigned int> > const &dims) const;
                    
    void coul(int, double, double, double&, double&) const;
    
     void PenFactor(const double E, const double L, const double R,
   				const double mue,
				const double qQ,
				double& P, double& S) const;     
                
	bool checkParameterDim(std::vector<std::vector<unsigned int> > const &dims) const;
	
	std::vector<unsigned int> dim(std::vector<std::vector<unsigned int> > const &dims,
    	
    	std::vector<double const *> const &values) const;
    	    	
	bool checkParameterValue(std::vector<double const *> const &args,
    	std::vector<std::vector<unsigned int> > const &dims) const;
}; 
    
}}//end namespaces

#endif /* SFACTORTDN3_H_ */
