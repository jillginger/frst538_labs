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
*2. Descriptive stats of the raw demogrphic data (N = 993, not 980)
************************************************************************************************

global rawpath `"C:\Users\jillb\OneDrive - UBC\FRST-538\lab5\attribute tables"'
global cleanpath `"C:\Users\jillb\OneDrive - UBC\FRST-538\lab5\data clean"'

*1.
cd "$rawpath"
import excel using VancouverDemo_GWR, first
sum C_* //mean max
sum C_*, d //quartiles

save gwr_raw,replace

*2. 
cd "$rawpath"
import excel using demo_raw, first clear
sum NEAR_DIST HHSize LowIncome Bachelors MedianIncome 
sum NonOfficialLanguages Immigrants20112016


log close
