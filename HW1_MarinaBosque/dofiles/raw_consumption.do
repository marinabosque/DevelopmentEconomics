 *--------------------------- Creating Consumption --------------------------*

 ***** Define Program 

 program define raw_consumption

 *** Opening 
 use "${data}UNPS 2013-14 Consumption Aggregate.dta", clear

 gen consumption = (cpexp30)*12 // yearly consumption
 
 keep HHID district_code urban ea region regurb consumption wgt_X hsize
 
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hh)
 drop HHID
 
 bysort hh: gen n = _n
 drop if n==2
 
 save "${temp}consumption.dta", replace
 
 end
 
 ************************************************************************************
