
*******************************************************************************************************

** This file generates the main tables in the Paper*********************************************************************************************

clear
set more off

*Path directories*
global main "C:/Users/richarjm/OneDrive - Lancaster University/Replication/Norwich Doctors 2"
global do "$main/dofiles"
global raw "$main/data/raw"
global proc "$main/data/intermediate"
global data "$main/data/analysis"
global out "$main/output"



*Other variable definitions
global treat mlp doctor
global cont_ind cct magedum1 magedum2 magedum3 magedum4 magedum5 first hausa mschool1 mschool2 mschool3 mschool4 autonomy car last gest
global cont_base $cont_ind male
global cont_hc hc_deliveries hc_cesarean hc_transfusion hc_clean*
global cont_all $cont_base $cont_hc pastdeath hc_workers hc_open24hrs hc_equipment hc_beds hc_lab hc_drug hc_nopow hc_vent hc_cond*
global patient agegroup* sex phone transport* bhealth* severity* fever cough headache abd_pain weakness pregnancy order interr


*New treatment list*
global cont_inddemean cctdemeaned magedum1demeaned magedum2demeaned magedum3demeaned magedum4demeaned magedum5demeaned firstdemeaned hausademeaned mschool1demeaned mschool2demeaned mschool3demeaned mschool4demeaned autonomydemeaned cardemeaned lastdemeaned gestdemeaned
global cont_basedemean $cont_inddemean maledemeaned
global cont_hcdemean hc_deliveriesdemeaned  hc_cesareandemeaned  hc_transfusiondemeaned  hc_clean1demeaned hc_clean2demeaned hc_clean3demeaned hc_clean4demeaned
global cont_alldemean $cont_base $cont_hc pastdeathdemeaned hc_workersdemeaned hc_open24hrsdemeaned hc_equipmentdemeaned hc_bedsdemeaned hc_labdemeaned hc_drugdemeaned hc_nopowdemeaned hc_ventdemeaned hc_cond*demeaned
global patientdemean agegroup1demeaned agegroup2demeaned agegroup3demeaned agegroup4demeaned agegroup5demeaned agegroup6demeaned agegroup7demeaned sexdemeaned phonedemeaned transport1demeaned transport2demeaned transport3demeaned transport4demeaned transport6demeaned bhealth1demeaned bhealth2demeaned bhealth3demeaned bhealth4demeaned bhealth5demeaned severity0demeaned severity1demeaned severity2demeaned severity3demeaned severity4demeaned severity5demeaned severity6demeaned severity7demeaned severity8demeaned severity9demeaned severity10demeaned feverdemeaned coughdemeaned headachedemeaned abd_paindemeaned weaknessdemeaned pregnancydemeaned orderdemeaned interrdemeaned
global qtrdemeaninteract qtr1demeaned qtr2demeaned qtr3demeaned qtr4demeaned qtr5demeaned qtr6demeaned c.mlp#c.qtr2demeangroup c.mlp#c.qtr3demeangroup c.mlp#c.qtr4demeangroup c.mlp#c.qtr5demeangroup c.mlp#c.qtr6demeangroup c.doctor#c.qtr1demeangroup c.doctor#c.qtr2demeangroup c.doctor#c.qtr3demeangroup c.doctor#c.qtr4demeangroup c.doctor#c.qtr5demeangroup c.doctor#c.qtr6demeangroup
global stratademeaninteract strata11demeaned strata12demeaned strata13demeaned strata14demeaned strata15demeaned strata16demeaned strata17demeaned strata18demeaned strata19demeaned strata20demeaned strata21demeaned strata22demeaned strata23demeaned strata24demeaned strata25demeaned strata26demeaned strata27demeaned strata28demeaned strata29demeaned strata30demeaned strata31demeaned strata32demeaned strata33demeaned strata34demeaned strata35demeaned strata36demeaned strata37demeaned strata38demeaned strata39demeaned strata40demeaned strata41demeaned strata42demeaned strata43demeaned strata44demeaned strata45demeaned strata46demeaned strata47demeaned strata48demeaned strata49demeaned strata50demeaned strata51demeaned strata52demeaned strata53demeaned c.mlp#c.strata11demeangroup c.mlp#c.strata12demeangroup c.mlp#c.strata13demeangroup c.mlp#c.strata14demeangroup c.mlp#c.strata15demeangroup c.mlp#c.strata16demeangroup c.mlp#c.strata17demeangroup c.mlp#c.strata18demeangroup c.mlp#c.strata19demeangroup c.mlp#c.strata20demeangroup c.mlp#c.strata21demeangroup c.mlp#c.strata22demeangroup c.mlp#c.strata23demeangroup c.mlp#c.strata24demeangroup c.mlp#c.strata25demeangroup c.mlp#c.strata26demeangroup c.mlp#c.strata27demeangroup c.mlp#c.strata28demeangroup c.mlp#c.strata29demeangroup c.mlp#c.strata30demeangroup c.mlp#c.strata31demeangroup c.mlp#c.strata32demeangroup c.mlp#c.strata33demeangroup c.mlp#c.strata34demeangroup c.mlp#c.strata35demeangroup c.mlp#c.strata36demeangroup c.mlp#c.strata37demeangroup c.mlp#c.strata38demeangroup c.mlp#c.strata39demeangroup c.mlp#c.strata40demeangroup c.mlp#c.strata41demeangroup c.mlp#c.strata42demeangroup c.mlp#c.strata43demeangroup c.mlp#c.strata44demeangroup c.mlp#c.strata45demeangroup c.mlp#c.strata46demeangroup c.mlp#c.strata47demeangroup c.mlp#c.strata48demeangroup c.mlp#c.strata49demeangroup c.mlp#c.strata50demeangroup c.mlp#c.strata51demeangroup c.mlp#c.strata52demeangroup c.mlp#c.strata53demeangroup c.doctor#c.strata11demeangroup c.doctor#c.strata12demeangroup c.doctor#c.strata13demeangroup c.doctor#c.strata14demeangroup c.doctor#c.strata15demeangroup c.doctor#c.strata16demeangroup c.doctor#c.strata17demeangroup c.doctor#c.strata18demeangroup c.doctor#c.strata19demeangroup c.doctor#c.strata20demeangroup c.doctor#c.strata21demeangroup c.doctor#c.strata22demeangroup c.doctor#c.strata23demeangroup c.doctor#c.strata24demeangroup c.doctor#c.strata25demeangroup c.doctor#c.strata26demeangroup c.doctor#c.strata27demeangroup c.doctor#c.strata28demeangroup c.doctor#c.strata29demeangroup c.doctor#c.strata30demeangroup c.doctor#c.strata31demeangroup c.doctor#c.strata32demeangroup c.doctor#c.strata33demeangroup c.doctor#c.strata34demeangroup c.doctor#c.strata35demeangroup c.doctor#c.strata36demeangroup c.doctor#c.strata37demeangroup c.doctor#c.strata38demeangroup c.doctor#c.strata39demeangroup c.doctor#c.strata40demeangroup c.doctor#c.strata41demeangroup c.doctor#c.strata42demeangroup c.doctor#c.strata43demeangroup c.doctor#c.strata44demeangroup c.doctor#c.strata45demeangroup c.doctor#c.strata46demeangroup c.doctor#c.strata47demeangroup c.doctor#c.strata48demeangroup c.doctor#c.strata49demeangroup c.doctor#c.strata50demeangroup c.doctor#c.strata51demeangroup c.doctor#c.strata52demeangroup c.doctor#c.strata53demeangroup

global cont_inddemeaninteract c.mlp#c.cctdemeangroup c.mlp#c.magedum1demeangroup c.mlp#c.magedum2demeangroup c.mlp#c.magedum3demeangroup c.mlp#c.magedum4demeangroup c.mlp#c.firstdemeangroup c.mlp#c.hausademeangroup c.mlp#c.mschool1demeangroup c.mlp#c.mschool2demeangroup c.mlp#c.mschool3demeangroup c.mlp#c.mschool4demeangroup c.mlp#c.autonomydemeangroup c.mlp#c.cardemeangroup c.mlp#c.lastdemeangroup c.mlp#c.gestdemeangroup c.doctor#c.cctdemeangroup c.doctor#c.magedum1demeangroup c.doctor#c.magedum2demeangroup c.doctor#c.magedum3demeangroup c.doctor#c.magedum4demeangroup c.doctor#c.magedum5demeangroup c.doctor#c.firstdemeangroup c.doctor#c.hausademeangroup c.doctor#c.mschool1demeangroup c.doctor#c.mschool2demeangroup c.doctor#c.mschool3demeangroup c.doctor#c.mschool4demeangroup c.doctor#c.autonomydemeangroup c.doctor#c.cardemeangroup c.doctor#c.lastdemeangroup c.doctor#c.gestdemeangroup
global cont_basedemeaninteract $cont_inddemeaninteract c.mlp#c.maledemeangroup c.doctor#c.maledemeangroup
global cont_hcdemeaninteract c.mlp#c.hc_deliveriesdemeangroup c.mlp#c.hc_cesareandemeangroup c.mlp#c.hc_transfusiondemeangroup c.mlp#c.hc_clean1demeangroup c.mlp#c.hc_clean2demeangroup c.mlp#c.hc_clean3demeangroup c.mlp#c.hc_clean4demeangroup c.doctor#c.hc_deliveriesdemeangroup c.doctor#c.hc_cesareandemeangroup c.doctor#c.hc_transfusiondemeangroup c.doctor#c.hc_clean1demeangroup c.doctor#c.hc_clean2demeangroup c.doctor#c.hc_clean3demeangroup c.doctor#c.hc_clean4demeangroup
global cont_alldemeaninteract $cont_basedemeaninteract $cont_hcdemeaninteract  c.mlp#c.pastdeathdemeangroup c.mlp#c.hc_workersdemeangroup c.mlp#c.hc_open24hrsdemeangroup c.mlp#c.hc_equipmentdemeangroup c.mlp#c.hc_bedsdemeangroup c.mlp#c.hc_labdemeangroup c.mlp#c.hc_drugdemeangroup c.mlp#c.hc_nopowdemeangroup c.mlp#c.hc_ventdemeangroup c.mlp#c.hc_cond*demeangroup c.doctor#c.pastdeathdemeangroup c.doctor#c.hc_workersdemeangroup c.doctor#c.hc_open24hrsdemeangroup c.doctor#c.hc_equipmentdemeangroup c.doctor#c.hc_bedsdemeangroup c.doctor#c.hc_labdemeangroup c.doctor#c.hc_drugdemeangroup c.doctor#c.hc_nopowdemeangroup c.doctoc.mlp#c.hc_clean1demeangroupr#c.hc_ventdemeangroup c.doctor#c.hc_cond*demeangroup
global patientdemeaninteract c.provider2#c.agegroup1demeangroup c.provider2#c.agegroup2demeangroup c.provider2#c.agegroup3demeangroup c.provider2#c.agegroup4demeangroup c.provider2#c.agegroup5demeangroup c.provider2#c.agegroup6demeangroup c.provider2#c.agegroup7demeangroup c.provider2#c.sexdemeangroup c.provider2#c.phonedemeangroup c.provider2#c.transport1demeangroup c.provider2#c.transport2demeangroup c.provider2#c.transport3demeangroup c.provider2#c.transport4demeangroup c.provider2#c.transport6demeangroup c.provider2#c.bhealth1demeangroup c.provider2#c.bhealth2demeangroup c.provider2#c.bhealth3demeangroup c.provider2#c.bhealth4demeangroup c.provider2#c.bhealth5demeangroup  c.provider2#c.severity0demeangroup c.provider2#c.severity1demeangroup c.provider2#c.severity2demeangroup c.provider2#c.severity3demeangroup c.provider2#c.severity4demeangroup c.provider2#c.severity5demeangroup c.provider2#c.severity6demeangroup c.provider2#c.severity7demeangroup c.provider2#c.severity8demeangroup c.provider2#c.severity9demeangroup c.provider2#c.severity10demeangroup c.provider2#c.feverdemeangroup c.provider2#c.coughdemeangroup c.provider2#c.headachedemeangroup c.provider2#c.abd_paindemeangroup c.provider2#c.weaknessdemeangroup c.provider2#c.pregnancydemeangroup c.provider2#c.orderdemeangroup c.provider2#c.interrdemeangroup c.provider3#c.agegroup2demeangroup c.provider3#c.agegroup3demeangroup c.provider3#c.agegroup4demeangroup c.provider3#c.agegroup5demeangroup c.provider3#c.agegroup6demeangroup c.provider3#c.agegroup7demeangroup c.provider3#c.sexdemeangroup c.provider3#c.phonedemeangroup c.provider3#c.transport1demeangroup c.provider3#c.transport2demeangroup c.provider3#c.transport3demeangroup c.provider3#c.transport4demeangroup c.provider3#c.transport6demeangroup c.provider3#c.bhealth1demeangroup c.provider3#c.bhealth2demeangroup c.provider3#c.bhealth3demeangroup c.provider3#c.bhealth4demeangroup c.provider3#c.bhealth5demeangroup c.provider3#c.severity0demeangroup c.provider3#c.severity1demeangroup c.provider3#c.severity2demeangroup c.provider3#c.severity3demeangroup c.provider3#c.severity4demeangroup c.provider3#c.severity5demeangroup c.provider3#c.severity6demeangroup c.provider3#c.severity7demeangroup c.provider3#c.severity8demeangroup c.provider3#c.severity9demeangroup c.provider3#c.severity10demeangroup  c.provider3#c.feverdemeangroup c.provider3#c.coughdemeangroup c.provider3#c.headachedemeangroup c.provider3#c.abd_paindemeangroup c.provider3#c.weaknessdemeangroup c.provider3#c.pregnancydemeangroup c.provider3#c.orderdemeangroup c.provider3#c.interrdemeangroup
global statedemeaninteract state2demeaned state3demeaned state4demeaned state5demeaned c.state2demeangroup#c.provider2 c.state3demeangroup#c.provider2 c.state4demeangroup#c.provider2 c.state5demeangroup#c.provider2 c.state2demeangroup#c.provider3 c.state3demeangroup#c.provider3 c.state4demeangroup#c.provider3 c.state5demeangroup#c.provider3

/*-----------------------------------------------------------------------------
	Table 3. Effect on probability that health care was provided by a doctor
------------------------------------------------------------------------------*/

use "$data/woman", clear

gen magedum1=(magedum==1)
gen magedum2=(magedum==2)
gen magedum3=(magedum==3)
gen magedum4=(magedum==4)
gen magedum5=(magedum==5)

forvalues i=11/53{
	gen strata`i'=(strata==`i')
	egen strata`i'mean=mean(strata`i')
	gen strata`i'demeaned=strata`i'-strata`i'mean
	drop strata`i'mean
	bys $treat: egen strata`i'meangroup=mean(strata`i')
	gen strata`i'demeangroup=strata`i'-strata`i'meangroup
	drop strata`i'meangroup
}


foreach i in cct magedum1 magedum2 magedum3 magedum4 magedum5 first hausa mschool1 mschool2 mschool3 mschool4 autonomy car last gest{
	egen `i'mean=mean(`i')
	gen `i'demeaned=`i'-`i'mean
	drop `i'mean
}
foreach i in cct magedum1 magedum2 magedum3 magedum4 magedum5 first hausa mschool1 mschool2 mschool3 mschool4 autonomy car last gest{
	bys $treat: egen `i'meangroup=mean(`i')
	gen `i'demeangroup=`i'-`i'meangroup
	drop `i'meangroup
}

*New controls*
	quietly {
		eststo clear
		local cond card==1
		foreach y of varlist doctorcare1 {
			eststo: reg `y' $treat $stratademeaninteract if `cond', cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: reg `y' $cont_inddemean $cont_inddemeaninteract $stratademeaninteract $treat if `cond', cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}
		foreach y of varlist doctorcare2 {
			eststo: reg `y' $treat $stratademeaninteract, cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
			
			eststo: reg `y' $cont_inddemean $cont_inddemeaninteract $stratademeaninteract $treat, cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
		}			
	}
	
	#delimit ;
		esttab using "$out/table3new", replace keep($treat) b(%9.3f) se(%9.3f)
		noconstant label nonotes nostar nomtitles eqlabels(" " " ") 
	width(\hsize) mgroups("Card" "Self-report", pattern(1 0 1 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
		scalars("mean Control group mean") indicate("Controls = cctdemeaned") rtf;
	#delimit cr	

	
/*-----------------------------------------------------------------------------
	Table 4. Effect on 7-day mortality
------------------------------------------------------------------------------*/

use "$data/child", clear

gen magedum1=(magedum==1)
gen magedum2=(magedum==2)
gen magedum3=(magedum==3)
gen magedum4=(magedum==4)
gen magedum5=(magedum==5)

gen hc_clean1=(hc_clean==1)
gen hc_clean2=(hc_clean==2)
gen hc_clean3=(hc_clean==3)
gen hc_clean4=(hc_clean==4)

gen qtr1=(qtr==228) if qtr!=.
gen qtr2=(qtr==229) if qtr!=.
gen qtr3=(qtr==230) if qtr!=.
gen qtr4=(qtr==231) if qtr!=.
gen qtr5=(qtr==232) if qtr!=.
gen qtr6=(qtr==233) if qtr!=.

forvalues i=11/53{
	gen strata`i'=(strata==`i')
	egen strata`i'mean=mean(strata`i')
	gen strata`i'demeaned=strata`i'-strata`i'mean
	drop strata`i'mean
	bys $treat: egen strata`i'meangroup=mean(strata`i')
	gen strata`i'demeangroup=strata`i'-strata`i'meangroup
	drop strata`i'meangroup
}

foreach i in cct magedum1 magedum2 magedum3 magedum4 magedum5 first hausa mschool1 mschool2 mschool3 mschool4 autonomy car last gest male hc_deliveries  hc_cesarean  hc_transfusion  hc_clean1 hc_clean2 hc_clean3 hc_clean4 qtr1 qtr2 qtr3 qtr4 qtr5 qtr6{
	egen `i'mean=mean(`i')
	gen `i'demeaned=`i'-`i'mean
	drop `i'mean
}
foreach i in cct magedum1 magedum2 magedum3 magedum4 magedum5 first hausa mschool1 mschool2 mschool3 mschool4 autonomy car last gest male hc_deliveries  hc_cesarean  hc_transfusion  hc_clean1 hc_clean2 hc_clean3 hc_clean4 qtr1 qtr2 qtr3 qtr4 qtr5 qtr6{
	bys $treat: egen `i'meangroup=mean(`i')
	gen `i'demeangroup=`i'-`i'meangroup
	drop `i'meangroup
}


* Minus lasso new*
	quietly {
		set seed 4321
		eststo clear
		foreach y of varlist mort7 {
			
			eststo: reg `y' $stratademeaninteract $treat, cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reg `y' $cont_basedemean $cont_basedemeaninteract $qtrdemeaninteract $stratademeaninteract $treat , cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)
			
			eststo: reg `y' $cont_basedemean $cont_basedemeaninteract $cont_hcdemean $cont_hcdemeaninteract $qtrdemeaninteract $stratademeaninteract $treat, cl(fid)
			sum `y' if e(sample) & control==1
			estadd r(mean)	
		}
	}
	
	#delimit;
		esttab using "$out/table4new", replace keep($treat) b(%9.4f) se(%9.4f)
		noconstant label nonotes nostar eqlabels(" " " ") 
		mtitles("No controls" "Basic controls" "Extended controls")
		rtf width(\hsize) scalars("mean Control group mean");
	#delimit cr	
	
/*-----------------------------------------------------------------------------
	Table 6. Effect on observed quality of treatment
------------------------------------------------------------------------------*/

use "$data/patient", clear

gen transport1=(transport==1)
gen transport2=(transport==2)
gen transport3=(transport==3)
gen transport4=(transport==4)
gen transport6=(transport==6)

gen severity1=(severity==1)
gen severity2=(severity==2)
gen severity3=(severity==3)
gen severity4=(severity==4)
gen severity5=(severity==5)
gen severity6=(severity==6)
gen severity7=(severity==7)
gen severity8=(severity==8)
gen severity9=(severity==9)
gen severity10=(severity==10)
gen severity0=(severity==0)

gen provider1=(provider==0)
gen provider2=(provider==1)
gen provider3=(provider==2)

gen state1=(sid==1)
gen state2=(sid==2)
gen state3=(sid==3)
gen state4=(sid==4)
gen state5=(sid==5)


foreach i in agegroup1 agegroup2 agegroup3 agegroup4 agegroup5 agegroup6 agegroup7 sex phone transport1 transport2 transport3 transport4 transport6 bhealth1 bhealth2 bhealth3 bhealth4 bhealth5 severity0 severity1 severity2 severity3 severity4 severity5 severity6 severity7 severity8 severity9 severity10 fever cough headache abd_pain weakness pregnancy order interr provider1 provider2 provider3 state1 state2 state3 state4 state5{
	egen `i'mean=mean(`i')
	gen `i'demeaned=`i'-`i'mean
	drop `i'mean
}
foreach i in agegroup1 agegroup2 agegroup3 agegroup4 agegroup5 agegroup6 agegroup7 sex phone transport1 transport2 transport3 transport4 transport6 bhealth1 bhealth2 bhealth3 bhealth4 bhealth5 severity0 severity1 severity2 severity3 severity4 severity5 severity6 severity7 severity8 severity9 severity10 fever cough headache abd_pain weakness pregnancy order interr provider1 provider2 provider3 state1 state2 state3 state4 state5{
	bys provider: egen `i'meangroup=mean(`i')
	gen `i'demeangroup=`i'-`i'meangroup
	drop `i'meangroup
}


	egen patientcom=rowmean(comm1-comm5 comm7-comm9)
	g logdur=ln(duration)
		
	quietly {
		eststo clear
		foreach y of varlist fever_perc exam diag inject antibio logdur patientcom {
			eststo: reg `y' $patientdemean $patientdemeaninteract $statedemeaninteract i.provider if observe==1, cl(fid)
			sum `y' if e(sample)
			estadd r(mean)
		}
	}
		
			#delimit ;
			esttab using "$out/table6new", replace keep(1.provider 2.provider) b(%9.3f) se(%9.3f)
		noconstant nonotes label nostar eqlabels(" " " ")
		coeflabels(1.provider "New MLP" 2.provider "Doctor")
		mtitles ("\shortstack{Adherence to\\fever protocol}" "\shortstack{Carried out\\physical exam}" 
		"\shortstack{Made a\\diagnosis}" "\shortstack{Prescribed\\injection}"
		"\shortstack{Prescribed\\antibiotic}" "\shortstack{Log of consultation\\time}"
		"\shortstack{Patient\\communication}") rtf width(\hsize) 
		mgroups("Good clinical practice" "Bad clinical practice", pattern(1 0 0 1 0 1 0) 
		prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))	
		scalars("mean Dep. variable mean") ;

	#delimit


