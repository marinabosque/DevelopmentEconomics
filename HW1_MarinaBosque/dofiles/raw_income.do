 *--------------------------- Creating Income --------------------------*

 ***** Define Program 

 program define raw_income

 * Agricultural net production
 
 use "${data}AGSEC5A.dta", clear
 drop if cropID==.
 
 keep HHID parcelID plotID cropID a5aq6a a5aq6b a5aq6c a5aq6d a5aq16 a5aq7a a5aq7b a5aq7c a5aq7d a5aq8 a5aq10 a5aq5_2
 drop if a5aq6a==. & a5aq6d==. & a5aq16==. & a5aq7a==. & a5aq7d==. & a5aq8==. & a5aq10==. & a5aq5_2 ==2 // no revenue but crop was mature
 replace a5aq6d = a5aq7d if  a5aq6b == a5aq7b & a5aq6c== a5aq7c & a5aq6d != a5aq7d //conversion weights are the same for buy and sell 

 ** Harvested crop
 gen ANP1_t = .
 replace ANP1_t = a5aq6a*a5aq6d if a5aq6d!=.
 replace ANP1_t = a5aq6a if a5aq6c==1
 // all the ANP1_t = . are observations missing in a5aq6a-a5aq6d (10 obs)
 
 *replace a5aq16 = a5aq16/100 if a5aq16>=1
 *replace a5aq16 = 0 if a5aq16==.
 *replace ANP1_t = (1-a5aq16)*ANP1_t //total quantity - quantity lost 
 
 ** Harvested crop sold
 gen ANP2_t = .
 replace ANP2_t = a5aq7a*a5aq7d if a5aq7d!=.
 replace ANP2_t = 0 if a5aq7a==0
 replace ANP2_t = 0 if a5aq7a==.
 replace ANP2_t = a5aq7a if a5aq7c==1
 
 gen dif = (ANP1_t - ANP2_t) 
 replace ANP2_t = ANP1_t if dif<0

 bysort HHID cropID: egen ANP2 = sum(ANP2_t) //quantity sold by HH and crop
 bysort HHID cropID: egen ANP1 = sum(ANP1_t) //quantity by HH and crop
  
 bysort HHID cropID: egen ANP2_tt = sum(a5aq8) //revenue by HH and crop

 gen P_t = (ANP2_tt/ANP2)
 bysort cropID: egen P = mean(P_t)
 
 ** Value of retained output
 gen ANP1_2 = P*(ANP1 - ANP2) //46 missings due to P==.
 
 replace ANP1_2 = 0 if ANP1_2==. 
 replace ANP2_tt = 0 if ANP2_tt==. 
 
 ************************************************************************************ 

 ** Costs
 *** Transportation costs
 bysort HHID cropID: gen ANP3 = a5aq10 
 replace ANP3 = 0 if ANP3==. 

 collapse (mean) ANP1_2 ANP3 ANP2_tt, by(HHID cropID) 
 collapse (sum) ANP1_2 ANP3 ANP2_tt, by(HHID) 
 save "${temp}temp.dta", replace
 
 *** Rent-in land
 use "${data}AGSEC2B.dta", clear
 bysort HHID parcelID: gen ANP4 = a2bq9
 replace ANP4 = 0 if ANP4==. 

 collapse (sum) ANP4, by(HHID)
 merge 1:1 HHID using "${temp}temp.dta"
 drop _merge
 save "${temp}temp.dta", replace

 *** Hired labor
 use "${data}AGSEC3A.dta", clear
 bysort HHID parcelID plotID: gen ANP5 = a3aq36
 replace ANP5 = 0 if ANP5==. 
 
 *** Pesticides and fertilizers
 bysort HHID parcelID plotID: gen ANP6 = a3aq8 
 bysort HHID parcelID plotID: gen ANP7 = a3aq18 
 bysort HHID parcelID plotID: gen ANP8 = a3aq27 
 replace ANP6 = 0 if ANP6 ==. 
 replace ANP7 = 0 if ANP7==. 
 replace ANP8 = 0 if ANP8 ==. 
 
 collapse (sum) ANP*, by(HHID)
 merge 1:1 HHID using "${temp}temp.dta"
 drop _merge
 
 foreach var of varlist _all {
  replace `var' = 0 if `var'==.
 }
 
 save "${temp}temp.dta", replace
 
 *** Seeds
 use "${data}AGSEC4A.dta", clear
 bysort HHID parcelID plotID cropID: gen ANP9 = a4aq15 
 replace ANP9 = 0 if ANP9==. 

 collapse (sum) ANP*, by(HHID)
 merge 1:1 HHID using "${temp}temp.dta"
 drop _merge
 
 foreach var of varlist _all {
  replace `var' = 0 if `var'==.
 }
 
 save "${temp}temp.dta", replace

 gen ANP = ANP1_2 + ANP2_tt - ANP3 - ANP4 - ANP5 - ANP6 - ANP7 - ANP8 - ANP9
 save "${temp}temp.dta", replace
 
 ************************************************************************************ 

 * Livestock
 
 ** Other costs
 use "${data}AGSEC7.dta", clear
 
 keep if a7aq1 == 1 // we keep only those who own or raise cattle
 bysort HHID: egen LS7 = sum(a7bq2e) 
 bysort HHID: egen LS8 = sum(a7bq3f) 
 bysort HHID: egen LS9 = sum(a7bq5d) 
 bysort HHID: egen LS10 = sum(a7bq6c) 
 bysort HHID: egen LS11 = sum(a7bq7c) 
 bysort HHID: egen LS12 = sum(a7bq8c) 
 gen LS13 = LS7 + LS8 + LS9 + LS10 + LS11 + LS12
 
 collapse (mean) LS13, by(HHID)
 save "${temp}temp2.dta", replace
 
 ** Cattle
 use "${data}AGSEC6A.dta", clear
 keep if a6aq2 != 2 & a6aq3a != 0 & a6aq3a != . // we keep only those who own 

 gen LS1 = a6aq14a*a6aq14b if a6aq14a !=. & a6aq14a != 0  & a6aq14b !=. & a6aq14b !=0 //revenues = quantity * revenue by unit, only for those who sell and report value
 replace LS1 = 0 if LS1==.

 gen LS2 = . 
 replace LS2 = a6aq5c if a6aq5c >0 & a6aq5c != . //cost labor
 replace LS2 = 0 if LS2 ==. 

 collapse (sum) LS1 (mean) LS2, by(HHID)
 merge 1:1 HHID using "${temp}temp2.dta"
 drop _merge
 replace LS1 = 0 if LS1==. 
 replace LS2 = 0 if LS1==.
 save "${temp}temp2.dta", replace
 
 ** Small animals
 use "${data}AGSEC6B.dta", clear
 keep if a6bq2 != 2 & a6bq3a != 0 & a6bq3a != . // we keep only those who own 
 
 gen LS3 = .
 replace LS3 = a6bq14a*a6bq14b if a6bq14a !=. & a6bq14a != 0  & a6bq14b !=. & a6bq14b !=0 //revenues = quantity * revenue by unit
 replace LS3 = 0 if LS3==.
 
 gen LS4 = . 
 replace LS4 = a6bq5c if a6bq5c >0 & a6bq5c != . //cost labor
 replace LS4 = 0 if LS4 ==.  
 
 collapse (sum) LS3 (mean) LS4, by(HHID)
 merge 1:1 HHID using "${temp}temp2.dta"
 drop _merge
 replace LS3 = 0 if LS3 ==.
 replace LS4 = 0 if LS4 ==.
 save "${temp}temp2.dta", replace
 
 ** Rabbits
 use "${data}AGSEC6C.dta", clear
 keep if a6cq2 != 2 & a6cq3a != 0 & a6cq3a != . // we keep only those who own 
 
 gen LS5 = .
 replace LS5 = a6cq14a*a6cq14b if a6cq14a !=. & a6cq14a != 0  & a6cq14b !=. & a6cq14b !=0 //revenues = quantity * revenue by unit
 replace LS5 = 0 if LS5==.
 
 gen LS6 = . 
 replace LS6 = a6cq5c if a6cq5c >0 & a6cq5c != . 
 replace LS6 = 0 if LS6 ==. //cost labor
 
 collapse (sum) LS5 (mean) LS6, by(HHID)
 merge 1:1 HHID using "${temp}temp2.dta"
 drop _merge
 
  foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen LS = LS1 + LS3 + LS5 - LS2 - LS4 - LS6 - LS13
 save "${temp}temp2.dta", replace

 ************************************************************************************ 
 
 * Livestock product
 
 ** Meat
 use "${data}AGSEC8A.dta", clear

 gen Pm_t = .
 replace Pm_t = a8aq5/a8aq3 if a8aq1 != 0 & a8aq5 != 0 & a8aq5 !=. & a8aq3 != 0 & a8aq3 !=. //price = revenue/quantity
 bysort AGroup_ID: egen Pm = mean(Pm_t)

 gen LM =. 
 replace LM = Pm*((a8aq1*a8aq2)-a8aq3) + a8aq5 if a8aq5 !=. 
 replace LM = Pm *((a8aq1*a8aq2)-a8aq3) if a8aq5 ==.
 replace LM = a8aq5 if ((a8aq1*a8aq2)-a8aq3) == 0 & a8aq5 !=.
 replace LM = 0 if LM==.

 collapse (sum) LM, by(HHID)
 save "${temp}temp3.dta", replace

 ** Milk
 use "${data}AGSEC8B.dta", clear
 
 gen daily_milk = a8bq1* a8bq3 //number of animals milked * avg milk production/day
 replace daily_milk = 0 if daily_milk==.
 replace a8bq5_1 = daily_milk if a8bq5_1 > daily_milk & a8bq5_1!=0 & a8bq5_1!=. //sales = production, for those who report more sales than production

 replace a8bq7 = 0 if a8bq6==0 | a8bq6==.
 replace a8bq7 = a8bq6 if a8bq7>a8bq6 // sales = amount converted, for those who report selling more than they convert per day

 replace a8bq5_1 = daily_milk if daily_milk < a8bq5 & a8bq5_1!=0 & a8bq9!=0 & a8bq9!=. & a8bq6==0
 replace a8bq5 = 0 if daily_milk<a8bq5 & a8bq5_1!=0 & a8bq9!=0 & a8bq9!=.
 
 replace a8bq5_1 = a8bq5_1 * 30 * a8bq2
 replace a8bq7 = a8bq7 * 30 * a8bq2
 replace a8bq7 = 0 if a8bq5_1==a8bq1*a8bq2*30*a8bq3 // convert daily to yealry
 
 gen Pmi_t = .
 replace Pmi_t = a8bq9/(a8bq5_1+a8bq7) if a8bq1!=0 & a8bq5_1!=0 & a8bq5_1 !=. & a8bq9!=0 & a8bq9 !=.| a8bq1 != 0 & a8bq6 != 0 & a8bq6 != . & a8bq7 != 0 & a8bq7 !=. & a8bq9 != 0 & a8bq9 !=.
 //revenue/(quantity milk + quantity dairy) for those who milked, sold and earned or milked, converted to dairy, sold and earn.
 bysort AGroup_ID: egen Pmi = mean(Pmi_t)
 
 replace a8bq2 = a8bq2*30 //months*30
 gen Milk = a8bq1*a8bq2*a8bq3 //liters of milk = quantity cows * days * avg day production
 replace Milk = 0 if Milk ==. 

 replace a8bq7 = 0 if a8bq7 ==. 
 replace a8bq5_1 = 0 if a8bq5_1==. 
 gen dif = (Milk-(a8bq5_1+a8bq7)) //quantity milk production - quantity sold

 gen LMi = .
 replace LMi = Pmi*(Milk-(a8bq5_1+a8bq7))
 replace LMi = Pmi*(Milk-(a8bq5_1+a8bq7)) + a8bq9 if a8bq9!=. 
 replace LMi = a8bq9 if Milk-(a8bq5_1+a8bq7)==0 &  a8bq9!=. 

 collapse (sum) LMi, by(HHID)
 merge 1:1 HHID using "${temp}temp3.dta"
 drop _merge
 replace LMi = 0 if LMi==.
 
 save "${temp}temp3.dta", replace
 
 
 ** Eggs
 use "${data}AGSEC8C.dta", clear 
 replace a8cq2 = a8cq2*4 //quantity eggs by year
 replace a8cq3 = a8cq3*4 //quantity sold by year
 replace a8cq5 = a8cq5*4 //revenue by year

 replace a8cq3=a8cq2 if a8cq3 > a8cq2
 
 
 gen Pe_t = a8cq5/a8cq3 if a8cq1 != 0 & a8cq1 != 0 & a8cq2 !=. & a8cq2 !=0
 bysort AGroup_ID: egen Pe = mean(Pe_t)

 gen LE = .
 replace LE = Pe*(a8cq2 - a8cq3)
 replace LE = Pe*(a8cq2 - a8cq3) + a8cq5 if a8cq5 !=. 
 replace LE = 0 if LE==. 
 
 collapse (sum) LE, by(HHID)
 merge 1:1 HHID using "${temp}temp3.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 save "${temp}temp3.dta", replace
 
 
 ** Dung
 use "${data}AGSEC11.dta", clear
 
 gen LD = a11q1c + a11q5 //revenues dung + revenues ploughing
  
 collapse (sum) LD, by(HHID)
 merge 1:1 HHID using "${temp}temp3.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }

 gen LP = LM + LMi + LE + LD
 save "${temp}temp3.dta", replace
 
 ************************************************************************************ 
 
 * Renting in agricultural equipment and capital
 use "${data}AGSEC10.dta", clear
 
 rename a10q8 rentals //value rentals
 collapse (sum) rentals, by(HHID)
   
 merge 1:1 HHID using "${temp}temp.dta"
 drop _merge
 
 merge 1:1 HHID using "${temp}temp2.dta"
 drop _merge

 merge 1:1 HHID using "${temp}temp3.dta"
 drop _merge 
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen ANP_total = ANP + LS + LP - rentals
 
 save "${temp}ANP.dta", replace
 
 ************************************************************************************ 
 
 * Labor market income
 use "${data}GSEC8_1.dta", clear
 
 gen LMI1 = .
 replace LMI1 = (h8q31a+h8q31b)*56 if h8q31c==1 //assume 8hrs every day of the week
 replace LMI1 = (h8q31a+h8q31b)*4 if h8q31c==2 //assume 30 days per month
 replace LMI1 = (h8q31a+h8q31b) if h8q31c==3 //assume 4 weeks per month
 replace LMI1 = (h8q31a+h8q31b)/4 if h8q31c==4 //assume 4 weeks per month
 replace LMI1 = LMI1*h8q30b*h8q30a //earnings in last year
 // main job
 
 gen LMI2 = .
 replace LMI2 = (h8q45a+h8q45b)*56 if h8q45c==1 //assume 8hrs every day of the week
 replace LMI2 = (h8q45a+h8q45b)*4 if h8q45c==2 //assume 30 days per month
 replace LMI2 = (h8q45a+h8q45b) if h8q45c==3 //assume 4 weeks per month
 replace LMI2 = (h8q45a+h8q45b)/4 if h8q45c==4 //assume 4 weeks per month
 replace LMI2 = LMI2*h8q44b*h8q44 //earnings in last year
 //second job
 
 //use usual activity status?
 
 gen LMI = LMI1 + LMI2 //income per year
 replace LMI = 0 if LMI==. 
 collapse (sum) LMI, by(HHID)
 save "${temp}LMI.dta", replace

 ************************************************************************************ 
 
 * Business income
 use "${data}gsec12.dta", clear
 rename hhid HHID
 
 gen BI1 = .
 replace BI1 = h12q13 //month gross revenue
 replace BI1= 0 if BI1 ==. 

 gen BI2 = .
 replace BI2 = h12q15 //month labor costs
 replace BI2= 0 if BI2 ==. 
 
 gen BI3 = .
 replace BI3 = h12q16 + h12q17 //month expenditure raw materials + others
 replace BI3= 0 if BI3 ==. 
 
 gen BI = (BI1 - BI2 - BI3)*h12q12 //business income per year (ignore VAT)
 replace BI = 0 if BI ==. 
 collapse (sum) BI, by(HHID)
 save "${temp}BI.dta", replace
 
 
 ************************************************************************************ 
 
 * Other income sources
 use "${data}GSEC11A.dta", clear
  
 gen OIS = h11q5 + h11q6
 replace OIS = 0 if OIS==.
 
 collapse (sum) OIS, by(HHID)
 save "${temp}OIS.dta", replace

 ************************************************************************************ 
  
 * Transfers (from expenditures in consumption)
 use "${data}GSEC15B.dta", clear
 
 gen Tr = .
 replace Tr = h15bq10*h15bq11
 replace Tr = 0 if Tr==.
 
 collapse (sum) Tr, by(HHID)

 merge 1:1 HHID using "${temp}LMI.dta"
 drop _merge
  
 merge 1:1 HHID using "${temp}BI.dta"
 drop _merge

 merge 1:1 HHID using "${temp}OIS.dta"
 drop _merge 
  
 replace HHID = subinstr(HHID, "H", "", .)
 replace HHID = subinstr(HHID, "-", "", .)
 destring HHID, gen(hh)
 drop HHID
 rename hh HHID
 
 merge 1:1 HHID using "${temp}ANP.dta"
 drop _merge 
 rename HHID hh
 save "${temp}income.dta", replace
 
 
 ************************************************************************************ 
 ************************************************************************************ 
 ***************************** Agricultural second visit  *************************** 
 
 * Agricultural net production
 
 use "${data}AGSEC5B.dta", clear
 drop if cropID==.
 
 keep HHID parcelID plotID cropID a5bq6a a5bq6b a5bq6c a5bq6d a5bq16 a5bq7a a5bq7b a5bq7c a5bq7d a5bq8 a5bq10 a5bq5_2
 drop if a5bq6a==. & a5bq6d==. & a5bq16==. & a5bq7a==. & a5bq7d==. & a5bq8==. & a5bq10==. & a5bq5_2==2 // no revenue but crop was mature
 replace a5bq6d = a5bq7d if a5bq6b==a5bq7b & a5bq6c==a5bq7c & a5bq6d!=a5bq7d //conversion weights are the same for buy and sell 
 
 ** Harvested crop
 gen ANP1_t2 = .
 replace ANP1_t2 = a5bq6a*a5bq6d if a5bq6d!=.
 replace ANP1_t2  = a5bq6a if a5bq6c==1
  
 ** Harvested crop sold 
 gen ANP2_t2 = .
 replace ANP2_t2 = a5bq7a*a5bq7d if a5bq7d!=.
 replace ANP2_t2 = 0 if a5bq7a==0 
 replace ANP2_t2 = 0 if a5bq7a==. 
 replace ANP2_t2 = a5bq7a if a5bq7c==1
 
 gen dif = (ANP1_t2 - ANP2_t2)
 replace ANP2_t = ANP1_t2 if dif<0
 
 bysort HHID cropID: egen ANP2_2 = sum(ANP2_t2) //quantity sold by HH and crop
 bysort HHID cropID: egen ANP1_2 = sum(ANP1_t2) //quantity by HH and crop
  
 bysort HHID cropID: egen ANP2_tt2 = sum(a5bq8) //revenue by HH and crop

 gen P_t2 = (ANP2_tt2/ANP2_2)
 bysort cropID: egen P_2 = mean(P_t2)
 
// value of kept crops 
 gen ANP1_2_2 = P_2*(ANP1_2 - ANP2_2) 
 
 replace ANP1_2_2 = 0 if ANP1_2_2 == . 
 replace ANP2_tt2 = 0 if ANP2_tt2 == . 

 ************************************************************************************ 

 ** Costs
 *** Transportation costs
 bysort HHID cropID: gen ANP3_2 = a5bq10
 replace ANP3_2 = 0 if ANP3_2==.
  
 collapse (mean) ANP1_2_2 ANP3_2 ANP2_tt2, by(HHID cropID) 
 collapse (sum) ANP1_2_2 ANP3_2 ANP2_tt2, by(HHID) 
 save "${temp}temp_second.dta", replace
 
 *** Land rents are given as annual 

 *** Hired labor
 use "${data}AGSEC3B.dta", clear
 bysort HHID parcelID plotID: gen ANP5_2 = a3bq36
 replace ANP5_2= 0 if ANP5_2==. 
 
 *** Pesticides and fertilizers
 bysort HHID parcelID plotID: gen ANP6_2 = a3bq8 
 bysort HHID parcelID plotID: gen ANP7_2 = a3bq18 
 bysort HHID parcelID plotID: gen ANP8_2 = a3bq27 
 replace ANP6_2 = 0 if ANP6_2 == . 
 replace ANP7_2 = 0 if ANP7_2 == . 
 replace ANP8_2 = 0 if ANP8_2 == . 
 
 collapse (sum) ANP*, by(HHID)
 merge 1:1 HHID using "${temp}temp_second.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 save "${temp}temp_second.dta", replace
 
 *** Seeds
 use "${data}AGSEC4B.dta", clear
 bysort HHID parcelID plotID cropID: gen ANP9_2 = a4bq15 
 replace ANP9_2 = 0 if ANP9_2==. 
 
 collapse (sum) ANP*, by(HHID)
 merge 1:1 HHID using "${temp}temp_second.dta"
 drop _merge
 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 gen ANP_2 = ANP1_2_2 + ANP2_tt2 - ANP3_2 - ANP5_2 - ANP6_2 - ANP7_2 - ANP8_2 - ANP9_2
 rename HHID hh
 
 save "${temp}temp_second.dta", replace


 ************************************************************************************ 
 
 ** Merge with previous data to get annual income 
 merge 1:1 hh using "${temp}income.dta" // people who do not merge is because they have no ANP in second visit
 drop _merge 
 foreach var of varlist _all {
	replace `var' = 0 if `var'==.
 }
 
 * Generate income
 generate income = ANP_2 + ANP_total + LMI + BI + OIS
 
 save "${temp}income.dta", replace
 
 rm "${temp}temp.dta"
 rm "${temp}temp2.dta"
 rm "${temp}temp3.dta"
 rm "${temp}temp_second.dta"
 rm "${temp}BI.dta"
 rm "${temp}OIS.dta"
 rm "${temp}LMI.dta"
 rm "${temp}ANP.dta"

 end
 
 ************************************************************************************
