************************************************
**Colmado pilot phone surveys: DIV Proposal*****
**By: Carlos Restituyo, Research Associate IPA**
**Last updated: 2019/04/29**********************
************************************************
clear all
set more off
version 14.2
***********
**READ ME**
***********
/*
This do file pools data from first and second pilot to provide key statistics for 
DIV grant proposal. All figures are in DOP (Dominican peso). All comments are the 
author's except where noted. Any questions can be addressed to Carlos Restituyo, 
the author, at crestituyo@poverty-action.org.


CHANGES: 
2019-04-29: Do file created by Carlos Restituyo

*/


*****************
** DIRECTORIES **
*****************
if c(username)=="Sean" {
	local base "C:/Box/IPA_RD_Colmados/"
}
else if c(username)=="crestituyo" {
	local base "X:\Box Sync\IPA_DR_Projects\3_Ongoing Projects\IPA_DR_Colmados\"
}
local adofiles "`base'/08_Data/Pilot/adofiles"
local dtafiles "`base'/08_Data/Pilot/dtafiles"
local dofiles "`base'/08_Data/Pilot/dofiles" 
local logs "`base'08_Data/Pilot/logfiles"
local graphs "`base'/08_Data/Pilot/graphs"
adopath ++ "`adofiles'" // read in user-written ado files

*******
**LOG**
*******
time // saves locals `date' (YYYYMMDD) and `time' (YYYYMMDD_HHMMSS)
cap log close
set linesize 80
local project "11_DIVProposal"
log using "`logs'/`project'_`time'.log", text replace
copy "`dofiles'/`project'.do" ///
	"`dofiles'/archive/`project'_`time'.do", replace // creates an archive of old versions of the do file
di "`c(current_date)' `c(current_time)'"
pwd

************
** LOCALS **
************





*******************
** PRELIMINARIES **
*******************
set scheme s1color // for graphs

********
**DATA**
********

use "`dtafiles'\demandestimation_clean.dta", clear

********************
**DATA PREPARATION**
********************

//merge data from first pilot with data from second pilot
#delimit;
append using 
"`dtafiles'\encuestapilotos_colmados_for_analysis.dta",
keep(tot_rev_month_one tot_rev_month_two profit_one profit_two profit_three 
profit_four mckenzie_profit b_buspracindex a_buspracindex numworkers
custqtygood custqtyok custqtybad busratesalemon__1 busratesalemon__2 busratesalemon__3 
busratesalemon__4 busratesalemon__5 busratesalemon__6 busratesalemon__7
recntbankloanamnt)
;
#delimit cr


*****************
**DATA CLEANING**
*****************
//Validate data with second pilots

replace monthlyprofits = mckenzie_profit if ~missing(mckenzie_profit)

replace monthlyrevenue = tot_rev_month_two if ~missing(tot_rev_month_two)

replace numberworkers = numworkers if ~missing(numworkers)

forvalues x = 1/7{

generate goodday`x' = cond(busratesalemon__`x'==1 & ~missing(busratesalemon__`x'),1,0)
replace goodday`x' = . if missing(busratesalemon__`x')

generate avgday`x' = cond(busratesalemon__`x'==2 & ~missing(busratesalemon__`x'),1,0)
replace avgday`x' = . if missing(busratesalemon__`x')


generate badday`x' = cond(busratesalemon__`x'==3 & ~missing(busratesalemon__`x'),1,0)
replace badday`x' = . if missing(busratesalemon__`x')

}


egen totalgood = rowtotal(goodday1 goodday2 goodday3 goodday4 goodday5 goodday6 goodday7), missing
egen totalavg = rowtotal(avgday1 avgday2 avgday3 avgday4 avgday5 avgday6 avgday7), missing
egen totalbad = rowtotal(badday1 badday2 badday3 badday4 badday5 badday6 badday7), missing

generate monthlyclients = ((totalgood*custqtygood)+ (totalavg*custqtyok) +(totalbad*custqtybad))*52/12



********
**SAVE**
********


***********
**WRAP UP**
***********
log close
exit
