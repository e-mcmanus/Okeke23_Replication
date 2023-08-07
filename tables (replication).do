
*******************************************************************************************************

** This file generates the main tables in the Paper

*******************************************************************************************************

clear
set more off

global treat mlp doctor
global cont_ind cct i.magedum first hausa i.mschool auton car last gest
global cont_ind2 cct age priorb i.ethnicity i.mschool auton car last gest
global cont_base $cont_ind male
global cont_base2 $cont_ind2 male
global cont_hc hc_deliveries hc_cesarean hc_transfusion i.hc_clean
global cont_hc2 pregprob* i.hc_cond i.hc_clean hc_*
global cont_all $cont_base $cont_hc pastdeath hc_workers hc_open24hrs hc_equipment hc_beds hc_lab hc_drug hc_nopow hc_vent i.hc_cond
global cont_all2 $cont_base2 $cont_hc2 pastdeath
global patient agegroup? sex phone i.transport i.bhealth i.severity fever cough headache abd_pain weakness pregnancy order interr


/*-----------------------------------------------------------------------------
	Table 2. Effect of the intervention on supply
------------------------------------------------------------------------------*/

use "$data/staffing", clear

	quietly {
		eststo clear
		foreach y of varlist staff doctor {
			eststo: reg `y' clinict##visit if visit>1, cl(fid)
			sum `y' if e(sample) & clinict==0
			estadd r(mean)
			
			eststo: reghdfe `y' clinict##visit if visit>1, abs(strata) cl(fid)
			sum `y' if e(sample) & clinict==0
			estadd r(mean)
		}
	}
		
	#delimit ;
		esttab using "$out/table2", replace b(%9.3f) se(%9.3f)
		keep(1.clinictreat 2.clinictreat 3.visit 1.clinictreat#3.visit 2.clinictreat#3.visit)
		noconstant label nonotes nostar nomtitles eqlabels(" " " ") 
		coeflabels(1.clinictreat "MLP Arm" 2.clinictreat "Doctor Arm"
		3.visit "T2" 1.clinictreat#3.visit "MLP Arm x T2" 2.clinictreat#3.visit "Doctor Arm x T2")
		booktabs width(\hsize) mgroups("Number of health providers" "Doctor available", pattern(1 0 1 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	
		scalars("mean Control group mean");
	#delimit cr	
	

/*-----------------------------------------------------------------------------
	Table 3. Effect on probability that health care was provided by a doctor
------------------------------------------------------------------------------*/

use "$data/woman", clear

	quietly {
		eststo clear
		local cond card==1
		foreach y of varlist doctorcare1 {
			eststo: reghdfe `y' $treat if `cond', abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: reghdfe `y' $cont_ind $treat if `cond', abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
		foreach y of varlist doctorcare2 {
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: reghdfe `y' $cont_ind $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}			
	}
	
	#delimit ;
		esttab using "$out/table3", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant label nonotes nostar nomtitles eqlabels(" " " ") 
		booktabs width(\hsize) mgroups("Card" "Self-report", pattern(1 0 1 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean") indicate("Controls = cct");
	#delimit cr	
	
	
	/*-----------------------------------------------------------------------------
	ADAPTEDa: Table 3. Effect on probability that health care was provided by a doctor - altered & additional controls
------------------------------------------------------------------------------*/

use "$data/woman", clear

	//quietly {
		eststo clear
		local cond card==1
		foreach y of varlist doctorcare1 {
			eststo: reghdfe `y' $treat if `cond', abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Original"
			
			eststo: reghdfe `y' $cont_ind $treat if `cond', abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Original"
			
			eststo: reghdfe `y' $cont_ind2 $treat if `cond', abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Replicated"
			
			eststo: reghdfe `y' $cont_ind2 $cont_hc2 $treat if `cond', abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Replicated"
		}
		foreach y of varlist doctorcare2 {
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Original"
			
			eststo: reghdfe `y' $cont_ind $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Original"
			
			eststo: reghdfe `y' $cont_ind2 $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Replicated"
			
			eststo: reghdfe `y' $cont_ind2 $cont_hc2 $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			estadd local type "Replicated"
		}			
	//}
	// some adjusted controls including age instead of age dummies & ethnicity dummies instead of just for hausa...
	// some additional controls including priorb and dummies regarding pregnancy problems and health center facilities leads to larger coefficient on DOCTOR
	
	#delimit ;
		esttab using "$out/table3a", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant label nonotes nostar nomtitles eqlabels(" " " ") 
		booktabs width(\hsize) mgroups("Card" "Self-report", pattern(1 0 1 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean" type) indicate("Controls = cct");
	#delimit cr	

	
/*-----------------------------------------------------------------------------
	Table 4. Effect on 7-day mortality
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	//quietly {
		set seed 4321
		eststo clear
		foreach y of varlist mort7 {
			
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $cont_hc $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: dsregress `y' $treat, controls(i.(strata qtr) $cont_all) vce(cluster fid) selection(adaptive)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
		}
	//}
	
	#delimit;
		esttab using "$out/table4", replace keep($treat) b(%9.4f) se(%9.4f)
		noconstant label nonotes nostar eqlabels(" " " ") 
		mtitles("No controls" "Basic controls" "Extended controls" "Double-Lasso")
		booktabs width(\hsize) scalars("mean Control group mean");
	#delimit cr	

	
	/*-----------------------------------------------------------------------------
	ADAPTEDa: Table 4. Effect on 7-day mortality - altered & additional controls
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	//quietly {
		set seed 4321
		eststo clear
		foreach y of varlist mort7 {
			
			eststo: reghdfe `y' $treat, abs(strata) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base2 $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reghdfe `y' $cont_base $cont_hc $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: reghdfe `y' $cont_base2 $cont_hc2 $treat, abs(strata qtr) cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: dsregress `y' $treat, controls(i.(strata qtr) $cont_all) vce(cluster fid) selection(adaptive)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: dsregress `y' $treat, controls(i.(strata qtr) $cont_all2) vce(cluster fid) selection(adaptive)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
		}
	//}
	
	#delimit;
		esttab using "$out/table4a", replace keep($treat) b(%9.4f) se(%9.4f)
		noconstant label nonotes nostar eqlabels(" " " ") 
		mtitles("No controls" "Basic controls" "Extended controls" "Double-Lasso", pattern(1 1 0 1 0 1 0))
		booktabs width(\hsize) scalars("mean Control group mean");
	#delimit cr	
	
/*-----------------------------------------------------------------------------
	Table 5. Effect on 7-day mortality by treatment dosage
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	//quietly {
		g a=1
		foreach y of varlist mort7 {
		eststo clear
			foreach  i of numlist 1/2 {
				eststo: reghdfe `y' doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base $cont_hc doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: dsregress mort7 a doctor if dose==`i', controls(i.(strata qtr) $cont_all) vce(cluster fid)
			}
		}
	//}
			
		#delimit ;
			esttab using "$out/table5", replace keep(doctor) b(%9.3f) se(%9.3f)
			noconstant nonotes label nostar nomtitles eqlabels(" " " ")
			booktabs width(\hsize) mgroups("Low dose " "High dose", pattern(1 0 0 0 1 0 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
			indicate("Basic controls = cct" "Extended controls = 2.hc_clean" );	
			drop a;
		#delimit cr	
		
/*-----------------------------------------------------------------------------
	ADAPTEDa:Table 5. Effect on 7-day mortality by treatment dosage - altered & additional controls
------------------------------------------------------------------------------*/

use "$data/child", clear
	
	//quietly {
		g a=1
		foreach y of varlist mort7 {
		eststo clear
			foreach  i of numlist 1/2 {
				eststo: reghdfe `y' doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base2 doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base $cont_hc doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base2 $cont_hc2 doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: dsregress mort7 a doctor if dose==`i', controls(i.(strata qtr) $cont_all) vce(cluster fid)
				eststo: dsregress mort7 a doctor if dose==`i', controls(i.(strata qtr) $cont_all2) vce(cluster fid)
			}
		}
	//}
			
		#delimit ;
			esttab using "$out/table5a", replace keep(doctor) b(%9.3f) se(%9.3f)
			noconstant nonotes label nostar nomtitles eqlabels(" " " ")
			booktabs width(\hsize) mgroups("Low dose " "High dose", pattern(1 0 0 0 1 0 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
			indicate("Basic controls = cct" "Extended controls = 2.hc_clean" );	
			drop a;
		#delimit cr	
		
/*-----------------------------------------------------------------------------
	ADAPTEDb: Table 5. Effect on 7-day mortality by treatment dosage - Interaction rather than split sample
------------------------------------------------------------------------------*/

use "$data/child", clear
	*** replace dosage to zero if dosage is given as a negative value 
	replace dosage=0 if dosage<0
	
	//quietly {
		g a=1
		foreach y of varlist mort7 {
		eststo clear
				eststo: reghdfe `y' i.doctor##c.dosage, abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base i.doctor##c.dosage, abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base $cont_hc i.doctor##c.dosage, abs(strata qtr) cl(fid)
				eststo: dsregress mort7 a i.doctor##c.dosage, controls(i.(strata qtr) $cont_all) vce(cluster fid)
			}
	//}
			
		#delimit ;
			esttab using "$out/table5b", replace keep(1.doctor* dosage*) b(%9.3f) se(%9.3f)
			noconstant nonotes label nostar nomtitles eqlabels(" " " ")
			booktabs width(\hsize) mgroups("Low dose " "High dose", pattern(1 0 0 0 1 0 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
			indicate("Basic controls = cct" "Extended controls = 2.hc_clean" );	
			drop a;
		#delimit cr	

///// Marginsplot /////////
		eststo: reghdfe mort7 $cont_base $cont_hc i.doctor##c.dosage, abs(strata qtr) cl(fid)
				margins, dydx(doctor) at(dosage=(0(1)10)) atmeans level(95)
				marginsplot, name(dosage, replace) title("Marginal Effect of Doctor for different dosage (with 95% CIs)") xtitle("Dosage (Months)") ytitle(Effects of Doctor on linear prediction)

////// Low, middle & High dosage ////////
	g dose3=1 if dosage<.
	qui sum dosage, det
	replace dose3=2 if dosage>3 & dosage<=6 & dose3==1
	replace dose3=3 if dosage>6 & dose3==1
	label define dose3  1 "Low" 2 "middle" 3 "high", modify
	label values dose3 dose3
	label var dose3 "Treatment dose"

g a=1
foreach y of varlist mort7 {
		eststo clear
			foreach  i of numlist 1/3 {
				eststo: reghdfe `y' doctor if dose3==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base doctor if dose3==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base $cont_hc doctor if dose3==`i', abs(strata qtr) cl(fid)
				eststo: dsregress mort7 a doctor if dose3==`i', controls(i.(strata qtr) $cont_all) vce(cluster fid)
			}
		}				

		/*-----------------------------------------------------------------------------
	ADAPTEDc: Table 5. Effect on 7-day mortality by treatment dosage - Modified definition of high dosage
------------------------------------------------------------------------------*/

	g dose2=1 if dosage<.
	qui sum dosage, det
	replace dose2=2 if dosage>6 & dose2==1
	label define dose2  1 "Low" 2 "High", modify
	label values dose2 dose2
	label var dose2 "Treatment dose"

g a=1
foreach y of varlist mort7 {
		eststo clear
			foreach  i of numlist 1/2 {
				eststo: reghdfe `y' doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' doctor if dose2==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base doctor if dose2==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base $cont_hc doctor if dose==`i', abs(strata qtr) cl(fid)
				eststo: reghdfe `y' $cont_base $cont_hc doctor if dose2==`i', abs(strata qtr) cl(fid)
				eststo: dsregress mort7 a doctor if dose==`i', controls(i.(strata qtr) $cont_all) vce(cluster fid)
				eststo: dsregress mort7 a doctor if dose2==`i', controls(i.(strata qtr) $cont_all) vce(cluster fid)
			}
		}
		#delimit ;
			esttab using "$out/table5c", replace keep(doctor) b(%9.3f) se(%9.3f)
			noconstant nonotes label nostar nomtitles eqlabels(" " " ")
			booktabs width(\hsize) mgroups("Low dose " "High dose", pattern(1 0 0 0 1 0 0 0) 
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
			indicate("Basic controls = cct" "Extended controls = 2.hc_clean" );	
			drop a;
		#delimit cr	


/*-----------------------------------------------------------------------------
	Table 6. Effect on observed quality of treatment
------------------------------------------------------------------------------*/

use "$data/patient", clear

	egen patientcom=rowmean(comm1-comm5 comm7-comm9)
	g logdur=ln(duration)
	g logfever_perc=log(fever_perc)
		// log fever_perc (to normalise distribution) makes little difference 
	quietly {
		eststo clear
		foreach y of varlist logfever_perc exam diag inject antibio logdur patientcom {
			eststo: reghdfe `y' $patient i.provider if observe==1, abs(sid) cl(fid)
			sum `y' if e(sample)
			estadd r(mean)
		}
	}
		
	#delimit ;
		esttab using "$out/table6", replace keep(1.provider 2.provider) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar eqlabels(" " " ")
		coeflabels(1.provider "New MLP" 2.provider "Doctor")
		mtitles ("\shortstack{Adherence to\\fever protocol}" "\shortstack{Carried out\\physical exam}" 
		"\shortstack{Made a\\diagnosis}" "\shortstack{Prescribed\\injection}"
		"\shortstack{Prescribed\\antibiotic}" "\shortstack{Log of consultation\\time}"
		"\shortstack{Patient\\communication}") booktabs width(\hsize) 
		mgroups("Good clinical practice" "Bad clinical practice", pattern(1 0 0 1 0 1 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	
		scalars("mean Dep. variable mean") ;
	#delimit cr	


/*-----------------------------------------------------------------------------
	Table 7. Qualitative impacts of the new provider
------------------------------------------------------------------------------*/

use "$data/impact", clear
	
	quietly {
		eststo clear
		foreach y in impacthow7 impacthow1 impacthow2 impacthow3 impacthow6 impacthow4 impacthow5 {
			eststo: reghdfe `y' i.clinict, abs(sid) 
			sum `y' if e(sample) & clinict==1
			estadd r(mean)
		}
	}
		
	#delimit;
		esttab using "$out/table7", replace keep(2.clinictreat) b(%9.3f) se(%9.3f)
		noconstant label nonotes nostar eqlabels(" " " ")	
		coeflabel(2.clinictreat "Doctor")
		mtitles ("\shortstack{Made work\\environment\\more pleasant}"
			"\shortstack{Reduce workload\\of other\\providers}" 
			"\shortstack{Allowed facility\\to extend\\hours}" 
			"\shortstack{Allowed facility\\to provide\\more services}"
			"\shortstack{Challenged others\\to be more\\hardworking}"
			"\shortstack{Helped other\\providers improve\\knowledge/skills}"
			"\shortstack{Introduced new\\ways of\\doing things}")
		booktabs width(\hsize) scalars("mean Control mean");
	#delimit cr	
	
// probit models
		eststo clear
		foreach y in impacthow7 impacthow1 impacthow2 impacthow3 impacthow6 impacthow4 impacthow5 {
			eststo: logit `y' i.clinict i.sid
			sum `y' if e(sample) & clinict==1
			estadd r(mean)
		}


/*-----------------------------------------------------------------------------
	Table 8. Provider quality and infant mortality (IV Analysis)
------------------------------------------------------------------------------*/

use "$data/provider", clear
	
* Merge with outcomes data 

	duplicates drop fid, force
	keep fid avg* 
	merge 1:m fid using "$data/child", nogen

* Regression
	
	replace avgqscore=avgqscore/10
	quietly {
		eststo clear
		foreach y of varlist mort7 {
			* OLS
			foreach x in avgqscore avgqindex {				
				eststo: reghdfe `y' `x' $cont_hc $cont_base, abs(strata qtr) cl(fid)
				sum `y' if e(sample) & control==1
				estadd r(mean)
			}
			*  IV
			foreach x in avgqscore avgqindex {	
				eststo: ivreghdfe `y' $cont_hc $cont_base (`x' = doctor) , abs(strata qtr) cl(fid)
				sum `y' if e(sample) & control==1
				estadd r(mean)
			}
		}
	}
		
	#delimit ;
		esttab using "$out/table8", replace keep(avg*) b(%9.4f) se(%9.4f) 
		noconstant nomtitles nonotes nostar eqlabels(" " " ")	
		coeflabel(avgqscore "Proficiency score (\%)" 
		avgqindex "Standardized proficiency") booktabs width(\hsize) 
		mgroups("OLS" "IV", pattern(1 0 1 0)
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("rkf First-stage F-statistic" "mean Control group mean");
	#delimit cr
	
/*-----------------------------------------------------------------------------
	ADAPTEDa: Table 8. Provider quality and infant mortality (IV Analysis) - altered & additional controls
------------------------------------------------------------------------------*/

use "$data/provider", clear
	
* Merge with outcomes data 

	duplicates drop fid, force
	keep fid avg* 
	merge 1:m fid using "$data/child", nogen

* Regression
	
	replace avgqscore=avgqscore/10
	//quietly {
		eststo clear
		foreach y of varlist mort7 {
			* OLS
			foreach x in avgqscore avgqindex {				
				eststo: reghdfe `y' `x' $cont_hc $cont_base, abs(strata qtr) cl(fid)
				sum `y' if e(sample) & control==1
				estadd r(mean)
				estadd local type "Orginal"
				eststo: reghdfe `y' `x' $cont_hc2 $cont_base2, abs(strata qtr) cl(fid)
				sum `y' if e(sample) & control==1
				estadd r(mean)
				estadd local type "Replicated"
			}
			*  IV
			foreach x in avgqscore avgqindex {
				eststo: ivreghdfe `y' $cont_hc $cont_base (`x' = doctor) , abs(strata qtr) cl(fid)
				sum `y' if e(sample) & control==1
				estadd r(mean)
				estadd local type "Orginal"
				eststo: ivreghdfe `y' $cont_hc2 $cont_base2 (`x' = doctor) , abs(strata qtr) cl(fid)
				sum `y' if e(sample) & control==1
				estadd r(mean)
				estadd local type "Replicated"
			}
		}
	//}
		
	#delimit ;
		esttab using "$out/table8a", replace keep(avg*) b(%9.4f) se(%9.4f) 
		noconstant nomtitles nonotes nostar eqlabels(" " " ")	
		coeflabel(avgqscore "Proficiency score (\%)" 
		avgqindex "Standardized proficiency") booktabs width(\hsize) 
		mgroups("OLS" "OLS" "IV" "IV", pattern(1 0 1 0 1 0 1 0)
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("rkf First-stage F-statistic" "mean Control group mean" type);
	#delimit cr

	



