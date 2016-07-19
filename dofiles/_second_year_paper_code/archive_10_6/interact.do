
#delimit ;
capture program drop interact;

program define interact ;

	local increment `1';
	display "`1'";
	local upper `2' ;
	display "`2'";


*     ***************************************************************** *;
*     ***************************************************************** *;
*       File-Name:      singlemodifyingvariable.do                      *;
*       Date:           Month/Day/Year                                  *;
*       Author:         MRG                                             *;
*       Purpose:        Do-file for creating figures showing the        *;
*                       marginal effect of X on Y with a single         *;
*                       modifying variable where the dependent variable *;
*                       is continuous.  The estimated model is:         *;
*                       Y = b0 + b1X + b2Z + b3XZ + epsilon             *;
*       Input File:     name_of_datafile.dta                            *;
*       Output File:    logfilename.log                                 *;
*       Data Output:    None                                            *;
*       Previous file:  None                                            *;
*       Machine:        Office                                          *;
*     ****************************************************************  *;
*     ****************************************************************  *;

*     ****************************************************************  *;
*     Estimate Model: Y = b0 + b1X + b2Z + b3XZ + b4Controls + epsilon  *;
*     ****************************************************************  *;


*     ****************************************************************  *;
*       Generate the values of Z for which you want to calculate the    *;
*       marginal effect (and standard errors) of X on Y.                *;
*     ****************************************************************  *;

generate MV=((_n-1)/`increment');

* replace  MV=. if _n>`upper'/`increment';

*     ****************************************************************  *;
*       Grab elements of the coefficient and variance-covariance matrix *;
*       that are required to calculate the marginal effect and standard *;
*       errors.                                                         *;
*     ****************************************************************  *;

matrix b=e(b); 
matrix V=e(V);
 
scalar b1=b[1,1]; 
scalar b2=b[1,2];
scalar b3=b[1,3];


scalar varb1=V[1,1]; 
scalar varb2=V[2,2]; 
scalar varb3=V[3,3];

scalar covb1b3=V[1,3]; 
scalar covb2b3=V[2,3];

scalar list b1 b2 b3 varb1 varb2 varb3 covb1b3 covb2b3;

*     ****************************************************************  *;
*       Calculate the marginal effect of X on Y for all MV values of    *;
*       the modifying variable Z.                                       *;
*     ****************************************************************  *;

gen conb=b1+b3*MV ;
* if _n<`upper'/`increment';


*     ****************************************************************  *;
*       Calculate the standard errors for the marginal effect of X on Y *;
*       for all MV values of the modifying variable Z.                  *;
*     ****************************************************************  *;

gen conse=sqrt(varb1+varb3*(MV^2)+2*covb1b3*MV) ;
* if _n<`upper'/`increment'; 


*     ****************************************************************  *;
*       Generate upper and lower bounds of the confidence interval.     *;
*       Specify the significance of the confidence interval.            *;
*     ****************************************************************  *;

gen a=1.96*conse;
 
gen upper=conb+a;
 
gen lower=conb-a;

*     ****************************************************************  *;
*       Graph the marginal effect of X on Y across the desired range of *;
*       the modifying variable Z.  Show the confidence interval.        *;
*     ****************************************************************  *;

graph twoway line conb   MV, clwidth(medium) clcolor(blue) clcolor(black)
        ||   line upper  MV, clpattern(dash) clwidth(thin) clcolor(black)
        ||   line lower  MV, clpattern(dash) clwidth(thin) clcolor(black)
        ||   ,   
             xlabel(0 1 2 3 4 5 6, labsize(2.5)) 
             ylabel(-4 -2 0 2 4,   labsize(2.5))
             yscale(noline)
             xscale(noline)
             legend(col(1) order(1 2) label(1 "Marginal Effect of X") 
                                      label(2 "95% Confidence Interval") 
                                      label(3 " "))
             yline(0, lcolor(black))   
             title("Marginal Effect of X on Y As Z Changes", size(4))
             subtitle(" " "Dependent Variable: Y" " ", size(3))
             xtitle( Z, size(3)  )
             xsca(titlegap(2))
             ysca(titlegap(2))
             ytitle("Marginal Effect of X", size(3))
             scheme(s2mono) graphregion(fcolor(white));
             
*     ****************************************************************  *;
*                 Figure can be saved in a variety of formats.          *;
*     ****************************************************************  *; 



*     ****************************************************************  *;
*                                   THE END                             *;
*     ****************************************************************  *;

end; 

exit;
