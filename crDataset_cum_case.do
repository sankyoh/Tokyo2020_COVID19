/****　***** ***** ***** ***** *****
*
* 累積患者数作成
* 
***** ***** ***** ***** ***** ****/
import excel "COVID19_data.xlsx", sheet("新規感染者数厚労省full version") cellrange(A2:C31009) clear
rename A date
rename B pref_txt
rename C new_case

drop if pref_txt=="ALL"

qui:do labelpref
encode pref_txt, gen(pref) label(lpref)
drop pref_txt

sort pref date
bysort pref: gen cum_case = 0 if _n==1

bysort pref: replace cum_case = cum_case[_n-1] + new_case if _n!=1

keep if  22128<=date & date<=22553
drop new_case
order date pref cum_case

* 重複日の確認
sort pref date
bysort pref: gen     tmp=date[_n] - date[_n-1]
bysort pref: replace tmp=1 if _n==1
assert tmp==1
drop tmp

* 保存
label data "Cummulative new case"
save Dataset_cum_case, replace

