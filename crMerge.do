/****　***** ***** ***** ***** *****
*
* Merge All dta files
* 
***** ***** ***** ***** ***** ****/

use Dataset_base, clear
merge m:1 pref using Dataset_pop,           gen(merge4)
merge m:1 pref using Dataset_variant,       gen(merge5)
merge 1:1 pref date using Dataset_cum_case, gen(merge6)

drop merge*

label variable date "Date"
label variable pref "Prefecture"
label variable new_case "New case"
label variable new_death "New death case"
label variable cum_death "Cummulative death case"
label variable total_shot "Total vaccine shot"
label variable first_shot "1st vaccine shot"
label variable second_shot "2nd vaccine shot"
label variable prov "Provision"
label variable pop_total "Total population"
label variable pop_00_14 "Population age 0-14"
label variable pop_15_64 "Population age 15-64"
label variable pop_65_ov "Population age 65-"
label variable pop_75_ov "Population age 75-"
label variable variant "Variant virus (%)"
label variable cum_case "Cummulative case"

sort pref date
bysort pref: gen tmp=date[_n] - date[_n-1]
drop if tmp==0 & td(28july2021)
drop tmp

label data "Full Dataset"
save Dataset_full, replace