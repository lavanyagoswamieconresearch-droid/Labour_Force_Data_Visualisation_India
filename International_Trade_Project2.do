
***************************************************************
**** International Trade - Empirical Project ******************
**** By: Lavanya Goswami, Sashank Rajaram, Stuti Das **********
*********** Creating Unique ID *******************************
use "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Extracted_stata_data\Block_4_Demographic particulars of household members.dta", clear

egen pid = concat (HHID Person_Serial_No)

save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Extracted_stata_data\Block_4_Demographic particulars of household members.dta", replace

use "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Extracted_stata_data\Block_5_1_Usual principal activity particulars of household members.dta", clear

egen pid = concat (HHID Person_Serial_No)

save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Extracted_stata_data\Block_5_1_Usual principal activity particulars of household members.dta", replace, clear

************* Data Merge ***********************************

merge 1:1 pid using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Extracted_stata_data\Block_4_Demographic particulars of household members.dta"

save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Merged_dataset.dta"

**********************************************
**#    Start Here  
**********************************************
use "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Merged_dataset.dta", clear

** Setting sampling pattern and multiplier
egen fs_strata = concat(State Sector Stratum Sub_Stratum_No)
label var fs_strata "first stage strata"
svyset FSU_Serial_No [pw = Multiplier_comb], strata(fs_strata) singleunit(centered)

**## Labour Force Participation Variables
/*
worked in h.h. enterprise (self-employed): own account worker -11, 
employer-12,  
worked as helper in h.h. enterprise (unpaid family worker) -21; 
worked as regular salaried/ wage employee -31,
worked as casual wage labour: in public works -41, 
in other types of  work -51;  
did not work but was seeking and/or available for work -81, 
attended educational institution -91,  
attended domestic duties only -92, 
attended domestic duties and was also engaged in free collection of goods (vegetables, roots, firewood, cattle feed, etc.), sewing, tailoring, weaving, etc. for household use -93, 
rentiers, pensioners , remittance recipients, etc. -94, 
not able to work due to disability -95, others (including begging, prostitution,  etc.)  -97.
*/

destring Usual_Principal_Activity_Status, replace

destring Sex, replace
label define sex 1 "Male" 2 "Female"
label values Sex sex

gen labor_force = .
replace labor_force=1 if Usual_Principal_Activity_Status <= 81 
replace labor_force=0 if Usual_Principal_Activity_Status > 81
label variable labor_force "Employed or seeking work"

gen Fem_labor_force = .
replace Fem_labor_force=1 if Usual_Principal_Activity_Status <= 81 & Sex==2
replace Fem_labor_force=0 if Usual_Principal_Activity_Status > 81 & Sex==2
label variable Fem_labor_force "Females, employed or seeking work"

gen Male_labor_force = .
replace Male_labor_force=1 if Usual_Principal_Activity_Status <= 81 & Sex==1
replace Male_labor_force=0 if Usual_Principal_Activity_Status > 81 & Sex==1
label variable Fem_labor_force "Males, employed or seeking work"


gen market_engaged=.
replace market_engaged=1 if Usual_Principal_Activity_Status <= 91
replace market_engaged=0 if Usual_Principal_Activity_Status > 91
label variable market_engaged "Employed, studying or seeking work"

gen not_market_engaged=.
replace not_market_engaged=1 if market_engaged==0
replace not_market_engaged=0 if market_engaged==1
label variable not_market_engaged "Not market engaged"

gen Male_not_market_engaged=.
replace Male_not_market_engaged=1 if market_engaged==0 & Sex==1
replace Male_not_market_engaged=0 if market_engaged==1 & Sex==1
label variable Male_not_market_engaged "Males not market engaged"


label values labor_force Fem_labor_force Male_labor_force market_engaged not_market_engaged Male_not_market_engaged binary

destring Sector, replace
label define sector 1 "Rural" 2 "Urban"
label values Sector sector


gen working_age1 = (Age>=18 & Age<60)
label variable working_age1 "Aged 18-59"

gen working_age2 = (Age>=30 & Age<=60)
label variable working_age2 "Aged 30-60"

gen working_age3 = (Age>=18 & Age<=30)
label variable working_age3 "Aged 18-30"

**********************************************
**## Labour Force Participation by District
**********************************************
** Unique district codes
destring District_code, generate(district)

***CAUTION NOTE: The following code may take some time to work, give it 5 mins and don't 
** interact with the laptop in that duration. Over-heating may cause code to crash, 

** LFPR in India, by Rural/Urban and Male/Female
quietly: collect: svy: mean labor_force, over(Sector Sex) 
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear 

**********************************************
**## Question a data 
**********************************************
** LFPR in India, by District (Using Usual_Principal_Activity_Status and aged 18-59)
quietly: collect: svy, subpop(working_age1): mean labor_force, over(district) 
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear 

**********************************************
**## Question b data 
**********************************************
** Proportion of population not engaged in market work across Indian districts(Using Usual_Principal_Activity_Status and aged 18-59)
quietly: collect: svy, subpop(working_age1): mean not_market_engaged, over(district) 
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear 

**********************************************
**## Question c data 
**********************************************
** Female LFPR in India, by District (Using Usual_Principal_Activity_Status and aged 18-59)
quietly: collect: svy, subpop(working_age1): mean Fem_labor_force, over(district)
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear

**********************************************
**## Question d data 
**********************************************
** Female LFPR in India, by District (Using Usual_Principal_Activity_Status and aged 30-60)
quietly: collect: svy, subpop(working_age2): mean Fem_labor_force, over(district)
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear

**********************************************
**## Question e data 
**********************************************
** Male LFPR in India, by District (Using Usual_Principal_Activity_Status and aged 30-60)
quietly: collect: svy, subpop(working_age2): mean Male_labor_force, over(district)
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear

**********************************************
**## Question f data 
**********************************************
** Proportion of male population not engaged in market work across Indian districts(Using Usual_Principal_Activity_Status and aged 18-30)
quietly: collect: svy, subpop(working_age3): mean Male_not_market_engaged, over(district) 
collect layout (colname) (result[_r_b _r_se _r_ci]) (cmdset) 
collect clear 

****************************************************************************
**# Mapping 
****************************************************************************
** ssc install spmap
** ssc install shp2dta
** ssc install mif2dta 


****************************************************************************
**# Cleaning and Merging District Wise Data with District Names
****************************************************************************
clear
import delimited "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Districts.csv"
rename st_dc Code
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Distrist_names.dta"

clear
import excel "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Cleaned_data.xlsx", sheet("LFPR by District") firstrow
keep Code a
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\a.dta"

clear
import excel "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Cleaned_data.xlsx", sheet("Not Market Engaged by District") firstrow
keep Code b
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\b.dta"

clear
import excel "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Cleaned_data.xlsx", sheet("FLFPR by District") firstrow
keep Code c
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\c.dta"

clear
import excel "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Cleaned_data.xlsx", sheet("FLFPR by District (Aged 30-60)") firstrow 
keep Code d
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\d.dta"

import excel "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Cleaned_data.xlsx", sheet("MLFPR by District (Aged 30-60)") firstrow clear
keep Code e
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\e.dta"

import excel "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Cleaned_data.xlsx", sheet("Male_not_market_engaged (18-30)") firstrow clear
keep Code f
save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\f.dta"

*************************************************************
**# Merging district names with codes
*************************************************************


merge 1:1 Code using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\a.dta"
drop _merge
merge 1:1 Code using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\b.dta"
drop _merge
merge 1:1 Code using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\c.dta"
drop _merge
merge 1:1 Code using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\d.dta"
drop _merge
merge 1:1 Code using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\e.dta"
drop _merge
merge 1:1 Code using "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\f.dta"
drop _merge

save "E:\Ashoka_University\ASP_Spring_2025\International_Trade\International_Trade_Project\Final_wrangled_data.dta"

