
#delimit ;
capture program drop interact_scores;

program define interact_scores ;

	display "First argument is moderating variable name, second is dependent variable (used for labeling, not var name), third is graph title";
	display "MAKE SURE THAT YOUR FIRST COEFFICIENT IS FOR THE DUMMY, SECOND IS CONTINUOUS INTERACTION TERM, AND THIRD IS INTERACTION!";
	local moderator `1';
	display "Moderator: `moderator'";
	local dependent `2';
	display "Dependent Var: `dependent'";
	local title "`3'";
	
	local umoderator: variable label `moderator';

	local increment 0.1;


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
scalar covb1b2=V[1,2];

scalar list b1 b2 b3 varb1 varb2 varb3 covb1b3 covb2b3;

quietly sum `moderator' if e(sample);
local min=r(min);
local max=r(max);

*     ****************************************************************  *;
*       Create fake dataset to plot    *; 
*     ****************************************************************  *;

preserve;
clear ;
local number_of_obs=int((`max'-`min')/`increment');
set obs `number_of_obs';

gen MV=_n*`increment'+`min';

gen conb_priv=b1+(b3+b2)*MV ;

gen conb_gov=b2*MV;

local tstat=abs(b3/sqrt(varb3));
local pvalue=(1-normal(`tstat'))*2;
* Reformat;
display "`pvalue'";
local pvalue: display %3.2f `pvalue';
display "`pvalue'";


*     ****************************************************************  *;
*       Calculate the standard errors for the marginal effect of X on Y *;
*       for all MV values of the modifying variable Z.                  *;
*     ****************************************************************  *;

gen conse_priv=sqrt(varb1+covb1b2 + covb1b3 + (MV^2)*(covb1b2 + covb1b3 + covb2b3 + covb2b3 + varb2+ varb3) );
gen conse_gov=sqrt(MV^2*varb2);

*     ****************************************************************  *;
*       Generate upper and lower bounds of the confidence interval.     *;
*       Specify the significance of the confidence interval.            *;
*     ****************************************************************  *;

foreach x in priv gov {;
	gen a_`x'=1.645*conse_`x';
	gen upper_`x'=conb_`x'+a_`x';
	gen lower_`x'=conb_`x'-a_`x';
};

*     ****************************************************************  *;
*       Graph the marginal effect of X on Y across the desired range of *;
*       the modifying variable Z.  Show the confidence interval.        *;
*     ****************************************************************  *;

graph twoway line conb_priv   MV, clwidth(medium) clcolor(blue)  clpattern(solid)
        ||  line conb_gov   MV, clwidth(medium) clcolor(red)  clpattern(solid)
		||	line upper_priv  MV, clpattern(dash) clwidth(thin) clcolor(black)
        ||   line lower_priv  MV, clpattern(dash) clwidth(thin) clcolor(black)
		||	line upper_gov  MV, clpattern(dash) clwidth(thin) clcolor(black)
        ||   line lower_gov  MV, clpattern(dash) clwidth(thin) clcolor(black)
        ||   ,   
             yscale(noline  range(-`increment') range(`increment'))
			 ytick(0) 
             xscale(  range(`max') range(`min'))
             legend(col(1) order(1 2) label(1 "Private") 
                                      label(2 "Government") )
             yline(0, lcolor(black))   
             title("`title'", size(4))
			 subtitle("With 90% Confidence Intervals", size(3))
             xtitle( `umoderator', size(3)  )
             xsca(titlegap(2))
             ysca(titlegap(2))
             ytitle("Private School Test Premium in Standard Deviations", size(3))
              graphregion(fcolor(white));
             
*     ****************************************************************  *;
*                 Figure can be saved in a variety of formats.          *;
*     ****************************************************************  *; 



*     ****************************************************************  *;
*                                   THE END                             *;
*     ****************************************************************  *;
restore;

end; 

exit;
