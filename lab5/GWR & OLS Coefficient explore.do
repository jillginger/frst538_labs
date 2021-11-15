cap log close
clear all
set more off

global logpath `"C:\Users\jillb\OneDrive - UBC\FRST-538\lab5\log"'
cd "$logpath"
log using lab5.smcl,replace

*GWR & OLS Explore
*Jing Jiang
*2021-11-14

************************************************************************************************
*Objectives*
*1. Calculate the Min, 1st Quartile, Median, 3rd Quartile, Max of the GWR estimators
*2. Testing the spatial non-stationary using Monte Carlo method (Brundsdon et al., 1996) page 288
*3. Descriptive stats of the raw demogrphic data (N = 993, not 980)
************************************************************************************************

global rawpath `"C:\Users\jillb\OneDrive - UBC\FRST-538\lab5\attribute tables"'
global cleanpath `"C:\Users\jillb\OneDrive - UBC\FRST-538\lab5\data clean"'

*1.
cd "$rawpath"
import excel using VancouverDemo_GWR, first
sum C_* //mean max
sum C_*, d //quartiles

save gwr_raw,replace

*3. 
cd "$rawpath"
import excel using demo_raw, first clear
sum NEAR_DIST HHSize LowIncome Bachelors MedianIncome 
sum NonOfficialLanguages Immigrants20112016

*2. 
set seed 49
g mc_dist1 = rnormal()*3 + 100 //fake distance for a GWR 1
sum mc_dist1
sum mc_dist1,d

set seed 20
g mc_dist2 = rnormal()*3 + 100 //fake distance for a GWR 2
sum mc_dist2
sum mc_dist2,d

set seed 955
g mc_dist3 = rnormal()*3 + 100 //fake distance for a GWR 3
sum mc_dist3
sum mc_dist3,d
// Not sure how to automatically run GWR 1000 times in Arc Pro, so I 
// illustrate with Monte Carlo N = 3 :p


cd "$cleanpath"
export excel using mc_demo.xlsx, first(var) replace
save mc_demo,replace
gwr NEAR_DIST HHSize LowIncome Bachelors MedianIncome NonOfficialLanguages ///
Immigrants20112016, east(mc_dist1) north(mc_dist2) replace dots nolog

// how to get east/north data from attribute table? merge with GEOUID?

cd "$rawpath"
import excel using mc_GWR1,first clear 
keep OBJECTID C_MC_VANCOUVERDA_* 

rename C_MC_VANCOUVERDA_HHSIZE hhsize
rename C_MC_VANCOUVERDA_LOWINCOME lowinc
rename C_MC_VANCOUVERDA_BACHELORS bach
rename C_MC_VANCOUVERDA_MEDIANINCOME medin
rename C_MC_VANCOUVERDA_NONOFFICIALLANG lang
rename C_MC_VANCOUVERDA_IMMIGRANTS20112 imm
gen model = 1

cd "$cleanpath"
save mc1_coef,replace

cd "$rawpath"
use gwr_raw,clear
keep OBJECTID C_*

rename C_HHSIZE hhsize
rename C_LOWINCOME lowinc
rename C_BACHELORS bach
rename C_MEDIANINCOME medin
rename C_NONOFFICIALLANGUAGES lang
rename C_IMMIGRANTS20112016 imm
gen model = 0

cd "$cleanpath"
save gwr_coef,replace

append using mc_coef

foreach v of varlist hhsize lowinc bach medin lang imm{
	sum `v' if model == 1
	ttest `v', by(model)
}

cd "$rawpath"
import excel using mc_GWR2,first clear 
keep OBJECTID C_MC_VANCOUVERDA_* 

rename C_MC_VANCOUVERDA_HHSIZE hhsize
rename C_MC_VANCOUVERDA_LOWINCOME lowinc
rename C_MC_VANCOUVERDA_BACHELORS bach
rename C_MC_VANCOUVERDA_MEDIANINCOME medin
rename C_MC_VANCOUVERDA_NONOFFICIALLANG lang
rename C_MC_VANCOUVERDA_IMMIGRANTS20112 imm
gen model = 2

cd "$cleanpath"
save mc2_coef,replace
append using gwr_coef

foreach v of varlist hhsize lowinc bach medin lang imm{
	sum `v' if model == 2
	ttest `v', by(model)
}

cd "$rawpath"
import excel using mc_GWR3,first clear 
keep OBJECTID C_MC_VANCOUVERDA_* 

rename C_MC_VANCOUVERDA_HHSIZE hhsize
rename C_MC_VANCOUVERDA_LOWINCOME lowinc
rename C_MC_VANCOUVERDA_BACHELORS bach
rename C_MC_VANCOUVERDA_MEDIANINCOME medin
rename C_MC_VANCOUVERDA_NONOFFICIALLANG lang
rename C_MC_VANCOUVERDA_IMMIGRANTS20112 imm
gen model = 3

cd "$cleanpath"
save mc3_coef,replace

append using gwr_coef

foreach v of varlist hhsize lowinc bach medin lang imm{
	sum `v' if model == 3
	ttest `v', by(model)
}


log close
