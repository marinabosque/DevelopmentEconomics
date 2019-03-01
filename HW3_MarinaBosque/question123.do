 ***********************************************************************************  
 *********************      P R O B L E M     S E T     3      *********************
 ***********************************************************************************

  ***** Preliminary commands
  clear all
  clear matrix
  clear mata
  capture log close
  capture program drop _all
  capture label drop _all
  capture set more off, permanently
  capture set matsize 11000
  capture set maxvar 32767
  capture set linesize 255
  pause on
	
  ***** Global paths
  global code "/Users/marinabosque/Documents/Master CEMFI/Second Course - Fifth Term/Development Economics/ProblemSet3/"
  global dofiles "${code}dofiles/" 
  global data "${code}data/"
  global output "${code}output/"

 ***********************************************************************************  
 **********************       Q U E S T I O N   1  &  3       **********************
 ***********************************************************************************

 *** Opening the dataset 
 use "${data}dataUGA.dta", clear
 
 ** Keep meaningful variables
 keep hh year wave lnc lninctotal_trans age age_sq familysize ethnic female urban
 
 ** Correct the variable year
 bysort year hh: gen cnt = _N // 262 repeated years
 replace year = 2010 if wave=="2010-2011" & year==2011 & cnt==2
 drop cnt
 
 bysort year hh: gen cnt = _N // 218 repeated years
 replace year = 2009 if wave=="2009-2010" & year==2010 & cnt==2
 drop cnt wave 	
 
 ** Construct residuals for consumption
 reg lnc age age_sq familysize i.ethnic i.female i.year i.urban
 predict res
 rename res res_c
 
 ** Construct residuals for income
 reg lninctotal_trans age age_sq familysize i.ethnic i.female i.year i.urban
 predict res
 rename res res_inc
 rename lninctotal_trans income
 
 ** Construct aggregate consumption
 bysort year: egen agg_c = sum(lnc)
 
 ** Set and balance the panel
 keep res_c res_inc agg_c hh year income
 xtset hh year
 
 reshape wide res_c res_inc agg_c income, i(hh) j(year)
 
 forvalues y = 10(1)14 {
	egen agg_c20`y'_t = mean(agg_c20`y')
	drop agg_c20`y'
	rename agg_c20`y'_t agg_c20`y'
 }
 egen agg_c2009_t = mean(agg_c2009)
 drop agg_c2009
 rename agg_c2009_t agg_c2009
 
 reshape long res_c res_inc agg_c income, i(hh)
 rename _j year
 
 ** Interpolate the missing observations and dropping the hh with just one year
 bysort hh: ipolate res_c year, generate(res_ci) epolate
 bysort hh: ipolate res_inc year, generate(res_inci) epolate  
 bysort hh: ipolate income year, generate(income_i) epolate  
 
 gen ones = 1
 replace ones = 0 if res_ci ==.
 egen numyears = sum(ones), by(hh)
 drop if numyears <= 1
 drop res_c res_inc ones numyears

 ** Generate an identifier for each individual
 sort hh year
 egen id = group(hh) 
 
 ** Regressions with random coefficients for each hh (question 1)
 generate beta = .
 generate phi = .
 
 forvalues i = 1(1)2895 {
	reg d.res_ci d.res_inci d.agg_c if id==`i', nocons
	replace beta = _b[d.res_inci] if id==`i'
	replace phi = _b[d.agg_c] if id==`i'
 }

 ** Regressions with average coefficients (question 3)
 reg d.res_ci d.res_inci d.agg_c, nocons
 display _b[d.res_inci]
 display _b[d.agg_c]
 
 ** Histogram of betas and phis
 preserve
	 collapse beta phi, by(hh)
	 
	 ** Trimming 
	 drop if beta > 2
	 drop if beta < -2
	 
	 ** Mean and median
	 sum beta, detail
	 
	 histogram beta, title("Figure 1: Coefficient beta across households", color(black)) ///
	 xtitle ("Beta") graphregion(color(white)) bcolor(maroon)
	 graph export "${output}hist_beta.png", replace
 restore
 
 preserve
 	 collapse beta phi, by(hh)

	 ** Trimming 
	 drop if phi > 0.00002
	 drop if phi < -0.00002

	 ** Mean and median
	 sum phi, detail
	 
	 histogram phi, title("Figure 2: Coefficient phi across households", color(black)) ///
	 xtitle ("Phi") graphregion(color(white)) bcolor(navy)
	 graph export "${output}hist_phi.png", replace
 restore

 ***********************************************************************************  
 *************************       Q U E S T I O N   2       *************************
 ***********************************************************************************
 
 ** Average hh income
 gen ones = 1
 replace ones = 0 if income_i ==.
 egen numyears = sum(ones), by(hh)
 drop if numyears <= 1
 drop ones numyears income
 
 collapse (mean) income_i beta, by(hh)
 
 *** Compute mean and median of beta within within each income group
 ** Define five income groups
 sort income_i
 gen nobs = _N // total of 2879 observations
 gen nhh = _n 
 
 gen inc_group = 0
 replace inc_group = 1 if nhh<=576
 replace inc_group = 2 if nhh>576 & nhh<=1152
 replace inc_group = 3 if nhh>1152 & nhh<=1728
 replace inc_group = 4 if nhh>1728 & nhh<=2304
 replace inc_group = 5 if nhh>2304 & nhh<=2879
 
 ** Compute mean and median betas
 forvalues i = 1(1)5 {
	sum beta if inc_group==`i', detail
 }
 drop nhh
 
 *** Compute mean and median of income within within each beta group
 ** Define five beta groups
 sort beta
 gen nhh = _n 
 
 gen beta_group = 0
 replace beta_group = 1 if nhh<=576
 replace beta_group = 2 if nhh>576 & nhh<=1152
 replace beta_group = 3 if nhh>1152 & nhh<=1728
 replace beta_group = 4 if nhh>1728 & nhh<=2304
 replace beta_group = 5 if nhh>2304 & nhh<=2879
 
 ** Compute mean and median betas
 forvalues i = 1(1)5 {
	sum income_i if beta_group==`i', detail
 }


 ************************************************************************************
