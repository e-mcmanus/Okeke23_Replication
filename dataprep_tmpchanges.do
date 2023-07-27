*******************************************************************************************************

** This file prepares the analytical datasets 

*******************************************************************************************************


/*---------------------------------------------------------------
	Get outcomes data
---------------------------------------------------------------*/

use "$proc/woman_el", clear

/*---------------------------------------------------------------
	Merge in provider start/end dates
---------------------------------------------------------------*/

merge m:1 fid using "$raw/dates", assert(1 3) nogen
	

/*-------------------------------------------------------------------------
	Merge in baseline clinic data to get service clinic characteristics
--------------------------------------------------------------------------*/

tempfile facility master
preserve
	use "$proc/facility_bl", clear

	g nopower=electric==3
	label var nopower "Facility has no source of electricity"
	
	egen equipment=rowmean(equip_*)
	label var equipment "Percent of essential equipment"
	
	egen deliveries=rowmean(births_m?)
	label var deliveries "Average number of deliveries per month in the last 6 months"
	
	keep fid water nopower beds workers lab drugs open24hrs travel_time cesarean transfusion equipment deliveries cond clean vent
	renvars *, pref(hc_)
	ren hc_fid fid
	save `facility'
restore

merge m:1 fid using `facility', nogen

save `master', replace

/*-------------------------------------------------------------------------
	Merge in demographics from enrollment survey
--------------------------------------------------------------------------*/

use "$proc/woman_bl", clear

* Age dummies
	recode age (10/17=1 "Less than 18") (18/24=2 "18-24 years") (25/29=3 "25-29 years") (30/34=4 "30-34 years") (35/120=5 "35 and older"), g(magedum)
	
* Mother's educational attainment
	recode schooling (1 17=1 "None") (2/7=2 "Some primary") (8/13=3 "Some secondary") (14/16=4 "Some tertiary" ), g(mschool)
	replace mschool=1 if education==0
	label var mschool "Mother's schooling"
	qui tab mschool, g(mschool)
	label var mschool1 "No formal schooling"
	label var mschool2 "Some primary schooling"
	label var mschool3 "Some secondary schooling"
	label var mschool4 "Some tertiary schooling"

* Literacy
	recode read (2=1 "Read part") (3=2 "Read whole") (else=0 "Can't read"), g(literacy)
	label var literacy "Mother's reading level"
	g notread=literac==0
	label var notread "Cannot read"

* Ethnicity
	g hausa=ethnicity<=2
	label var hausa "Hausa/Fulani ethnicity"

* Religion
	ge moslem=religion==5 if religion<.
	label var moslem "Religion is Islam"

* Autonomy
	ge autonomy=decide2==2 
	label var autonomy "Husband makes health-care decisions"
	
* First birth
	g first=priorb==0 if priorb<.
	label var first "First birth"

* Last delivery in a health facility
	g last=lastbfac==1
	label var last "Last birth in health facility"

* Household assets 
	egen asset=rowtotal(radio-fridge)
	label var asset "Household assets (out of 11)"

* Merge in follow-up data

	local var wid blmth gest age magedum hausa moslem mschool* notread autonomy priorb first pastdeath last hhsize car asset
	keep `var'
	order `var'
	merge 1:m wid using `master', nogen

/*-------------------------------------------------------------------------
	Create analysis variables
--------------------------------------------------------------------------*/

* Attrition
	ge attrit=consent==0 | follow==0
	label var attrit "Dropped out from study"

* Place of delivery

	loc cond consent==1
	loc var delplace
	g `var'1=inlist(`var',1,2) if `cond'
	g `var'2=inlist(`var',3,4) if `cond'
	g `var'3=inlist(`var',5) if `cond'
	g `var'4=inlist(`var',6,7,8) if `cond'
	g `var'5=inlist(`var',9) if `cond'
	g `var'6=inlist(`var',10,11,12,13) if `cond'
	order `var'?, after(`var')
	foreach v of varlist delplace? {
		label values `v' yesno
	}
	label var `var'1 "At home"
	label var `var'2 "Government hospital"
	label var `var'3 "Health center"
	label var `var'4 "Other health center"
	label var `var'5 "Private hospital/clinic"
	label var `var'6 "Other location"

	
	
	ge facility=0 if consent==1
	replace facility=1 if delplace>=3 & delplace<=9 
	label var facility "Gave birth in a hospital/clinic"
	label values facility yesno
		
		
* Received medical care during pregnancy

	tempvar anc3 ancfacility
	g `ancfacility'=0 if anc<. 
	foreach i of numlist 3 4 6 5 7 8 9 {
		replace `ancfacility'=1 if ancplace`i'==1
	}
	g `anc3'=ancvisit>=3 & ancvisit<. if `ancfacility'<. // completed at least 3 prenatal visits
	replace `anc3'=0 if `ancfacility'==0
	
	g usedcare=0 if consent==1
	replace usedcare=1 if (facility==1 | `anc3'==1 ) & usedcare==0
	
	drop `anc3'
	
* Health centre delivery

	ge hc_facility=0 if consent==1
	replace hc_facility=1 if delplace==5 
	label var hc_facility "Gave birth in a health centre"
	label values hc_facility yesno
	
**Received care during pregnancy at health center
	tempvar anc3 ancfacility
	g `ancfacility'=0 if anc<. 
	foreach i of numlist 5 {
		replace `ancfacility'=1 if ancplace`i'==1
	}
	g `anc3'=ancvisit>=3 & ancvisit<. if `ancfacility'<. // completed at least 3 prenatal visits
	replace `anc3'=0 if `ancfacility'==0
	
	gen hc_usedcare=0 if consent==1
	replace hc_usedcare=1 if (hc_facility==1 | `anc3'==1) & hc_usedcare==0

	
	label var usedcare "Received medical care at a facility"
	label var hc_usedcare "Received medical care at health centre"

* Received care from doctor
	g doctorcare1= carddoc1==1 | carddoc2==1 if consent==1
	g doctorcare2= ancprov1==1 | delprov1==1 if consent==1
	label var doctorcare1 "Received care from doctor (card)"
	label var doctorcare2 "Received care from doctor (self-report)"

* Number of months exposed to the intervention

* First estimate the start month of the pregnancy
	
	g pstart=month-10 if outcome==1		// use standard duration if reported as birth
	replace pstart=month-pregmths if inlist(outcome,2,3) & pregmths<. // use pregnancy age at termination if pregnancy terminated early
	replace pstart=month-round(pregweeks/4) if inlist(outcome,2,3) & pregweeks<.	
	replace pstart=blmth-gest if consent==0 | outcome==4	// use gestational age at enrollment if no consent or died during pregnancy
	replace pstart=blmth-gest if pstart==. & outcome<.	// use gestational age at enrollment if missing date  
	
* Then calculate dosage 
 
	* If preg end date is before provider start date: end date-start date
	 g dosage=month-startd if month<. & month<startd
	* If preg end date is after provider start date: min(posting end date, preg end date)-max(posting start date, preg start date)
	replace dosage=min(stopd,month)-max(startd,pstart) if month<. & month>=startd
	* Code as 0 if no provider posted
	replace dosage=0 if duration==0 
	drop pstart
	label var dosage "Months of exposure"

* Treatment dose dummy
	g dose=1 if dosage<.
	qui sum dosage, det
	replace dose=2 if dosage>r(p50) & dose==1
	label define dose  1 "Low" 2 "High", modify
	label values dose dose
	label var dose "Treatment dose"
	
* Mortality 
	g mort7=diedage==1 if consent==1
	label var mort7 "7-day mortality"
	g mort30=diedage<=2 if consent==1
	label var mort30 "30-day mortality"
	
* Male child
	g male=sex==1 if consent==1
	label var male "Male infant"
	
* In utero death
	g inut=outcome>1 | alive==0 if consent==1
	label var inut "In utero death"

* Multiple pregnancy
	g multiple=multip==2 if consent==1
	label var multiple "Multiple birth" 
	
* Quarter of Birth
	g qtr=qofd(dofm(month)) if delplace<.
	format qtr %tq
	label var qtr "Quarter of birth"

* Caesarean
	g csection=cesarean==1 if consent==1
	label var csection "Caesarean delivery"

* Treatment dummies
	qui tab clinictreat, g(treat)
	ren (treat1 treat2 treat3)(control mlp doctor)
	label var control "Control"
	label var mlp "MLP Village"
	label var doctor "Doctor Village"
	
* Apply value labels
	foreach v of varlist attrit mschool? hausa-last usedcare-doctorcare2 mort* male csec-doctor {
		label values `v'  yesno
	}

/*---------------------------------------------------------------
	Save files
---------------------------------------------------------------*/
/*	
* Woman file

	preserve
		foreach v in mort7 inut {
			bys wid: egen _`v'=max(`v') if consent==1
		}
		ren (_mort7 _inut)(mort inutero)
		label var mort "Woman's child died in the first week"
		label var inutero "Woman experienced an in utero death"
		drop multip-length mort7-csection __0000*  // drop child variables
		duplicates drop wid, force
		save "$data/woman_tmpchanges", replace
	restore
	
	*/
	
* Child file

	preserve
		keep if alive==1
		drop __0000* 
		save "$data/child_tmpchanges", replace
	restore

/*
/*---------------------------------------------------------------------
	Provider data
---------------------------------------------------------------------*/

use "$proc/provider", clear

* Score on general medical knowledge module 
	egen mscore=rowmean(mcq*)
	label var mscore "Basic medical knowledge (%)"

* Score on obstetric module
	egen cscore=rowmean(cs_?_? cs_?_??)
	label var cscore "Emergency obstetric care (%)"

* Performance on Vignette 1
	egen v1hx=rowmean(v1hx_*)
	egen v1exam=rowmean(v1pe_*)
	egen v1lab=rowmean(v1lab_*)
	egen v1educ=rowmean(v1educ_*)
	egen vscore1=rowmean(v1hx_* v1pe_* v1lab_* v1educ_* v1diag1 v1treat_tb)

* Performance on Vignette 2
	egen v2hx=rowmean(v2hx_*)
	egen v2exam=rowmean(v2pe_*)
	egen v2lab=rowmean(v2lab_*)
	egen v2educ=rowmean(v2educ_*)
	egen vscore2=rowmean(v2hx_* v2pe_* v2lab_* v2educ_* v2diag1 v2treat_malaria v2treat_folate)

* Labels
	foreach i in 1 2 {
		label var v`i'hx "Vignette `i' history score"
		label var v`i'exam "Vignette `i' examination score"
		label var v`i'lab "Vignette `i' lab test score"
		label var v`i'educ "Vignette `i' patient education score"
		label var vscore`i' "Vignette `i' total score"
	}
	
* Average performance across vignettes
	egen vscore=rowmean(v?hx_* v?pe_* v?lab_* v?educ_* v?diag1 v1treat_tb v2treat_malaria v2treat_folate)
	replace vscore=vscore*100
	label var vscore "Outpatient primary care (%)"
	
* Average score on proficiency tests
	foreach x of varlist mscore cscore vscore? {
		qui replace `x'=`x'*100
	}
	egen qscore=rowmean(mscore cscore vscore?)
	label var qscore "Proficiency score (%)"
	
* Aggregate using Principal Component Analysis
	qui pca mcq* cs_?_* v?hx_* v?pe_* v?lab_* v?educ_* v?diag1 v1treat_tb v1treat_refer v2treat_malaria v2treat_folate, comp(1)
	cap drop x
	qui predict x

* Standardize against the control group
	qui sum x if clinict==0
	g qindex=(x-r(mean))/r(sd)
	label var qindex "Standardized proficiency"
	drop x

* Facility-level averages 
	foreach v in qscore qindex {
		bys fid: egen avg`v'=mean(`v')
		}
	label var avgqscore "Average proficiency score"
	label var avgqindex "Average standardized quality"
	

* Save
	ren provtype provider
	save "$data/provider", replace


/*---------------------------------------------------------------------
	Patient data
---------------------------------------------------------------------*/

use "$proc/patient", clear

* Presenting complaint

foreach x in fever headache abd_pain cough weakness diarrhea vomiting chest_pain pregnancy back_pain feeling_ill genital leg sneezing rash eyedischarge redeye dizziness sob nausea abd_distention chills pain hypertension earache appetite eardischarge eyepain {
	cap drop `x'
	ge `x'=0
}

quietly {
	forvalues i=1/8 {
		replace pain=1 if code`i'=="A01"	
		replace chills=1 if code`i'=="A02"
		replace fever=1 if code`i'=="A03"
		replace weakness=1 if code`i'=="A04"	
		replace feeling_ill=1 if code`i'=="A05"	
		replace chest_pain=1 if code`i'=="A11"
		replace abd_pain=1 if code`i'=="D01"
		replace nausea=1 if code`i'=="D09"
		replace vomiting=1 if code`i'=="D10"
		replace diarrhea=1 if code`i'=="D11"
		replace abd_distention=1 if code`i'=="D25"	
		replace eyepain=1 if code`i'=="F01"
		replace redeye=1 if code`i'=="F02"
		replace eyedischarge=1 if code`i'=="F03"
		replace earache=1 if code`i'=="H01"
		replace eardischarge=1 if code`i'=="H04"
		replace hypertension=1 if code`i'=="K25"	
		replace back_pain=1 if code`i'=="L02" | code`i'=="L03"	
		replace leg=1 if code`i'=="L14" | code`i'=="L15" | code`i'=="L16" | code`i'=="L17"	
		replace headache=1 if code`i'=="N01"
		replace dizziness=1 if code`i'=="N17"	
		replace sob=1 if code`i'=="R02"	
		replace cough=1 if code`i'=="R05"	
		replace sneezing=1 if code`i'=="R07"
		replace rash=1 if code`i'=="S06" | code`i'=="S07"	
		replace appetite=1 if code`i'=="T03"	
		replace pregnancy=1 if regexm(code`i',"W")
		replace genital=1 if regexm(code`i',"X")
		replace genital=1 if regexm(code`i',"Y")
	}
}
	label var fever "Complains of fever"
	label var cough "Complains of cough"
	label var diarrhea "Complains of diarrhea" 
	label var headache "Complains of headache"
	label var chest_pain "Complains of chest pain" 
	label var abd_pain "Complains of abdominal pain"
	label var weakness "Complains of tiredness/weakness"
	label var vomiting "Complains of vomiting" 
	label var feeling_ill "Complains of feeling ill"
	label var back_pain "Back complaint" 
	label var sneezing "Complains of nasal congestion"
	label var genital "Genital complaint" 
	label var leg "Leg complaint"  
	label var rash "Complains of rash"
	label var eyedischarge "Complains of eye discharge"
	label var redeye "Complains of red eye"
	label var dizziness "Complains of dizziness"
	label var sob "Complains of shortness of breath"
	label var nausea "Complains of nausea"
	label var abd_distention "Complains of abdominal distention"
	label var chills "Complains of chills"
	label var pain "Complains of general pain"
	label var hypertension "Complains of hypertension"
	label var earache "Complains of ear ache"
	label var appetite "Complains of poor appetite"
	label var eardischarge "Complains of ear discharge"
	label var eyepain "Complains of eye pain"
	label var pregnancy "Pregnancy-related visit"
	
* Group age into categories because of measurement error 

	egen agegp=cut(age), at(0,5,10,20,30,40,50,100)
	tab agegp, g(agegroup)
	label var agegroup1 "Age < 5 years"
	label var agegroup2 "Age 5-9 years"
	label var agegroup3 "Age 10-19 years"
	label var agegroup4 "Age 20-29 years"
	label var agegroup5 "Age 30-39 years"
	label var agegroup6 "Age 40-49 years"
	label var agegroup7 "Age 50 or older"
	drop agegp
	order agegroup?, after(age)

* Health variables: Recode so that higher is better

	label define healthrating 1 "Poor" 2 "Fair" 3 "Good" 4 "Very good" 5 "Excellent", modify
	label define status 1 "A lot" 2 "Some" 3 "None", modify
	
	foreach x of varlist bhealth {
		replace `x'=. if `x'==99
		recode `x' (5=1) (4=2) (2=4) (1=5)
		label values `x' healthrating
	}

	foreach x of varlist walk run ache sleep {
		recode `x' (3=1) (1=3)
		label values `x' status
	}

* Dummies
	
	foreach v in bhealth walk run {
	qui tab `v', g(`v')
	order `v'?, after(`v')
	}

	g walked=transport==1
	g car= transport==4
	order walked car, after(transport)
	g male=sex==1
	g severe=severity>=7 if severity<.
	order severe, after(severity)
	
	label var male "Male"
	label var severe "Severity score 7 or higher"
	label var walk3 "Difficulty walking: None"
	label var walk2 "Difficulty walking: Some"
	label var walk1 "Difficulty walking: A lot"
	label var run3 "Difficulty running: None"
	label var run2 "Difficulty running: Some"
	label var run1 "Difficulty running: A lot"
	label var bhealth1 "Poor"
	label var bhealth2 "Fair"
	label var bhealth3 "Good"
	label var bhealth4 "Very good"
	label var bhealth5 "Excellent"
	label var walked "Transport to clinic: walked"
	label var car "Transport to clinic: own car/motorcycle"

* Labels

foreach v of varlist agegroup? bhealth? walk? run? fever-eyepain severe male {
	label values `v' yesno
}

* Save
	save "$data/patient", replace


/*---------------------------------------------------------------------
	Audit data
---------------------------------------------------------------------*/

use "$proc/audit", clear

* Merge with deployment data

merge m:1 fid using "$raw/dates", nogen keep(1 3)

* Identify audit visits that took place during the provider's posting

	g auditwhen=visitdate-startdate
	label var auditwhen "Timing of visit relative to provider startdate (months)"
	replace auditwhen=. if auditwhen<0 			// before provider arrived
	replace auditwhen=. if visitdate>stopdate 	// after provider left

	bys fid: g visits=_N
	label var visits "Number of audit visits"

* Save
	save "$data/audit", replace


/*---------------------------------------------------------------------
	Provider assessment data
---------------------------------------------------------------------*/

use "$proc/facility_el", clear

* Merge in provider start/end dates
g n=_n	
merge 1:1 fid using "$raw/dates", nogen
sort n
drop n
keep if duration>7
keep state sid strata fid impact* ideas clinict

* Save
	save "$data/impact", replace
	
	
/*---------------------------------------------------------------------
	Clinic staff roster
---------------------------------------------------------------------*/

use "$raw/roster", clear

* Doctor on staff at various timepoints

loc var doctor1
g x=1 if provtype==1 & present1==1 & studyprov==.
bys fid: egen `var'=min(x)
replace `var'=0 if `var'==.
drop x 

loc var doctor2
g x=1 if provtype==1 & present1==1 
bys fid: egen `var'=min(x)
replace `var'=0 if `var'==.
drop x 

loc var doctor3
g x=1 if provtype==1 & present2==1 & present12>0 
bys fid: egen `var'=min(x)
replace `var'=0 if `var'==.
drop x 

* Number of health workers at various timepoints

loc var staff1
g x=1 if present1==1 & studyprov==.
bys fid: egen `var'=total(x)
replace `var'=0 if `var'==.
drop x 

loc var staff2
bys fid: egen `var'=total(present1)
replace `var'=0 if `var'==.

loc var staff3
bys fid: egen `var'=total(present2)
replace `var'=0 if `var'==.

duplicates drop fid, force

* Reshape the data 

keep state sid strata fid doctor? staff? clinictreat
reshape long doctor staff, i(fid) j(visit)

label var doctor "Doctor on staff"
label var staff "Number of providers"
label var visit "Visit timing"
label define visit 1 "T0" 2 "T1" 3 "T2"
label values visit visit

* Save
	save "$data/staffing", replace

*/