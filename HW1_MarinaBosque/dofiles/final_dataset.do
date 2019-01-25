 *--------------------------- Final Dataset --------------------------*

 ***** Define Program 

 program define final_dataset

 *** Merge all the datasets 
 use "${temp}consumption.dta", clear

 merge 1:1 hh using "${temp}income.dta"
 drop _merge
 
 merge 1:1 hh using "${temp}wealth.dta"
 drop _merge
 
 
 *** Merge with HH roster to get household head, age, education
 
 merge m:m HHID using "${data}GSEC2.dta" // get gender and age
 drop _merge
 keep if h2q4==1 // keep the household
 rename h2q8 age 
 rename h2q3 gender
 keep  HHID  PID district_code urban ea region regurb consumption income wealth wgt_X hsize wealth age gender h2q4
 
 merge 1:1 HHID PID using "${data}GSEC4.dta" //get education
 drop _merge
 keep if h2q4 == 1 
 rename h4q7 education
 keep HHID district_code urban ea region regurb consumption income wealth wgt_X hsize wealth age gender education
 
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hhid)
 drop HHID
 rename hhid HHID
  
 drop if consumption ==.
 drop if income == 0
 drop if consumption > wealth+income 
 
 bysort HHID: gen n = _n
 drop if n>1
 drop n
 
 save "${output}final_dataset.dta", replace
 
 end
 
 ************************************************************************************
