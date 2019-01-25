 *-------------------------------- Question 3 -------------------------------*

 ***** Define Program 

 program define question3

 *** Preparing the dataset
 use "${output}lab_income.dta", clear
   
 collapse (mean) intensive consumption income wealth, by (district_code)

 foreach var in consumption income wealth {
	replace `var' = log(`var')
 }
 
 ********************************** Part 1 ******************************** 
 
 *** Plot the level of CIW and labor supply by zone against the level of household income by zone
 
 preserve
	 scatter intensive consumption, ytitle("Mean hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean consumption", size(medlarge)) ///
	 graphregion(color(white))
	 graph export "${figures}figure9.png", replace
 restore

 preserve
	 drop if district_code =="413" // drop the outlier
	 
	 scatter intensive income, ytitle("Mean hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean income", size(medlarge)) ///
	 graphregion(color(white))
	 graph export "${figures}figure10.png", replace
 restore
 
 preserve
	 scatter intensive wealth, ytitle("Mean hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean wealth", size(medlarge)) ///
	 graphregion(color(white))
	 graph export "${figures}figure11.png", replace
 restore
 
 **************************************************************************
	  
 ********************************** Part 2 ******************************** 
 
 *** Plot the inequality of CIW and labor supply by zone against the level of household income by zone
 use "${output}lab_income.dta", clear
 
 foreach var in intensive {
	 gen log_`var'=log(`var')
	 gen log_`var'_mean=.
	 gen v_`var'=.
 }

 foreach var in intensive {
	 sum log_`var' [w=wgt_X]
	 replace log_`var'_mean = r(mean)
	 replace v_`var'=(log_`var'-log_`var'_mean)^2
 }

 collapse (mean) v_intensive income wealth consumption, by(district_code)
 
 foreach var in income wealth consumption {
	replace `var' = log(`var')
  }
 
 preserve
	 scatter v_intensive consumption || lfit v_intensive consumption, ///
	 ytitle("Mean var log hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean consumption", size(medlarge)) ///
	 graphregion(color(white))
	 graph export "${figures}figure12.png", replace
 restore
 
 preserve
	 drop if district_code =="413" // drop the outlier
	 
	 scatter v_intensive income || lfit v_intensive income, ///
	 ytitle("Mean var log hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean income", size(medlarge)) ///
	 graphregion(color(white))
	 graph export "${figures}figure13.png", replace
 restore
 
 preserve
	 scatter v_intensive wealth || lfit v_intensive wealth, ///
	 ytitle("Mean hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean wealth", size(medlarge)) ///
	 graphregion(color(white))
	 graph export "${figures}figure14.png", replace
 restore
	
	
 **************************************************************************
	  
 ********************************** Part 3 ******************************** 

 *** Plot the covariances of CIW and labor supply by zone against the level of household income by zone
 use "${output}lab_income.dta", clear
 *ssc install egenmore
 
 ** Create a local variable with the different districts
 levelsof district_code, local(district)
 bysort district: correlate income intensive
 
 egen corr_income = corr(income intensive), by(district)
 egen corr_wealth = corr(wealth intensive), by(district)
 egen corr_consumption = corr(consumption intensive), by(district)

 collapse (mean) corr_income corr_wealth corr_consumption income wealth consumption, by(district_code)

 foreach var in consumption income wealth {
	replace `var' = log(`var')
 }
 
 preserve
	 scatter corr_income income || lfit corr_income income, ///
	 ytitle("Correlation income - hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean income", size(medlarge)) ///
	 graphregion(color(white)) legend(off)
	 graph export "${figures}figure15.png", replace
 restore
 
 preserve
	 drop if district_code =="413" // drop the outlier

	 scatter corr_wealth income || lfit corr_income income, ///
	 ytitle("Correlation wealth - hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean wealth", size(medlarge)) ///
	 graphregion(color(white)) legend(off)
	 graph export "${figures}figure16.png", replace
 restore

 preserve
	 scatter corr_consumption wealth || lfit corr_income income, ///
	 ytitle("Correlation consumption - hours worked", size(medlarge)) ///
	 ylabel(, labsize(medlarge) noticks nogrid) xtitle("Log-mean consumption", size(medlarge)) ///
	 graphregion(color(white)) legend(off)
	 graph export "${figures}figure17.png", replace
 restore 
 
 end
 
 ************************************************************************************
