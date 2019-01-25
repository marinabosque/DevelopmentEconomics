 *--------------------------- Creating Wealth --------------------------*

 ***** Define Program 

 program define raw_wealth

 * Housing assets
 
 use "${data}GSEC14A.dta", clear

 gen  H_t = . 
 replace H_t = h14q5 if h14q3==1 // only for those who own assets
 replace H_t = 0 if h14q3==2
 replace H_t = 0 if H_t==.

 bysort HHID: egen H = sum(H_t)

 collapse (mean) H, by(HHID)
 rename HHID hh

 save "${temp}tempw.dta", replace 
 
 ************************************************************************************ 

 * Agricultural equipment and structure capital
 use "${data}AGSEC10.dta", clear
 
 gen  AGE_t = . 
 replace AGE_t = a10q2 if  a10q1>0 // only for those who own some item 
 replace AGE_t= 0 if AGE_t == . 

 bysort HHID: egen AGE = sum(AGE_t)

 collapse (mean) AGE, by(hh)

 merge 1:1 hh using "${temp}tempw.dta"
 drop _merge
 replace AGE = 0 if AGE==.
 
 save "${temp}tempw.dta", replace 

 ************************************************************************************ 

 * Livestock capital
 
 ** Cattle 
 use "${data}AGSEC6A.dta", clear
 
 bysort LiveStockID: egen Pb = mean(a6aq13b) //mean buying price
 replace Pb = 0 if Pb==. 
 bysort LiveStockID: egen Ps = mean(a6aq14b) //mean selling price
 replace Ps = 0 if Ps==. 
 
 gen P_C = (Pb + Ps)/2 if Pb!=0 & Ps!=0
 replace P_C = Ps if Ps>0 & Pb==0
 replace P_C = Pb if Ps==0 & Pb>0
 replace P_C = 0 if Ps==0 & Pb==0
 
 gen C_t = . 
 replace C_t = a6aq3a*P_C if a6aq3a>0 // only for those who currently own it
 replace C_t = 0 if C_t==. // missing values do not have nor own

 bysort HHID: egen C = sum(C_t)

 collapse (mean) C, by(hh)

 merge 1:1 hh using "${temp}tempw.dta"
 drop _merge
 replace C = 0 if C==.

 save "${temp}tempw.dta", replace 


 ** Small animals 
 use "${data}AGSEC6B.dta", clear

 bysort ALiveStock_Small_ID: egen Pb = mean(a6bq13b) //mean buying price
 replace Pb = 0 if Pb==. 
 bysort ALiveStock_Small_ID: egen Ps = mean(a6bq14b) //mean selling price
 replace Ps = 0 if Ps==. 
 
 gen P_S = (Pb + Ps)/2 if Pb!=0 & Ps!=0
 replace P_S = Ps if Ps>0 & Pb==0
 replace P_S = Pb if Ps==0 & Pb>0
 replace P_S = 0 if Ps==0 & Pb==0
 
 gen  S_t = . 
 replace S_t = a6bq3a*P_S if a6bq3a>0 // only for those who currently own it
 replace S_t = 0 if S_t==. //missing values do not have nor own

 bysort HHID: egen S = sum(S_t)

 collapse (mean) S, by(hh)

 merge 1:1 hh using "${temp}tempw.dta"
 drop _merge
 replace S = 0 if S==.

 save "${temp}tempw.dta", replace 

 ** Poultry 
 use "${data}AGSEC6C.dta", clear

 bysort APCode: egen Pb = mean(a6cq13b) //mean buying price
 replace Pb = 0 if Pb==. 
 bysort APCode: egen Ps = mean(a6cq14b) //mean selling price
 replace Ps = 0 if Ps==. 
 
 gen P_T = (Pb + Ps)/2 if Pb!=0 & Ps!=0
 replace P_T = Ps if Ps>0 & Pb==0
 replace P_T = Pb if Ps==0 & Pb>0
 replace P_T = 0 if Ps==0 & Pb==0
 
 gen  Po_t = . 
 replace Po_t = a6cq3a*P_T if a6cq3a>0 // only for those who currently own it
 replace Po_t= 0 if Po_t== . // Missing values do not have nor own

 bysort HHID: egen Po = sum(Po_t)

 collapse (mean) Po, by(hh)

 merge 1:1 hh using "${temp}tempw.dta"
 drop _merge
 replace Po = 0 if Po==.

 save "${temp}tempw.dta", replace 

 ************************************************************************************ 

 * Agricultural Land Value
 use "${data}AGSEC2B.dta", clear

 keep if a2bq9!=. //drop missing prices 
 
 gen P_r = a2bq9/a2bq5 // Rental_Price/acres, overall mean rental price per acre for each plots
 drop if P_r == .
 
 collapse (mean) P_r

 *rental_price = 69778.398

 ** Ownership data 
 use "${data}AGSEC2A.dta", clear

 gen AGL = . 
 replace AGL = 69778.398 * 10 * a2aq5 if a2aq5!=0 

 collapse (sum) AGL, by(hh) 
 
 merge 1:1 hh using "${temp}tempw.dta"
 drop _merge
 replace AGL = 0 if AGL==. 
 
 ************************************************************************************ 
 
 * Generate wealth
 gen wealth = H + AGE + C + S + Po + AGL
 
 gen hhid = hh
 replace hh = subinstr(hh, "H", "", .)
 replace hh = subinstr(hh, "-", "", .)
 destring hh, gen(HHID)
 drop hh
 rename HHID hh
 rename hhid HHID
 
 save "${temp}wealth.dta", replace 
 
 rm "${temp}tempw.dta"
 
 end
 
 ************************************************************************************
