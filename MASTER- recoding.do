


**Recoding notes -  dataprep recoded lines 156-177; saved as dataprep_tmpchanges//
**apptable4_15 recoded lines 19-82 and 416-450; saved as apptable4_15_tmpchanges


/*==================================================================================================
Project: 	When a Doctor Falls from the Sky: The Impact of Easing Doctor Supply Constraints on Mortality 
Author: 	Edward Okeke  
Purpose:	This is the master code to replicate all of the tables and figures in the paper
----------------------------------------------------------------------------------------------------
Index:		A. Install Programs
			B. Set Path Directories
			C. Set Options for Replication
			D. Execute Programs
	
===================================================================================================*/

clear all
set more off

/*===============================================================================================
                                  A. Install Programs 
===============================================================================================*/

* Note: You will need the program "dsregress" for the double-lasso estimation. It is available in Stata 17. If you do not have Stata 17 comment out Rows 110-112 (Table 4) and Row 138 (Table 5) in tables.do 

foreach program in cibar estout ftools ivreg2 ivreghdfe ranktest reghdfe spmap {
	ssc install `program', all replace
}
net install dm88_1.pkg,  all replace from (http://www.stata-journal.com/software/sj5-4)
net install grc1leg2, all replace from (http://digital.cgdev.org/doc/stata/MO/Misc)


/*===============================================================================================
                                  B. Set Path Directories
===============================================================================================*/

global main "" // Set the path to the main replication folder
global do "$main/dofiles"
global raw "$main/data/raw"
global proc "$main/data/intermediate"
global data "$main/data/analysis"
global out "$main/output"

/*===============================================================================================
                                  C. Set Options for Replication
===============================================================================================*/

local clean=1	// Switch this option to zero if you do not want to run the data cleaning code
local prep=1	// Switch this option to zero if you do not want to run the code preparing the analysis files
local tables=0 	// Switch this option to zero if you do not want to run the code replicating the tables
local figures=0 // Switch this option to zero if you do not want to run the code replicating the figures
local apptab=1 	// Switch this option to zero if you do not want to run the code replicating the appendix tables 
local appfig=0 	// Switch this option to zero if you do not want to run the code replicating the appendix figures

/*===============================================================================================
                                  D. Execute Programs
===============================================================================================*/

** Clean the data. This step is optional

	if `clean'==1 {
		do "$do/clean.do"
	}
	
** Create analytical files. This step is optional

	if `prep'==1 {
		do "$do/dataprep_tmpchanges.do"
	}

** Generate the main tables 

	if `tables'==1 {
		do "$do/table1.do"			// generates Table 1
		do "$do/tables.do"			// generates all the other Tables
	}

** Generate the main figures

	if `figures'==1 {
		do "$do/figures.do"
	}

** Generate the appendix tables

	if `apptab'==1 {
		*do "$do/apptable2_3.do"		// Tables A.2 and A.3
		do "$do/apptable4_15_tmpchanges.do"	// Tables A.4 to A.15
		*do "$do/apptable16.do"	 	// Table A.16
		*do "$do/apptable17_18.do"	// Tables A.17 and A.18
	}

** Generate the appendix figures

	if `appfig' == 1 {
		do "$do/appfigures.do"
	}










