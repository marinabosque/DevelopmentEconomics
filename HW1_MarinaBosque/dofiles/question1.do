 *-------------------------------- Question 1 -------------------------------*

 ***** Define Program 

 program define question1

 *** Merge all the datasets 
 use "${output}final_dataset.dta", clear

 drop if income <0
 
 *** Convert to 2013 USD 
 foreach var in consumption wealth income {
	replace `var' = `var'/3696.24
 }
 
 ******************************** Question 1 ****************************** 
 
 ********************************** Part 1 ******************************** 
 
 *** Average CIW for rural and urban areas
 
 mean consumption[pw=wgt_X] if urban==0 // Mean annual consumption in rural areas is 634  
 mean consumption[pw=wgt_X] if urban==1 // Mean annual consumption in urban areas is 1103 
 mean income [pw=wgt_X] if urban==0 // Mean annual income in rural areas is 1409   
 mean income [pw=wgt_X] if urban==1 // Mean annul income in urban areas is 5827   
 mean wealth [pw=wgt_X] if urban==0 // Mean annual wealth in rural areas is 2568
 mean wealth [pw=wgt_X] if urban==1 // Mean annual wealth in urban areas is 7198

 
 ********************************** Part 2 ******************************** 
 
 *** Histogram for CIW for rural and urban areas  
 _pctile consumption, nq(100)
 drop if consumption >r(r99) 
 _pctile wealth, nq(100)
 drop if wealth >r(r99) 
 _pctile income, nq(100)
 drop if income >r(r99) //trim

 twoway (histogram consumption if urban==0, fcolor(none) lcolor(maroon)) ///
 (histogram consumption if urban==1, fcolor(none) lcolor(forest_green)), ///
 legend(order(1 "Rural" 2 "Urban")) xtitle(Consumption) graphregion(color(white)) 
 graph export "${figures}hist1.png", replace 
 
 twoway (histogram income if urban==0, fcolor(none) lcolor(maroon)) ///
 (histogram income if urban==1, fcolor(none) lcolor(forest_green)), ///
 legend(order(1 "Rural" 2 "Urban")) xtitle(Income) graphregion(color(white)) 
 graph export "${figures}hist2.png", replace 

 twoway (histogram wealth if urban==0, fcolor(none) lcolor(maroon)) ///
 (histogram wealth if urban==1, fcolor(none) lcolor(forest_green)), ///
 legend(order(1 "Rural" 2 "Urban")) xtitle(Wealth) graphregion(color(white)) 
 graph export "${figures}hist3.png", replace 
 
 *** Variance of logs for CIW for rural and urban areas

 foreach var in consumption wealth income {
	 gen log_`var'=log(`var')
	 gen log_`var'_mean=.
	 gen v_`var'=.
 }

 foreach var in consumption wealth income {
	 sum log_`var' [w=wgt_X]
	 replace log_`var'_mean = r(mean)
	 replace v_`var'=(log_`var'-log_`var'_mean)^2
	 mean v_`var' [pw=wgt_X] if urban== 0
	 mean v_`var' [pw=wgt_X] if urban== 1
 }

 mean v_consumption [pw=wgt_X] if urban== 0 // 0.39
 mean v_consumption [pw=wgt_X] if urban== 1 // 0.65 
 mean v_income [pw=wgt_X] if urban== 0 // 1.62 
 mean v_income [pw=wgt_X] if urban== 1 // 2.50
 mean v_wealth [pw=wgt_X] if urban== 0 // 1.37
 mean v_wealth [pw=wgt_X] if urban== 1 // 2.83 
 
 drop log_* v_*
 
 ********************************** Part 3 ******************************** 
 
 *** Joint cross-sectional behavior of CIW
 
 correlate consumption income wealth // Correlation for both rural and urban areas
 correlate consumption income wealth if urban==0 // Correlation for rural areas
 correlate consumption income wealth if urban==1 // Correlation for urban areas
 
 ********************************** Part 4 ******************************** 
  
 *** CIW level, inequality, and covariances over the lifecycle
 
 ** CIW level over the lifecycle
 
 keep if age<70
 
 gen income_lc = .
 gen wealth_lc = .
 gen consumption_lc = .

 foreach var in income wealth consumption {
	forvalues i=15(1)105 {
		 sum `var' [w=wgt_X] if age==`i'
		 replace `var'_lc = r(mean) if age==`i'
	}
 }

 preserve
	  
	 collapse (mean) income_lc wealth_lc consumption_lc, by(age)
	 	 
	 graph twoway (line income_lc age, fcolor(none) lcolor(navy)) ///
	 (line wealth_lc age, fcolor(none) lcolor(maroon)) ///
	 (line consumption_lc age, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Income" 2 "Wealth" 3 "Consumption")) xtitle("Age") ///
	 xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) graphregion(color(white))
	 graph export "${figures}figure1.png", replace
	 
 restore

 ** CIW inequality over the lifecycle

 foreach var in consumption wealth income {
	 gen log_`var'=log(`var')
	 gen log_`var'_mean=.
	 gen v_`var'=.
	 gen v_`var'_all =.
 }


 foreach var in consumption wealth income {
	forvalues i=15(1)70{
		sum log_`var' [w=wgt_X] if age == `i'
		replace log_`var'_mean = r(mean) if age == `i'
		replace v_`var' = (log_`var' - log_`var'_mean)^2 if age == `i'
	}
 }
 

 foreach var in consumption wealth income {
	forvalues i=15(1)70 {
		sum v_`var' [w=wgt_X] if age == `i'
		replace v_`var'_all = r(mean) if age == `i'
	}
 }

 
 preserve 
 
	collapse (mean) v_*, by(age)
	 
	graph twoway (line v_income_all age, fcolor(none) lcolor(navy)) ///
	(line v_wealth_all age, fcolor(none) lcolor(maroon)) ///
	(line v_consumption_all age, fcolor(none) lcolor(forest_green)), ///
	legend(order(1 "Var of log-income" 2 "Var of log-wealth" 3 "Var of log-consumption")) xtitle("Age") ///
	xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	ylabel(, labsize(medlarge) nogrid) graphregion(color(white))
	graph export "${figures}figure2.png", replace
	 
 restore 
	 
 
 ********************************** Part 5 ******************************** 

 *** Top and bottom of the consumption and wealth distributions conditional on income
 use "${output}final_dataset.dta", clear

 drop if income <0
 
 *** Convert to 2013 USD 
 foreach var in consumption wealth income {
	replace `var' = `var'/3696.24
 }
 
 *** Percentiles for consumption
 sort income
 gen cum_income_cons = consumption[1]
 replace cum_income_cons = consumption[_n]+ cum_income_cons[_n-1] if _n>1
 sum cum_income_cons, d
 scalar list
 
 *** Percentiles for wealth
 sort income
 gen cum_income_wealth = wealth[1]
 replace cum_income_wealth = wealth[_n]+ cum_income_wealth[_n-1] if _n>1
 sum cum_income_wealth, d
 scalar list
 
 
 end
 
 ************************************************************************************
