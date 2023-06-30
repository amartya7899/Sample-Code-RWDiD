
/*******************************************************************************

	DESCRIPTION: 	.do file looking at the impact of the UG-RW border closure 
					on Rwandan firms' performance. Here we are looking at a 
					balanced panel of firms with canonical sales present in 
					2015 to 2020
						
	INPUTS:			- Oliver imports dataset
						
	OUTPUTS: 		- DiD graphs and estimations
	                - Folder: rwugvat_002_borderClosure_RWDiD_finalDiD_Amartya  
	
	EDIT HISTORY: 	Created December 2022
					Last modified, XX/05/2023

*******************************************************************************/

*Paths (Amartya's laptop):
global UGdata "/Users/Amartya/Dropbox/LSE/RW UG VAT/orig/Uganda"
global RWdata "/Users/Amartya/Dropbox/LSE/RW_anon_tax data"
global outputs "/Users/Amartya/Dropbox/LSE/RW UG VAT/outputs"
global doc "/Users/Amartya/Dropbox/LSE/RW UG VAT/doc"
global data "/Users/Amartya/Dropbox/LSE/RW UG VAT/data"
global temp "/Users/Amartya/Dropbox/LSE/RW UG VAT/temp"
global orig "/Users/Amartya/Dropbox/LSE/RW UG VAT/orig"

*.do file number, to know where the outputs are coming from
global doNum 002

* Set scheme to get better looking graphs
net install scheme-modern, from("https://raw.githubusercontent.com/mdroste/stata-scheme-modern/master/")
set scheme modern, perm

/* 
 Step-1 Import Export Data 
        We create dummy variables for imports and export to explore the extensive 
		margin of production networks
		
 Step-2 Creating Balanced Panel for RW firms
        Here we take an unbalanced panel dataset that contains firm level sales, 
		purchases, imports, exports, pay data and clean it to prepare a final dataset ready for DiD analysis
		
 Step-3 DiD Regressions 
        We conduct 4 variations of DiD analysis 
	   (OLS, Firm Fixed Effects, District Fixed Effects and District Fixed effects with time variation)
*/

/*******************************************************************************
 1. Import Export Data  
*******************************************************************************/
* Import and process data for verified exports

forvalues y = 2015(1)2020{
    * Import data from the CSV file for a specific year
    import delimited "$orig/Rwanda/File requests - May 2022/Belle Fille MURORUNKWERE - Verified Exports `y'.csv", clear
    
    * Generate variables indicating exports from specific countries (TZ, CD, BI) to Rwanda
    gen exports_from_tz = (dest == "TZ" & prov == "RW")
    gen exports_from_cd = (dest == "CD" & prov == "RW")
    gen exports_from_bi = (dest == "BI" & prov == "RW")
    
    * Collapse the data to calculate the sum of exports for each unique identifier (atin)
    collapse (sum) exports_from_tz (sum) exports_from_cd (sum) exports_from_bi, by(atin)
    
    * Replace the variables with a value of 1 if exports are non-zero (indicating presence of exports)
    replace exports_from_tz = 1 if exports_from_tz != 0 
    replace exports_from_cd = 1 if exports_from_cd != 0 
    replace exports_from_bi = 1 if exports_from_bi != 0
    
    * Generate a year variable
    gen year = `y'
    
    * Save the processed data in a temporary file for each year
    save "$data/Amartya's data/RWDiDdata2_temp_ex`y'.dta", replace 
}

* Merge and save the final dataset for exports

use "$data/Amartya's data/RWDiDdata2_temp_ex2015.dta", clear

forvalues y = 2016(1)2020{
    * Append the data from each subsequent year to the initial dataset
    append using "$data/Amartya's data/RWDiDdata2_temp_ex`y'.dta"
}

* Save the merged dataset as the final export dataset
save "$data/Amartya's data/RWDiDdata2_temp_ex.dta", replace 

* Erase the temporary files for exports

forvalues y = 2015(1)2020{
    erase "$data/Amartya's data/RWDiDdata2_temp_ex`y'.dta"
}

* We do similar cleaning with verified exports/anonymised imports and exports data
forvalues y = 2015(1)2020{
import delimited "$orig/Rwanda/File requests - May 2022/Belle Fille MURORUNKWERE - Verified Imports `y'.csv", clear  
gen imports_from_tz = (orig == "TZ" & dest == "RW")
gen imports_from_cd = (orig == "CD" & dest == "RW")
gen imports_from_bi = (orig == "BI" & dest == "RW")
collapse (sum)imports_from_tz (sum)imports_from_cd (sum)imports_from_bi, by(atin)
replace imports_from_tz = 1 if imports_from_tz !=0 
replace imports_from_cd = 1 if imports_from_cd !=0 
replace imports_from_bi = 1 if imports_from_bi !=0 
gen year = `y' 
save "$data/Amartya's data/RWDiDdata2_temp_im`y'.dta", replace 
}
use "$data/Amartya's data/RWDiDdata2_temp_im2015.dta", clear
forvalues y = 2016(1)2020{
append using "$data/Amartya's data/RWDiDdata2_temp_im`y'.dta"
} 
save "$data/Amartya's data/RWDiDdata2_temp_im.dta", replace 
forvalues y = 2015(1)2020{
erase "$data/Amartya's data/RWDiDdata2_temp_im`y'.dta"
} 

forvalues y = 2015(1)2020{
import delimited "$orig/Rwanda/File requests - May 2022/Belle Fille - Anonymized Imports and Exports `y'.csv", clear 
gen imports_from_tz = (orig == "TZ" & dest == "RW")
gen imports_from_cd = (orig == "CD" & dest == "RW")
gen imports_from_bi = (orig == "BI" & dest == "RW")
gen exports_from_tz = (dest == "TZ" & prov == "RW")
gen exports_from_cd = (dest == "CD" & prov == "RW")
gen exports_from_bi = (dest == "BI" & prov == "RW")
collapse (sum)imports_from_tz (sum)imports_from_cd (sum)imports_from_bi (sum)exports_from_tz (sum)exports_from_cd (sum)exports_from_bi, by(atin)
replace imports_from_tz = 1 if imports_from_tz !=0 
replace imports_from_cd = 1 if imports_from_cd !=0 
replace imports_from_bi = 1 if imports_from_bi !=0 
replace exports_from_tz = 1 if exports_from_tz !=0 
replace exports_from_cd = 1 if exports_from_cd !=0 
replace exports_from_bi = 1 if exports_from_bi !=0
gen year = `y' 
save "$data/Amartya's data/RWDiDdata2_temp_exim`y'.dta", replace 
} 
 
use "$data/Amartya's data/RWDiDdata2_temp_exim2015.dta", clear
forvalues y = 2016(1)2020{
append using "$data/Amartya's data/RWDiDdata2_temp_exim`y'.dta"
} 
save "$data/Amartya's data/RWDiDdata2_temp_exim.dta", replace 

forvalues y = 2015(1)2020{
erase "$data/Amartya's data/RWDiDdata2_temp_exim`y'.dta"
} 

 
/*******************************************************************************
 2. Creating Balanced Panel for RW firms 
*******************************************************************************/

* 126_panel_importers1618 dataset has all the firm level panel data created by the previous RA with a few missing variables which could be merged with step-1 data
use "$data/126_panel_importers1618.dta", clear

* Keep only the necessary variables
keep atin year orig_treatment_1718 vatsaOnly_vrfd_rp intsctn_vrfd_avg_rp vatpaOnly_vrfd_rp vatsaOnly_vrfd_rs intsctn_vrfd_avg_rs vatpaOnly_vrfd_rs total_real_exports canonical_real_sales nr_sales nr_purchases total_real_imports orig_ug_real_imports orig_cdbitz_real_imports orig_no_border_real_imports total_real_exports

* Generate treatment and control variables
gen treatment = orig_treatment_1718
gen control = orig_treatment_1718 == 0

* Keep observations with treatment or control
keep if treatment == 1 | control == 1

* Keep observations between 2015 and 2020
keep if year >= 2015 & year <= 2020

* Order variables (optional)
*order vatsaOnly_vrfd_rp intsctn_vrfd_avg_rp vatpaOnly_vrfd_rp vatsaOnly_vrfd_rs intsctn_vrfd_avg_rs vatpaOnly_vrfd_rs

* Generate variables for purchases and sales
gen purchases = vatsaOnly_vrfd_rp + intsctn_vrfd_avg_rp + vatpaOnly_vrfd_rp
gen sales = vatsaOnly_vrfd_rs + intsctn_vrfd_avg_rs + vatpaOnly_vrfd_rs

* Generate new values for total sales, domestic sales, and exports
gen exports_new = total_real_exports
replace exports_new = 0 if exports_new == .
gen domestic_sales_new = sales
replace domestic_sales_new = 0 if domestic_sales_new == .
gen total_sales_new = exports_new + domestic_sales_new
replace total_sales_new = . if total_sales_new == 0
gen canonical_sales_new = canonical_real_sales
replace canonical_sales_new = total_sales_new if total_sales_new != . & canonical_sales_new == .
gen total_sales = canonical_sales_new
replace total_sales = 0 if total_sales == .

* Sort by firm and year
sort atin year

* Preserve the dataset for later use
preserve

* Keep only relevant variables for further analysis
keep atin year total_sales treatment

* Generate a unique identifier for each firm
egen long id = group(atin)

* Sort by id and year for panel data analysis
sort id year
xtset id year

* Generate a binary variable x for firms with zero sales that have non-zero sales in other years
gen x = (total_sales == 0 & f.total_sales != 0)

* Replace x with 0 for the last observation within each firm
by id: replace x = 0 if _n == _N

* Collapse the dataset to the firm level, summing x and calculating the mean of treatment
collapse (sum) x (mean) treatment, by(atin)
replace x = 1 if x != 0

* Print the number of unique firms based on x and treatment conditions
unique atin if x == 1 & treatment == 1 // 1,256 unique firms
unique atin if x == 1 & treatment == 0 // 3,118 unique firms
unique atin if x == 0 & treatment == 1 // 5,331 unique firms out of which 1,284 unique firms make the final cut


unique atin if x == 0 & treatment == 0 // 21,386 unique firms out of which 2,790 unique firms make the final cut

* Restore the preserved dataset
restore

* Keep firms that have total sales in a year
gen keep = (total_sales != . & total_sales != 0)
tab year treatment if keep == 1
bys atin: egen tot = sum(keep)

* Print the count of observations with tot equal to 6 in 2018
tab tot if year == 2018

* Keep observations with tot equal to 6
keep if tot == 6

* Drop control, keep, and tot variables
drop control keep tot

* Sort by firm and year
sort atin year

* Print the number of unique firms based on treatment
unique atin if treatment == 1 // 1,307 firms
unique atin if treatment == 0 // 2,808 firms

* Preserve the dataset for later use
preserve

* Collapse the dataset to the firm level, summing total_sales, nr_sales, and nr_purchases
collapse total_sales nr_sales nr_purchases, by(atin)

* Sort the dataset by total_sales in descending order
gsort -total_sales

* Generate a binary variable sno_totsales for firms with less than or equal to 1% of total sales
gen sno_totsales = ((_n / _N) * 100 > 1)

* Sort the dataset by nr_sales in descending order
gsort -nr_sales

* Generate a binary variable sno_nr_sales for firms with less than or equal to 1% of nr_sales
gen sno_nr_sales = ((_n / _N) * 100 > 1)

* Sort the dataset by nr_purchases in descending order
gsort -nr_purchases

* Generate a binary variable sno_nr_purchases for firms with less than or equal to 1% of nr_purchases
gen sno_nr_purchases = ((_n / _N) * 100 > 1)

* Print the number of unique firms with sno_totsales and sno_nr_sales equal to 0
unique atin if sno_totsales == 0 & sno_nr_sales == 0 // 5 records

* Print the number of unique firms with sno_totsales and sno_nr_purchases equal to 0
unique atin if sno_totsales == 0 & sno_nr_purchases == 0 // 5 records

* Save the dataset as RWDiDdata2_temp.dta
save "$data/Amartya's data/RWDiDdata2_temp.dta", replace

* Restore the preserved dataset
restore

* Merge the dataset with RWDiDdata2_temp.dta using atin as the key
merge m:1 atin using "$data/Amartya's data/RWDiDdata2_temp.dta"

* Drop the merge indicator variable
drop _merge

* Erase the temporary dataset RWDiDdata2_temp.dta
erase "$data/Amartya's data/RWDiDdata2_temp.dta"

* Print the number of unique firms with sno_totsales equal to 0 and treatment equal to 1
unique atin if sno_totsales == 0 & treatment == 1 // 23 firms

* Print the number of unique firms with sno_totsales equal to 0 and treatment equal to 0
unique atin if sno_totsales == 0 & treatment == 0 // 18 firms

* Drop observations with sno_totsales equal to 0
drop if sno_totsales == 0

* Print the number

 of unique firms based on treatment
unique atin if treatment == 1 // 1,284 firms
unique atin if treatment == 0 // 2,790 firms

* Save the dataset as RWDiDdata_temp_finalids.dta
save "$data/Amartya's data/RWDiDdata_temp_finalids.dta", replace

* Clear the current dataset and load RWDiDdata_temp_finalids.dta
use "$data/Amartya's data/RWDiDdata_temp_finalids.dta", clear

* Preserve the dataset for later use
preserve

* Keep only atin and treatment variables
keep atin treatment

* Rename treatment variable to treated
ren treatment treated

* Drop duplicate observations
duplicates drop

* Generate a variable x with a value of 1 for all observations
gen x = 1

* Save the dataset as RWDiDdata2_finalfirms.dta
save "$data/Amartya's data/RWDiDdata2_finalfirms.dta", replace
restore

* Print the number of unique firms based on treatment
unique atin if treatment == 1 // 1,284 firms
unique atin if treatment == 0 // 2,790 firms

* Merge the dataset with RWDiDdata2_temp_ex.dta using atin and year as the key
merge m:1 atin year using "$data/Amartya's data/RWDiDdata2_temp_ex.dta"

* Drop observations that did not merge successfully
drop if _m == 2
drop _m

* Merge the dataset with RWDiDdata2_temp_im.dta using atin and year as the key
merge m:1 atin year using "$data/Amartya's data/RWDiDdata2_temp_im.dta"

* Drop observations that did not merge successfully
drop if _m == 2
drop _m


*bro if orig_cdbitz_real_imports != . & (imports_from_tz ==. |imports_from_cd==. |imports_from_bi==.)
*bro if nfl_cdbitz_real_exports !=. & (exports_from_tz==. |exports_from_cd ==. |exports_from_bi==.)

* Set the variable to zero if missing 
replace imports_from_tz = 0 if imports_from_tz ==.
replace imports_from_cd = 0 if imports_from_cd ==.
replace imports_from_bi = 0 if imports_from_bi ==. 
replace exports_from_tz = 0 if exports_from_tz ==. 
replace exports_from_cd = 0 if exports_from_cd ==.
replace exports_from_bi = 0 if exports_from_bi ==.

* Create log values for all the levels variables 
gen ln_sales = ln(sales)
gen ln_purchases = ln(purchases)

gen imports = total_real_imports
gen imports_ug = orig_ug_real_imports
gen imports_cdbitz = orig_cdbitz_real_imports
gen imports_no_border = orig_no_border_real_imports

gen ln_imports = ln(total_real_imports)
gen ln_imports_ug = ln(orig_ug_real_imports)
gen ln_imports_cdbitz = ln(orig_cdbitz_real_imports)
gen ln_imports_no_border = ln(orig_no_border_real_imports)


gen exports = total_real_exports
gen exports_ug = nfl_ug_real_exports
gen exports_cdbitz = nfl_cdbitz_real_exports
gen exports_no_border = nfl_no_border_real_exports

gen ln_exports = ln(total_real_exports)
gen ln_exports_ug = ln(nfl_ug_real_exports)
gen ln_exports_cdbitz = ln(nfl_cdbitz_real_exports)
gen ln_exports_no_border = ln(nfl_no_border_real_exports)

* Create dummy variables to study extensive margin 
gen buyers_extensivemargin = (nr_sales != .)
gen suppliers_extensivemargin = (nr_purchases != .)

gen imports_from_ug = (orig_ug_real_imports != . & orig_ug_real_imports != 0)
gen imports_from_cdbitz = (orig_cdbitz_real_imports != . & orig_cdbitz_real_imports != 0)
gen imports_from_no_border  = (orig_no_border_real_imports != . & orig_no_border_real_imports != 0)
gen imports_from_RoW = ((orig_cdbitz_real_imports != . & orig_cdbitz_real_imports != 0) | (orig_no_border_real_imports != . & orig_no_border_real_imports != 0))

gen exports_to_ug = (nfl_ug_real_exports != . & nfl_ug_real_exports != 0)
gen exports_to_cdbitz = (nfl_cdbitz_real_exports != . & nfl_cdbitz_real_exports != 0)
gen exports_to_no_border = (nfl_no_border_real_exports != . & nfl_no_border_real_exports != 0)
gen exports_to_RoW = ((nfl_cdbitz_real_exports != . & nfl_cdbitz_real_exports != 0) | (nfl_no_border_real_exports != . & nfl_no_border_real_exports != 0))

gen nr_customers = nr_sales
gen nr_suppliers = nr_purchases

gen ln_nr_customers = ln(nr_sales) 
gen ln_nr_suppliers = ln(nr_purchases)

* Set the variable to zero if missing 
replace perm_emp_agg_clean = 0 if perm_emp_agg_clean ==.
replace cas_emp_agg = 0 if cas_emp_agg ==.
replace second_emp_agg = 0 if second_emp_agg ==.



foreach v in canonical_real_sales total_real_exports sales perm_pay_agg_clean cas_pay_agg second_pay_agg perm_emp_agg_clean cas_emp_agg second_emp_agg {
	replace `v' = 0 if `v'==.
}

gen ln_canonical_sales = ln(canonical_real_sales)
gen ln_total_sales = ln(total_sales)
gen ln_pay_employees = ln(perm_pay_agg_clean + cas_pay_agg + second_pay_agg)
gen ln_nr_employees = ln(perm_emp_agg_clean + cas_emp_agg + second_emp_agg )

* Generate a unique identifier 'id' for each observation based on 'atin'
egen long id = group(atin)

* Sort the data by 'id' and 'year'
sort id year

* Loop over the variables and replace missing values with 0
foreach v in sales purchases nr_customers nr_suppliers imports imports_ug imports_cdbitz imports_no_border exports exports_ug exports_cdbitz exports_no_border {
    replace `v' = 0 if `v' == .
}

* Rename 'treatment' variable to 'treated'
ren treatment treated 

* Preserve the dataset in its current state
preserve 

* Keep only the necessary variables and save the dataset as a new file
keep atin year total_sales treated
save "$data/Amartya's data/RWDiDdata2_finalfirms_totalsales.dta", replace 
restore

* Keep only the selected variables for further analysis
keep atin year sales ln_sales purchases ln_purchases nr_customers ln_nr_customers nr_suppliers ln_nr_suppliers imports imports_ug imports_cdbitz imports_no_border ln_imports ln_imports_ug ln_imports_cdbitz ln_imports_no_border exports exports_ug exports_cdbitz exports_no_border ln_exports ln_exports_ug ln_exports_cdbitz ln_exports_no_border suppliers_extensivemargin buyers_extensivemargin imports_from_ug imports_from_cdbitz imports_from_tz imports_from_cd imports_from_bi imports_from_no_border imports_from_RoW exports_to_ug exports_to_cdbitz exports_from_tz exports_from_cd exports_from_bi exports_to_no_border exports_to_RoW ln_canonical_sales ln_total_sales ln_pay_employees ln_nr_employees treated total_sales 

* Order the variables in a specific order
order atin year sales ln_sales purchases ln_purchases nr_customers ln_nr_customers nr_suppliers ln_nr_suppliers imports imports_ug imports_cdbitz imports_no_border ln_imports ln_imports_ug ln_imports_cdbitz ln_imports_no_border exports exports_ug exports_cdbitz exports_no_border ln_exports ln_exports_ug ln_exports_cdbitz ln_exports_no_border suppliers_extensivemargin buyers_extensivemargin imports_from_ug imports_from_cdbitz imports_from_tz imports_from_cd imports_from_bi imports_from_no_border imports_from_RoW exports_to_ug exports_to_cdbitz exports_from_tz exports_from_cd exports_from_bi exports_to_no_border exports_to_RoW ln_canonical_sales ln_total_sales ln_pay_employees ln_nr_employees treated total_sales

* Merge the 'atin' variable from another dataset called "add_RW.dta"
merge m:1 atin using "$data/Amartya's data/add_RW.dta"

* Drop the observations that failed to merge
drop if _merge == 2

* Drop the merge indicator variable '_merge'
drop _merge 

* Sort the data by 'atin'
sort atin 

* Clean and standardize the 'add_district_overall' variable based on certain conditions
replace add_CIT = upper(add_CIT)
replace add_PIT = upper(add_PIT)
replace add_VAT = substr(add_VAT, 1, strpos(add_VAT, " ") - 1)

* Generate the 'add_district_overall' variable using priority-based replacements
mdesc 
gen add_district_overall = add_district_PAYE
replace add_district_overall = add_VAT if add_district_overall == "" & substr(add_VAT,1,6) != "KIGALI"
replace add_district_overall = add_CIT if add_district_over

all == "" & substr(add_CIT,1,6) != "KIGALI" 
replace add_district_overall = add_PIT if add_district_overall == "" & substr(add_PIT,1,6) != "KIGALI" 

* Replace specific values of 'add_district_overall' based on 'atin' values
replace add_district_overall = "KIREHE" if atin == "0c2eb0fdb86132af4600062e64dedd52"
replace add_district_overall = "RUBAVU" if atin == "53c38beacaf7403d4e3263db8d25c2d5"
replace add_district_overall = "KICUKIRO" if atin == "dd514f4f147559209b485789a29f3eba"

* Set 'add_district_overall' to "KIGALI" if it is still missing and any of the three variables ('add_VAT', 'add_CIT', 'add_PIT') doesn't start with "KIGALI"
replace add_district_overall = "KIGALI" if add_district_overall == "" & (substr(add_VAT,1,6) != "KIGALI" | substr(add_CIT,1,6) != "KIGALI" | substr(add_PIT,1,6) != "KIGALI")

* Perform additional replacements on 'add_district_overall' based on specific conditions
replace add_district_overall = "KICUKIRO" if add_district_overall == "KABUGA"
replace add_district_overall = "NYARUGENGE" if add_district_overall == "NYARUGENGE-MICRO"
replace add_district_overall = "RUSIZI" if add_district_overall == "RUSIZI DTD"

* Rename 'add_district_overall' to 'District'
ren add_district_overall District

* Merge the 'District' variable from another dataset called "Rwanda_District_Province.dta"
merge m:1 District using "$data/Amartya's data/Rwanda_District_Province.dta"

* Replace the values of 'Province' based on specific conditions
replace Province = "KIGALI CITY" if _merge == 1 & District == "KIGALI"
replace District = "KIGALI" if District == "GASABO" | District == "NYARUGENGE" | District == "KICUKIRO"

* Drop unnecessary variables
drop _merge add_CIT add_province_PAYE add_district_PAYE add_PIT add_VAT add_anonEx add_anonIm add_VAT_annex add_VAT_purchases add_verex add_verim

* Sort the data by 'atin' and 'year'
sort atin year 

* Generate a running variable 'num' within groups defined by 'atin' and 'year'
bys atin year: gen num = _n

* Modify the 'atin' variable by appending the 'num' as a string
replace atin = atin + string(num)

* Generate binary indicators for non-zero values of 'sales', 'purchases', 'exports', and 'imports'
gen pr_sales = (sales != 0)
gen pr_purchases = (purchases != 0)
gen pr_exports = (exports != 0)
gen pr_imports = (imports != 0)

* Save the modified dataset as a new file
save "$data/Amartya's data/RWDiDdata2.dta", replace

* Export the dataset as a CSV file
export

 delimited using "$data/Amartya's data/rwugvat_002_borderClosure_RWDiD_final_no_specification.csv", replace

* Clear the current dataset and load the saved dataset
use "$data/Amartya's data/RWDiDdata2.dta", clear 

* Keep only the necessary variables for analysis
keep atin year total_sales treated 

* Collapse the data by 'year' and 'treated' variables while calculating the sum of 'total_sales'
collapse total_sales, by(year treated)

* Generate the natural logarithm of 'total_sales' and store it in a new variable 'ln_total_sales'
gen ln_total_sales = ln(total_sales)

* Create a line graph to compare the trend of 'ln_total_sales' over 'year' between the treatment and control groups
twoway (line ln_total_sales year if treated == 1, lcolor(blue)) ///
       (line ln_total_sales year if treated == 0, lcolor(red)), ///
       xtitle("Year") ytitle("Ln Total Sales") ylabel(19.4(0.3)20.9) title("Ln Avg Total Sales 17-18 - No Specification") ///
       legend(order(1 "Treatment" 2 "Control") label(1 "Treatment Group Label") label(2 "Control Group Label"))

* Export the graph as a PNG image
gr export "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/treatvscont_total_sales_nospecification.png", as(png) replace

* Clear all graphs from memory
graph drop _all

/*******************************************************************************
 3: DiD Regressions 
*******************************************************************************/

* Clear the current dataset and load the saved dataset
use "$data/Amartya's data/RWDiDdata2.dta", clear 

* Generate variables 't' and 't2' based on the 'year' variable
gen t = year - 2018
gen t2 = t + 4

* Create indicator variables 'dum_' for each value of 't'
tab t, gen(dum_)

* Generate variables 'TXTreated_1' to 'TXTreated_6' based on the interaction of 'dum_' variables and 'treated'
forval i = 1/6 {
    gen TXTreated_`i' = dum_`i' * treated
}

* Encode variables 'District' and 'atin' to create new variables 'dis' and 'id' respectively
encode District, gen(dis)
encode atin, gen(id)

* Sort the data by 'id' and 't'
sort id t

* Set the panel data structure using 'id' as the panel identifier and 't2' as the time variable
xtset id t2

* Rename 'treated' variable to 'treatment'
ren treated treatment

* Perform OLS regression for each variable in the varlist
foreach var of varlist sales ln_sales purchases ln_purchases nr_customers ln_nr_customers nr_suppliers ln_nr_suppliers imports ln_imports imports_ug ln_imports_ug imports_cdbitz ln_imports_cdbitz imports_no_border ln_imports_no_border exports ln_exports exports_ug ln_exports_ug exports_cdbitz ln_exports_cdbitz exports_no_border ln_exports_no_border ln_nr_employees ln_pay_employees ln_total_sales suppliers_extensivemargin buyers_extensivemargin imports_from_ug imports_from_tz imports_from_cd imports_from_bi imports_from_cdbitz imports_from_no_border imports_from_RoW exports_to_ug exports_from_tz exports_from_cd exports_from_bi exports_to_cdbitz exports_to_no_border exports_to_RoW pr_sales pr_purchases pr_exports pr_imports {
	
	* OLS Regression 
    reg `var' TXTreated_1-TXTreated_3 TXTreated_5-TXTreated_6 dum_1-dum_6 treated
    
    * Tabulate the treatment group count for 2018 and store it in a global macro
    tab treatment if treatment == 1 & year == 2018 & e(sample)
    global N_treated = round(`r(N)', 1)
    di $N_treated
    
    * Tabulate the control group count for 2018 and store it in a global macro
    tab treatment if treatment == 0 & year == 2018 & e(sample)
    global N_control = round(`r(N)', 1)
    di $N_control

    * Calculate the critical value for the confidence interval
    local T = -invt(`e(df_r)', .025)
    di `e(df_r)'
    di `T'

    * Store the coefficient estimates and variance-covariance matrix in matrices
    matrix b = e(b)
    matrix V = e(V)

    preserve
        clear
        local obs = 6 // from 2015 to 2020
        set obs `obs'
        quietly gen t = _n - 4
        quietly gen b = .
        quietly gen l = .
        quietly gen u = .
        forval i = 1/`obs' {
            quietly replace b = b[1,`i'] if _n == `i'
            quietly replace l = b[1,`i'] - `T' * sqrt(V[`i',`i']) if _n == `i'
            quietly replace u = b[1,`i'] + `T' * sqrt(V[`i',`i']) if _n == `i'
        }
        
        * Replace missing values and assign values to 't'
        replace t = . if t == 2
        replace t = 2 if t == 1
        replace t = 1 if t == 0
        replace t = 0 if t == .
        replace b = 0 if t == 0
        replace l = 0 if t == 0
        replace u = 0 if t == 0

        * Create a graph with confidence intervals
        twoway (rcap u l t, color(navy) msize(0)) ///
            (scatter b t, mlcolor(navy) mfcolor(white) msymbol(O)), ///
            yline(0, lpattern(dash) lcolor(gs8)) xline(0.5, lcolor(red)) legend(off) title("`var'") xlabel(-3(1)2) name(g1)
        
        * Save the data for the current variable in a separate file
        save "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/OLS no specification/${doNum}_DiD_`var'_data_ols_nospecification.dta", replace
    restore

    preserve
        keep if e(sample)
        gen count = 1
        tab year treatment
        collapse (mean) `var' (sem) se = `var' (sum) count, by(treatment year)
        gen u = `var' + 1.96 * se
        gen l = `var' - 1.96 * se
        
        * Create a graph to visualize the mean and confidence intervals
        twoway (scatter `var' year if treatment == 1, color(blue%10) mlabel(count) mlabpos(0) msize(0)) ///
            (scatter `var' year if treatment == 0, color(red%10) mlabel(count) mlabpos(0) msize(0)) ///
            (rarea u l year if treatment == 1, color(blue%10)) ///
            (rarea u l year if treatment == 0, color(red%10)), ///
            legend(order(3 "T" 4 "C") pos(11) ring(0)) xlabel(2015(1)2020) xline(2018.5) ///
            name(g2)
        
        * Save the graph as an image
        //graph save "$outputs/${doNum}_trends_`var'.gph", replace
    restore

    * Combine the two graphs into a single figure
    graph dir
    graph combine `r(list)', col(1) imargin(0)
    gr export "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/OLS no specification/${doNum}_DiD_`var'_ols_nospecification.png", as(png) replace
    graph drop _all
}

*Firm Fixed Effects
foreach var of varlist sales ln_sales purchases ln_purchases  nr_customers ln_nr_customers nr_suppliers ln_nr_suppliers imports ln_imports imports_ug ln_imports_ug imports_cdbitz ln_imports_cdbitz imports_no_border  ln_imports_no_border exports ln_exports exports_ug ln_exports_ug exports_cdbitz ln_exports_cdbitz exports_no_border ln_exports_no_border ln_nr_employees ln_pay_employees ln_total_sales suppliers_extensivemargin buyers_extensivemargin imports_from_ug  imports_from_tz imports_from_cd imports_from_bi imports_from_cdbitz imports_from_no_border imports_from_RoW exports_to_ug exports_from_tz exports_from_cd exports_from_bi exports_to_cdbitz exports_to_no_border exports_to_RoW pr_sales pr_purchases pr_exports pr_imports{
	
    xtreg `var' TXTreated_1-TXTreated_3 TXTreated_5-TXTreated_6 dum_1-dum_6 treated, fe

	tab treatment if treatment==1 & year == 2018 & e(sample)
	global N_treated = round(`r(N)', 1)
	di $N_treated
	tab treatment if treatment==0 & year == 2018 & e(sample)
	global N_control = round(`r(N)', 1)
	di $N_control

	*local inoc=`r(N)'
	local T=-invt(`e(df_r)',.025)
	di `e(df_r)'
	di `T'
	matrix b = e(b)
	matrix V = e(V)

	preserve
		clear
		local obs=6 // from 2015 to 2020
		set obs `obs'
		quietly gen t=_n-4
		quietly gen b=.
		quietly gen l=.
		quietly gen u=.
		forval i=1/`obs' {
			quietly replace b=b[1,`i'] if _n==`i'
			quietly replace l=b[1,`i'] - `T'*sqrt(V[`i',`i']) if _n==`i'
			quietly replace u=b[1,`i'] + `T'*sqrt(V[`i',`i']) if _n==`i'
			}
			
		replace t=. if t==2
		replace t=2 if t==1
		replace t=1 if t==0
		replace t=0 if t==.
		replace b = 0 if t==0
		replace l = 0 if t==0
		replace u = 0 if t==0

		
		twoway (rcap u l t , color(navy) msize(0)) ///
			(scatter b t, mlcolor(navy) mfcolor(white) msymbol(O) ),				///
					yline(0, lpattern(dash) lcolor(gs8)) xline(0.5, lcolor(red))  legend(off) title("`var'") xlabel(-3(1)2) name(g1)
					/*note("$N_treated treated firms in 2018" "$N_control control firms")*/
	

		save "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/Firm FE no specification/${doNum}_DiD_`var'_data_firmfe_nospecification.dta", replace
		
	restore
	
	preserve
		keep if e(sample)
		gen count = 1
		tab year treatment
		collapse (mean) `var' (sem) se = `var' (sum) count, by(treatment year)
		gen u = `var'+1.96*se
		gen l = `var'-1.96*se
		
		twoway (scatter `var' year if treatment == 1, color(blue%10) mlabel(count) mlabpos(0) msize(0)) ///
			(scatter `var' year if treatment == 0, color(red%10) mlabel(count) mlabpos(0) msize(0)) ///
			(rarea u l year if treatment == 1, color(blue%10)) /// 
			(rarea u l year if treatment == 0, color(red%10)), ///
			legend(order(3 "T" 4 "C") pos(11) ring(0)) xlabel(2015(1)2020) xline(2018.5) ///
			name(g2)
		//graph save "$outputs/${doNum}_trends_`var'.gph", replace
		
	restore
	
	*combining graphs
	graph dir
	graph combine `r(list)', col(1) imargin(0)
	gr export "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/Firm FE no specification/${doNum}_DiD_`var'_firmfe_nospecification.png", as(png) replace
	graph drop _all
	}

*District Fixed Effects
foreach var of varlist sales ln_sales purchases ln_purchases  nr_customers ln_nr_customers nr_suppliers ln_nr_suppliers imports ln_imports imports_ug ln_imports_ug imports_cdbitz ln_imports_cdbitz imports_no_border  ln_imports_no_border exports ln_exports exports_ug ln_exports_ug exports_cdbitz ln_exports_cdbitz exports_no_border ln_exports_no_border ln_nr_employees ln_pay_employees ln_total_sales suppliers_extensivemargin buyers_extensivemargin imports_from_ug  imports_from_tz imports_from_cd imports_from_bi imports_from_cdbitz imports_from_no_border imports_from_RoW exports_to_ug exports_from_tz exports_from_cd exports_from_bi exports_to_cdbitz exports_to_no_border exports_to_RoW pr_sales pr_purchases pr_exports pr_imports{
	
    reg `var' TXTreated_1-TXTreated_3 TXTreated_5-TXTreated_6 dum_1-dum_6 treated i.dis

	tab treatment if treatment==1 & year == 2018 & e(sample)
	global N_treated = round(`r(N)', 1)
	di $N_treated
	tab treatment if treatment==0 & year == 2018 & e(sample)
	global N_control = round(`r(N)', 1)
	di $N_control

	*local inoc=`r(N)'
	local T=-invt(`e(df_r)',.025)
	di `e(df_r)'
	di `T'
	matrix b = e(b)
	matrix V = e(V)

	preserve
		clear
		local obs=6 // from 2015 to 2020
		set obs `obs'
		quietly gen t=_n-4
		quietly gen b=.
		quietly gen l=.
		quietly gen u=.
		forval i=1/`obs' {
			quietly replace b=b[1,`i'] if _n==`i'
			quietly replace l=b[1,`i'] - `T'*sqrt(V[`i',`i']) if _n==`i'
			quietly replace u=b[1,`i'] + `T'*sqrt(V[`i',`i']) if _n==`i'
			}
			
		replace t=. if t==2
		replace t=2 if t==1
		replace t=1 if t==0
		replace t=0 if t==.
		replace b = 0 if t==0
		replace l = 0 if t==0
		replace u = 0 if t==0

		twoway (rcap u l t , color(navy) msize(0)) ///
			(scatter b t, mlcolor(navy) mfcolor(white) msymbol(O) ),				///
					yline(0, lpattern(dash) lcolor(gs8)) xline(0.5, lcolor(red))  legend(off) title("`var'") xlabel(-3(1)2) name(g1)
					/*note("$N_treated treated firms in 2018" "$N_control control firms")*/
	
	
		save "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/${doNum}_DiD_`var'_data_districtfe_nospecification.dta", replace
	restore
	
	preserve
		keep if e(sample)
		gen count = 1
		tab year treatment
		collapse (mean) `var' (sem) se = `var' (sum) count, by(treatment year)
		gen u = `var'+1.96*se
		gen l = `var'-1.96*se
		twoway (scatter `var' year if treatment == 1, color(blue%10) mlabel(count) mlabpos(0) msize(0)) ///
			(scatter `var' year if treatment == 0, color(red%10) mlabel(count) mlabpos(0) msize(0)) ///
			(rarea u l year if treatment == 1, color(blue%10)) /// 
			(rarea u l year if treatment == 0, color(red%10)), ///
			legend(order(3 "T" 4 "C") pos(11) ring(0)) xlabel(2015(1)2020) xline(2018.5) ///
			name(g2)
		//graph save "$outputs/${doNum}_trends_`var'.gph", replace
	restore
	
	*combining graphs
	graph dir
	graph combine `r(list)', col(1) imargin(0)
	gr export "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/${doNum}_DiD_`var'_districtfe_nospecification.png", as(png) replace
	graph drop _all
	}

*District Fixed Effects with year interaction
foreach var of varlist sales ln_sales purchases ln_purchases  nr_customers ln_nr_customers nr_suppliers ln_nr_suppliers imports ln_imports imports_ug ln_imports_ug imports_cdbitz ln_imports_cdbitz imports_no_border  ln_imports_no_border exports ln_exports exports_ug ln_exports_ug exports_cdbitz ln_exports_cdbitz exports_no_border ln_exports_no_border ln_nr_employees ln_pay_employees ln_total_sales suppliers_extensivemargin buyers_extensivemargin imports_from_ug  imports_from_tz imports_from_cd imports_from_bi imports_from_cdbitz imports_from_no_border imports_from_RoW exports_to_ug exports_from_tz exports_from_cd exports_from_bi exports_to_cdbitz exports_to_no_border exports_to_RoW pr_sales pr_purchases pr_exports pr_imports{
	
    reg `var' TXTreated_1-TXTreated_3 TXTreated_5-TXTreated_6 dum_1-dum_6 treated i.dis#i.year i.dis

	tab treatment if treatment==1 & year == 2018 & e(sample)
	global N_treated = round(`r(N)', 1)
	di $N_treated
	tab treatment if treatment==0 & year == 2018 & e(sample)
	global N_control = round(`r(N)', 1)
	di $N_control

	*local inoc=`r(N)'
	local T=-invt(`e(df_r)',.025)
	di `e(df_r)'
	di `T'
	matrix b = e(b)
	matrix V = e(V)

	preserve
		clear
		local obs=6 // from 2015 to 2020
		set obs `obs'
		quietly gen t=_n-4
		quietly gen b=.
		quietly gen l=.
		quietly gen u=.
		forval i=1/`obs' {
			quietly replace b=b[1,`i'] if _n==`i'
			quietly replace l=b[1,`i'] - `T'*sqrt(V[`i',`i']) if _n==`i'
			quietly replace u=b[1,`i'] + `T'*sqrt(V[`i',`i']) if _n==`i'
			}
			
		replace t=. if t==2
		replace t=2 if t==1
		replace t=1 if t==0
		replace t=0 if t==.
		replace b = 0 if t==0
		replace l = 0 if t==0
		replace u = 0 if t==0

		twoway (rcap u l t , color(navy) msize(0)) ///
			(scatter b t, mlcolor(navy) mfcolor(white) msymbol(O) ),				///
					yline(0, lpattern(dash) lcolor(gs8)) xline(0.5, lcolor(red))  legend(off) title("`var'") xlabel(-3(1)2) name(g1)
					/*note("$N_treated treated firms in 2018" "$N_control control firms")*/
	
	
		save "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/${doNum}_DiD_`var'_data_districtfeinteraction_nospecification.dta", replace
	restore
	
	preserve
		keep if e(sample)
		gen count = 1
		tab year treatment
		collapse (mean) `var' (sem) se = `var' (sum) count, by(treatment year)
		gen u = `var'+1.96*se
		gen l = `var'-1.96*se
		twoway (scatter `var' year if treatment == 1, color(blue%10) mlabel(count) mlabpos(0) msize(0)) ///
			(scatter `var' year if treatment == 0, color(red%10) mlabel(count) mlabpos(0) msize(0)) ///
			(rarea u l year if treatment == 1, color(blue%10)) /// 
			(rarea u l year if treatment == 0, color(red%10)), ///
			legend(order(3 "T" 4 "C") pos(11) ring(0)) xlabel(2015(1)2020) xline(2018.5) ///
			name(g2)
		//graph save "$outputs/${doNum}_trends_`var'.gph", replace
	restore
	
	*combining graphs
	graph dir
	graph combine `r(list)', col(1) imargin(0)
	gr export "$outputs/Amartya's outputs/rwugvat_${doNum}_borderClosure_RWDiD_finalDiD_Amartya/${doNum}_DiD_`var'_districtfeinteraction_nospecification.png", as(png) replace
	graph drop _all
	}

* Erase all the intermediary files 
erase "$data/Amartya's data/RWDiDdata2_temp_ex.dta"
erase "$data/Amartya's data/RWDiDdata2_temp_im.dta"
erase "$data/Amartya's data/RWDiDdata2_temp_exim.dta"
erase "$data/Amartya's data/RWDiDdata2_finalfirms_totalsales.dta"
erase "$data/Amartya's data/RWDiDdata2_finalfirms_professions.dta"
 
 
