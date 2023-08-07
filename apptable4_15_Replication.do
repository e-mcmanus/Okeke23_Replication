
*******************************************************************************************************

** This file generates the Appendix tables A.4 to A.15

*******************************************************************************************************


global treat mlp doctor
global cont_ind cct i.magedum first hausa i.mschool auton car last gest
global cont_base $cont_ind male
global cont_hc hc_deliveries hc_cesarean hc_transfusion i.hc_clean
global cont_all $cont_base $cont_hc pastdeath hc_workers hc_open24hrs hc_equipment hc_beds hc_lab hc_drug hc_nopow hc_vent i.hc_cond
global patient agegroup? sex phone i.transport i.bhealth i.severity fever cough headache abd_pain weakness pregnancy order interr
	
/*-----------------------------------------------------------------------------
	Table A.4. 7-day mortality by whether medical care was received
------------------------------------------------------------------------------*/

clear
tempfile a b
save `a', emptyok
save `b', emptyok

quietly {

	foreach v in count sum mean {
		use "$data/child_tmpchanges", clear
		ren mort7 care
		loc var care
		collapse (`v') `var', by(clinictreat usedcare)
		reshape wide `var', i(clinictreat) j(usedcare)
		append using `a'
		save `a', replace
	}
	gsort clinict -`var'0
	by clinict: g id=_n
	save `a', replace
		

	foreach v in count sum mean {
		use "$data/child_tmpchanges", clear
		ren mort7 oth
		loc var oth
		collapse (`v') `var' if usedcare==1, by(clinictreat hc_usedcare)
		reshape wide `var', i(clinictreat) j(hc_usedcare)
		append using `b'
		save `b', replace
	}
	gsort clinict -`var'0
	by clinict: g id=_n
}
merge 1:1 clinict id using `a', nogen 
	
/*	
foreach v in count sum mean {
		use "$data/child_tmpchanges", clear
		ren mort7 doc
		loc var doc
		collapse (`v') `var' if usedcare==1, by(clinictreat doctorcare1)
		reshape wide `var', i(clinictreat) j(doctorcare1)
		append using `b'
		save `b', replace
	}
	gsort clinict -`var'0
	by clinict: g id=_n
}
merge 1:1 clinict id using `a', nogen 

*/
	label define id 1 "# children" 2 "# deaths within 1st week" 3 "Percent"
	label values id id
	order clinict id care? oth1 
	label var clinict " "
	label var id " "
	label var care0 "Care = No"
	label var care1 "Care at a facility= Yes"
	label var oth1 "Care at health centre= Yes"
	label var oth0 "Care at other facility= Yes"
	*label var doc0 "Doctor = No"
	*label var doc1 "Doctor = Yes"
export excel using "$out/apptab4", replace first(varl)


/*-----------------------------------------------------------------------------
	Table A.5. Effect on 30-day mortality
------------------------------------------------------------------------------*/
/*
use "$data/child", clear
	
	quietly {
		foreach y of varlist mort30 {
			eststo clear	
			
			eststo: reghdfe `y' $cont_base $cont_hc $treat, abs(strata qtr) cl(fid)
			sum `y' if control==1
			estadd r(mean)	
			
			eststo: reghdfe `y' $cont_base $cont_hc doctor if dose==1, abs(strata qtr) cl(fid)
			sum `y' if control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $cont_hc doctor if dose==2, abs(strata qtr) cl(fid)
			sum `y' if control==1
			estadd r(mean)
		}
	}
		
	#delimit;
		esttab using "$out/apptab5", replace keep(mlp doctor) b(%9.4f) se(%9.4f)
		noconstant label nonotes nostar eqlabels(" " " ") booktabs width(\hsize) 
		mtitles("Full sample" "Low dose" "High dose")
		scalars("mean Control group mean");
	#delimit cr	

	
/*-----------------------------------------------------------------------------
	Table A.6. Effect on deaths in utero
------------------------------------------------------------------------------*/

use "$data/woman", clear
	keep if consent==1
	quietly {
		eststo clear
		foreach y of varlist inutero {
			eststo: reghdfe `y' $cont_ind $cont_hc $treat, abs(strata) cl(fid)
			sum `y' if control==1
			estadd r(mean)	
			
			eststo: reghdfe `y' $cont_ind $cont_hc doctor if dose==1, abs(strata) cl(fid)
			sum `y' if control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_ind $cont_hc doctor if dose==2, abs(strata) cl(fid)
			sum `y' if control==1
			estadd r(mean)
		}
	}
	
	#delimit;
		esttab using "$out/apptab6", replace keep(mlp doctor) b(%9.4f) se(%9.4f)
		noconstant label nonotes nostar eqlabels(" " " ") booktabs width(\hsize) 
		mtitles("Full sample" "Low dose" "High dose" "Full sample" "Low dose" "High dose")
		scalars("mean Control group mean");
	#delimit cr	
		
	
/*-----------------------------------------------------------------------------
	Table A.7. 7-day mortality per 100 pregnancies
------------------------------------------------------------------------------*/

use "$data/woman", clear
	quietly {
		eststo clear
		foreach y of varlist mort {
			
			eststo: reghdfe `y' $cont_ind $cont_hc $treat, abs(strata) cl(fid)
			sum `y' if control==1
			estadd r(mean)	
			
			eststo: reghdfe `y' $cont_ind $cont_hc doctor if dose==1, abs(strata) cl(fid)
			sum `y' if control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_ind $cont_hc doctor if dose==2, abs(strata) cl(fid)
			sum `y' if control==1
			estadd r(mean)
		}
		}
	
	#delimit;
		esttab using "$out/apptab7", replace keep(mlp doctor) b(%9.4f) se(%9.4f)
		noconstant label nonotes nostar eqlabels(" " " ") booktabs width(\hsize) 
		mtitles("Full sample" "Low dose" "High dose")
		scalars("mean Control group mean");
	#delimit cr	
*/
*-----------------------------------------------------------------------------
	ADAPTEDa: Table A.8. Effect on birthweight - Truncated Regression
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	g lbw= birthwt<2.5 if birthwt<.
	
	//quietly {
		eststo clear
		foreach y of varlist birthwt {
			sum `y'
			eststo: truncreg `y' $treat i.strata, cl(fid) ll(`r(min)')
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			sum `y'
			eststo: truncreg `y' $cont_base $treat i.strata i.qtr, cl(fid) ll(`r(min)')
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			sum `y'
			eststo: truncreg `y' $cont_base $cont_hc $treat i.strata i.qtr, cl(fid) ll(`r(min)')
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
	//}
			
	#delimit ;
		esttab using "$out/apptab8a", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ")
		booktabs width(\hsize) 
		mgroups("Birthweight (kg)" "Birthweight $<$2.5kg", pattern(1 0 0  1 0 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean") 
		indicate("Basic controls = cct" "Extended controls = 2.hc_clean");	
	#delimit cr	
/*

/*-----------------------------------------------------------------------------
	Table A.8. Effect on birthweight
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	g lbw= birthwt<2.5 if birthwt<.
	
	quietly {
		eststo clear
		foreach y of varlist birthwt lbw {
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
				
			eststo: reghdfe `y' $cont_base $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
				
			eststo: reghdfe `y' $cont_base $cont_hc $treat , abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
	}
			
	#delimit ;
		esttab using "$out/apptab8", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ")
		booktabs width(\hsize) 
		mgroups("Birthweight (kg)" "Birthweight $<$2.5kg", pattern(1 0 0  1 0 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean") 
		indicate("Basic controls = cct" "Extended controls = 2.hc_clean");	
	#delimit cr	
*/

/*-----------------------------------------------------------------------------
	ADAPTEDa: Table A.9. Effect on child weight and length - Truncated Regression
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	//quietly {
	eststo clear
		foreach y of varlist weight length {
			cap drop log`y'
			g log`y'=ln(`y')
			sum log`y'
				eststo: truncreg log`y' $treat i.strata i.qtr, cl(fid) ll(`r(min)')
				sum log`y' if control==1
				estadd r(mean)
				
				eststo: truncreg log`y' $cont_base $treat i.strata i.qtr, cl(fid) ll(`r(min)')
				sum log`y' if control==1
				estadd r(mean)
				
				eststo: truncreg log`y' $cont_base $cont_hc $treat i.strata i.qtr, cl(fid) ll(`r(min)')
				sum log`y' if control==1
				estadd r(mean)
		}
	//}
	
	#delimit ;
		esttab using "$out/apptab9a", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ")
		booktabs width(\hsize) 
		mgroups("Ln (weight)" "Ln (height)", pattern(1 0 0 1 0 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean") 
		indicate("Basic controls = cct" "Extended controls = 2.hc_clean");
	#delimit cr	

	/*

/*-----------------------------------------------------------------------------
	Table A.9. Effect on child weight and length
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	quietly {
	eststo clear
		foreach y of varlist weight length {
			cap drop log`y'
			g log`y'=ln(`y')
				eststo: reghdfe log`y' $treat, abs(strata qtr) cl(fid)
				sum log`y' if control==1
				estadd r(mean)
				
				eststo: reghdfe log`y' $cont_base $treat, abs(strata qtr) cl(fid)
				sum log`y' if control==1
				estadd r(mean)
				
				eststo: reghdfe log`y' $cont_base $cont_hc $treat, abs(strata qtr) cl(fid)
				sum log`y' if control==1
				estadd r(mean)
		}
	}
	
	#delimit ;
		esttab using "$out/apptab9", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ")
		booktabs width(\hsize) 
		mgroups("Ln (weight)" "Ln (height)", pattern(1 0 0 1 0 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean") 
		indicate("Basic controls = cct" "Extended controls = 2.hc_clean");
	#delimit cr	


/*-----------------------------------------------------------------------------
	Table A.10. Effect of being observed on consultation length
------------------------------------------------------------------------------*/

use "$data/patient", clear
		
	quietly {
		g logdur=ln(duration)
		local y logdur
		eststo clear
		foreach i in 0 1 {
		eststo: reghdfe `y' $patient i.provider if observe==`i', abs(sid) cl(fid)
		sum `y' if e(sample)
		estadd r(mean)
		}
	}
		
	#delimit ;
		esttab using "$out/apptab10", replace keep(1.provider 2.provider) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ") 
		coeflabels(1.provider "New MLP" 2.provider "Doctor")
		booktabs width(\hsize) 
		mgroups("Observer was absent" "Observer was present", pattern(1 1) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	
		scalars("mean Dep. variable mean") ;
	#delimit cr

	
/*-----------------------------------------------------------------------------
	Table A.11. Effect on quality of obstetric care
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	g traction=cord==1 
	g uterotonic=0 
		foreach v of varlist injmed tabmed ivmed {
			replace uterotonic=1 if `v'==1
		}
	
	quietly {
		eststo clear
		foreach y of varlist uterotonic traction {
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $cont_hc $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
	}
	
	#delimit ;
		esttab using "$out/apptab11", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ")		
		mgroups("Uterotonic administration" "Cord traction", pattern(1 0 0 1 0 0)
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		booktabs width(\hsize) scalars("mean Control group mean") 
		indicate("Basic controls = cct" "Extended controls = 2.hc_clean");
	#delimit cr	
	

/*-----------------------------------------------------------------------------
	Table A.12. Effect on postpartum fever
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	quietly {
		eststo clear
		foreach y of varlist postpart2 {
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base doctor, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
		}
	}
		
	#delimit ;
		esttab using "$out/apptab12", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar nomtitles eqlabels(" " " ")		
		booktabs width(\hsize) 
		scalars("mean Control group mean") 
		indicate("Controls = cct");
	#delimit cr	
	

/*-----------------------------------------------------------------------------
	Table A.13. Innovation introduced by new providers
------------------------------------------------------------------------------*/

use "$data/impact", clear
	keep clinict ideas
	keep if ideas!=""
	g id=_n
	reshape wide ideas, i(id) j(clinict)

	foreach i in 1 2 {
		preserve
			 keep ideas`i'
			 drop if ideas`i'==""
			 g id=_n
			 tempfile ideas`i'
			 save `ideas`i''
		 restore
	 }
	
	use `ideas1'
	merge 1:1 id using `ideas2', nogen
		label var ideas1 "Mid-level Provider"
		label var ideas2 "Doctor"
		export excel ideas? using "$out/apptab13", replace first(varl)
		
/*-----------------------------------------------------------------------------
	Table A.14. Effects on utilization of medical care
------------------------------------------------------------------------------*/

use "$data/woman_tmpchanges", clear

	
		eststo clear
		foreach y of varlist usedcare {

			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_ind $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_ind $cont_hc $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
	
	
	cd "\\nask.man.ac.uk\home$\Documents\Norwich replication games\AER replication_NRG\output"
	
	#delimit ;
		esttab using "apptab14org", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant label nonotes nomtitles eqlabels(" " " ")
			star(* 0.10 ** 0.05 *** 0.01)
		booktabs width(\hsize) scalars("mean Control group mean") 
		indicate("Basic controls = cct" "Extended controls = 2.hc_clean");	
	#delimit cr	


*/
/*-----------------------------------------------------------------------------
	Table A.15. Is there evidence of changes in substitution patterns
------------------------------------------------------------------------------*/

use "$data/child_tmpchanges", clear

gen no_facility=facility==0
gen oth_facility=delplace>=3 & delplace<=9  & delplace!=5
order no_facility hc_facility oth_facility, last
	
quietly {
		eststo clear
		foreach y of varlist no_facility-oth_facility {		
			eststo: reghdfe `y' $cont_ind $cont_hc $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
      }
	  

/*	
	#delimit ;
		esttab using "apptab15", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant label nonotes eqlabels(" " " ")
		star(* 0.10 ** 0.05 *** 0.01)
		mtitles("At home" "Public hospital" "Health center"
		"Other public" "Private facility" "Other location")
		booktabs width(\hsize) scalars("mean Control group mean");
	#delimit cr	
	
*/	
	  
#delimit ;
		esttab using "apptab15", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant label nonotes eqlabels(" " " ") 
		star(* 0.10 ** 0.05 *** 0.01)
		mtitles("Not facility" "Health center" "Other facility")
		rtf width(\hsize) scalars("mean Control group mean");
	#delimit cr	


	
*/



	
