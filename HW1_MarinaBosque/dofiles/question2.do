 *-------------------------------- Question 2 -------------------------------*

 ***** Define Program 

 program define question2

 *** Construct labor supply 
 use "${data}GSEC8_1.dta", clear
   
 *** Replace all missings by 0
 
 keep HHID h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g h8q30a h8q30b h8q31a ///
 h8q31b h8q31c h8q43 h8q44 h8q44b h8q45a h8q45b h8q45c
 
 foreach var of varlist h8q36a h8q36b h8q36c h8q36d h8q36e h8q36f h8q36g h8q30a h8q30b h8q31a ///
 h8q31b h8q31c h8q43 h8q44 h8q44b h8q45a h8q45b h8q45c {
	replace `var' = 0 if `var'==.
 }
 
 
 *** Main job
 ** Hours worked
 gen hours_week = h8q36a + h8q36b + h8q36c + h8q36d + h8q36e + h8q36f + h8q36g //hours worked per week
 gen hours_year = hours_week*h8q30a*h8q30b //hours worked per year
 
 ** Wage per hour
 gen wage_hour = .
 replace wage_hour = (h8q31a+h8q31b) if h8q31c==1	
 replace wage_hour = (h8q31a+h8q31b)/8 if h8q31c==2 // work 8 hours a day 
 replace wage_hour = (h8q31a+h8q31b)/56 if h8q31c==3  	// work 56 hours a week	
 replace wage_hour = (h8q31a+h8q31b)/(4*56) if h8q31c==4	// work 4*56 hours a year
 replace wage_hour = . if h8q31c==5 
 
 ** Labor Income
 gen labor_income1 = wage_hour * hours_year
 replace labor_income1 = 0 if labor_income1==.
 
 
 *** Second job
 ** Hours worked
 gen hours_week2 = h8q43
 gen hours_year2 = hours_week2 * h8q44 * h8q44b

 gen wage_hour2 = .
 replace wage_hour2 = (h8q45a+h8q45b) if h8q45c==1	
 replace wage_hour2 = (h8q45a+h8q45b)/8 if h8q45c==2   	// work 8 hours a day
 replace wage_hour2 = (h8q45a+h8q45b)/56 if h8q45c==3  	// work 56 hours a week		
 replace wage_hour2 = (h8q45a+h8q45b)/(4*56) if h8q45c==4	// work 4*56 hours a year
 replace wage_hour2 = . if h8q45c==5	

 ** Labor Income
 gen labor_income2 = wage_hour2 * hours_year2
 replace labor_income2 = 0 if labor_income2==.

 ** Total labor income
 gen labor_income = labor_income1 + labor_income2

 collapse (sum) labor_income labor_income1 labor_income2 hours_week ///
 hours_week2 hours_year hours_year2, by(HHID)
 
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hh)
 drop HHID
 rename hh HHID
 
 merge 1:1 HHID using "${output}final_dataset.dta"
 drop _merge
 replace labor_income = 0 if labor_income==.
 
  *** Generate intensive and extensive margin of labor supply
 keep if age> 15 & age < 70
 gen intensive = hours_year + hours_year2
 bysort urban: egen emp=sum(wgt_X) if intensive>0
 bysort urban: egen total=sum(wgt_X) 
 gen extensive = emp/total 
 
 save "${output}lab_income.dta", replace

 
 ********************************** Part 1 ******************************** 
 
 *** Average labor supply for rural and urban areas
 mean intensive[pw=wgt_X]
 mean intensive[pw=wgt_X] if urban==0  
 mean intensive[pw=wgt_X] if urban==1  

 *** Histogram for labor supply for rural and urban areas  
 
 preserve
 
	 gen log_intensive=log(intensive)
	 
	 twoway (histogram intensive if urban==0, fcolor(none) lcolor(maroon)) ///
	 (histogram intensive if urban==1, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Rural" 2 "Urban")) xtitle("Intensive margin (hours worked)") graphregion(color(white)) 
	 graph export "${figures}hist4.png", replace 
 
 restore

 *** Variance of logs for labor supply for rural and urban areas

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

 mean v_intensive [pw=wgt_X]
 mean v_intensive [pw=wgt_X] if urban== 0 
 mean v_intensive [pw=wgt_X] if urban== 1 
 
 
 *** Labor supply level, inequality, and covariances over the lifecycle
 
 ** Labor supply level and inequality over the lifecycle

 preserve
	  
	 collapse (mean) intensive v_intensive, by(age)
	 	 
	 graph twoway (line intensive age, fcolor(none) lcolor(navy)), ///
	 xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (var of log hours worked)") ///
	 graphregion(color(white))
	 graph export "${figures}figure3.png", replace
	 
	 graph twoway (line v_intensive age, fcolor(none) lcolor(navy)), ///
	 xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (var of log hours worked)") ///
	 graphregion(color(white))
	 graph export "${figures}figure4.png", replace
	 
 restore

 ************************************************************************************ 
	  
 ********************************** Part 2 ******************************** 
 
 *** GENDER
 use "${output}lab_income.dta", clear
 
 *** Average labor supply for rural and urban areas
 forvalues i=1/2 {
	 mean intensive[pw=wgt_X] if gender==`i'
	 mean intensive[pw=wgt_X] if urban==0 & gender==`i'
	 mean intensive[pw=wgt_X] if urban==1 & gender==`i'
 }	 


 *** Histogram for labor supply for rural and urban areas  
 
 preserve
 
	 gen log_intensive = log(intensive)
	 
	 twoway (histogram log_intensive if urban==0 & gender==1, fcolor(none) lcolor(maroon)) ///
	 (histogram log_intensive if urban==1 & gender==1, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Rural" 2 "Urban")) xtitle("Intensive margin (hours worked)") graphregion(color(white)) 
	 graph export "${figures}hist5.png", replace 

	 twoway (histogram log_intensive if urban==0 & gender==2, fcolor(none) lcolor(maroon)) ///
	 (histogram log_intensive if urban==1 & gender==2, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Rural" 2 "Urban")) xtitle("Intensive margin (hours worked)") graphregion(color(white)) 
	 graph export "${figures}hist6.png", replace 

 restore

 *** Variance of logs for labor supply for rural and urban areas

 forvalues i = 1/2 {
	foreach var in intensive {
		gen log_`var'_`i'=log(`var') if gender == `i'
		gen log_`var'_mean_`i'=. if gender == `i'
		gen v_`var'_`i'=. if gender == `i'
	}
 }
 
 forvalues i = 1/2 {
	 foreach var in intensive {
		 sum log_`var'_`i' [w=wgt_X] if gender == `i'
		 replace log_`var'_mean_`i' = r(mean) if gender == `i'
		 replace v_`var'_`i'=(log_`var'_`i'-log_`var'_mean_`i')^2 if gender == `i'
	 }
 }
 
 forvalues i = 1/2 {
	 mean v_intensive_`i' [pw=wgt_X]
	 mean v_intensive_`i' [pw=wgt_X] if urban== 0 
	 mean v_intensive_`i' [pw=wgt_X] if urban== 1 
 }

 
 *** Labor supply level, inequality, and covariances over the lifecycle
 
 ** Labor supply level and inequality over the lifecycle

 preserve
	  
	 collapse (mean) intensive v_intensive_*, by(age gender)
	 	 
	 graph twoway (line intensive age if gender==1, fcolor(none) lcolor(navy)) ///
	 (line intensive age if gender==2, fcolor(none) lcolor(maroon)), ///
	 xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (hours worked)", size(medlarge)) ///
	 legend(order(1 "Men" 2 "Women")) graphregion(color(white))
	 graph export "${figures}figure5.png", replace
	 
	 graph twoway (line v_intensive_1 age, fcolor(none) lcolor(navy)) ///
	 (line v_intensive_2 age if gender==2, fcolor(none) lcolor(maroon)), ///
	 xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (var of log hours worked)", size(medlarge)) ///
	 legend(order(1 "Men" 2 "Women")) graphregion(color(white))
	 graph export "${figures}figure6.png", replace
	 
 restore

 ************************************************************************************

 *** EDUCATION GROUPS
 use "${output}lab_income.dta", clear
 
 *** Clean education variable
 drop if education==. | education==99
 rename education educ
 
 gen education =.
 replace education = 1 if educ < 17 // less than P.7
 replace education = 2 if educ>=17 & educ < 34 //Primary education but less than high school
 replace education = 3 if educ>=34 // Secondary and more

 *** Average labor supply for rural and urban areas
 
 forvalues i=1/3 {
	 mean intensive[pw=wgt_X] if education==`i'
	 mean intensive[pw=wgt_X] if urban==0 & education==`i'
	 mean intensive[pw=wgt_X] if urban==1 & education==`i'  
 }

 *** Histogram for labor supply for rural and urban areas  
 
 preserve
 
	 gen log_intensive=log(intensive)
	 
	 twoway (histogram log_intensive if urban==0 & education==1, fcolor(none) lcolor(maroon)) ///
	 (histogram log_intensive if urban==1 & education==1, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Rural" 2 "Urban")) xtitle("Intensive margin (hours worked)") graphregion(color(white)) 
	 graph export "${figures}hist7.png", replace 

	 twoway (histogram log_intensive if urban==0 & education==2, fcolor(none) lcolor(maroon)) ///
	 (histogram log_intensive if urban==1 & education==2, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Rural" 2 "Urban")) xtitle("Intensive margin (hours worked)") graphregion(color(white)) 
	 graph export "${figures}hist8.png", replace 
	 
	 twoway (histogram log_intensive if urban==0 & education==3, fcolor(none) lcolor(maroon)) ///
	 (histogram log_intensive if urban==1 & education==3, fcolor(none) lcolor(forest_green)), ///
	 legend(order(1 "Rural" 2 "Urban")) xtitle("Intensive margin (hours worked)") graphregion(color(white)) 
	 graph export "${figures}hist9.png", replace 

 restore

  *** Variance of logs for labor supply for rural and urban areas

 forvalues i = 1/3 {
	foreach var in intensive {
		gen log_`var'_`i'=log(`var') if education == `i'
		gen log_`var'_mean_`i'=. if education == `i'
		gen v_`var'_`i'=. if education == `i'
	}
 }
 
 forvalues i = 1/3 {
	 foreach var in intensive {
		 sum log_`var'_`i' [w=wgt_X] if education == `i'
		 replace log_`var'_mean_`i' = r(mean) if education == `i'
		 replace v_`var'_`i'=(log_`var'_`i'-log_`var'_mean_`i')^2 if education == `i'
	 }
 }
 
 forvalues i = 1/3 {
	 mean v_intensive_`i' [pw=wgt_X] if education==`i'
	 mean v_intensive_`i' [pw=wgt_X] if urban== 0 & education==`i'
	 mean v_intensive_`i' [pw=wgt_X] if urban== 1 & education==`i'
 }

 
 *** Labor supply level, inequality, and covariances over the lifecycle
 
 ** Labor supply level and inequality over the lifecycle

 preserve
	  
	 collapse (mean) intensive v_intensive_*, by(age education)
	 	 
	 graph twoway (line intensive age if education==1, fcolor(none) lcolor(navy)) ///
	 (line intensive age if education==2, fcolor(none) lcolor(maroon)) ///
	 (line intensive age if education==3, fcolor(none) lcolor(forest_green)), ///
	 xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (hours worked)", size(medlarge)) ///
	 legend(order(1 "Less than primary school" 2 "Less than high school" 3 "High school or more")) ///
	 graphregion(color(white))
	 graph export "${figures}figure7.png", replace
	 
	 graph twoway (line v_intensive_1 age if education==1, fcolor(none) lcolor(navy)) ///
	 (line v_intensive_2 age if education==2, fcolor(none) lcolor(maroon)) ///
	 (line v_intensive_3 age if education==3, fcolor(none) lcolor(forest_green)), ///
	 xtitle("Age") xlabel(15(10)70, labsize(medlarge) noticks grid angle(0)) ///
	 ylabel(, labsize(medlarge) nogrid) ytitle("Intensive margin (hours worked)", size(medlarge)) ///
	 legend(order(1 "Less than primary school" 2 "Less than high school" 3 "High school or more")) ///
	 graphregion(color(white))
	 graph export "${figures}figure8.png", replace
	 
 restore
 
 
 end
 
 ************************************************************************************
