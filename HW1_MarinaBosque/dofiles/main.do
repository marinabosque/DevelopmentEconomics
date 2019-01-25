
 ***********************************************************************************  
 *     T H I S  P R O G R A M    C O M P U T E S   F I N A L    R E S U L T S      *
 ***********************************************************************************

 ///////////////////////////////////////////////////////////////////////////////////
 ///                                                                             ///
 ///  This main program and all its subordinated files include all the code that ///
 ///  is needed to replicate the results. 										 ///	
 ///																			 ///
 ///////////////////////////////////////////////////////////////////////////////////
 
 
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
	
	
  ***** Paths
  
  *global code "Please insert here you working directory for code folder"
  global code "/Users/marinabosque/Documents/Master CEMFI/Second Course - Fifth Term/Development Economics/ProblemSet1/"
  
  global dofiles "${code}dofiles/"
  
  global data "${code}data/UGA_2013_UNPS_v01_M_STATA/"
  global temp "${code}data/temp/"
  global output "${code}data/output/"
  
  global figures "${code}figures/"


 ****************************     M A I N   P R O G R A M    ***********************
	
  **** Read programs
 
	capture program drop _all
	quietly {	
		do "${dofiles}raw_consumption.do"
		do "${dofiles}raw_income.do"
		do "${dofiles}raw_wealth.do"
		do "${dofiles}final_dataset.do"
		
		do "${dofiles}question1.do"
		do "${dofiles}question2.do"
		do "${dofiles}question3.do"
	}

  **** Execute programs
 	
	global qui "qui" // Execute the program silenty
 	
	** Consumption 
	raw_consumption
	
	** Income
	raw_income
	
	** Wealth
	raw_wealth
	
	** Final dataset
	final_dataset
	
	** Questions
	question1
	question2
	question3

		
************************************************************************************

