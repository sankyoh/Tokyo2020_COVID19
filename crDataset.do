/****　***** ***** ***** ***** *****
*
* 新規感染者データのインポートと整理
* 
***** ***** ***** ***** ***** ****/

import excel "COVID19_data.xlsx", sheet("新規感染者数厚労省") cellrange(A4:C20402) clear
rename A date
rename B pref_txt
rename C new_case

drop if pref_txt=="ALL"

qui:do labelpref
encode pref_txt, gen(pref) label(lpref)
drop pref_txt

* 重複日の削除
sort pref date
bysort pref: gen tmp=date[_n] - date[_n-1]
drop if tmp==0 & td(28july2021)
drop tmp

* saveing...
order date pref new_case
label data "New case by prefecture"
save covid_newcase.dta, replace

/****　***** ***** ***** ***** *****
*
* 死亡者データのインポートと整理
* 
***** ***** ***** ***** ***** ****/

import excel "COVID19_data.xlsx", sheet("死亡者数累積厚労省") cellrange(A4:C20402) clear
rename A date
rename B pref_txt
rename C cum_death

drop if pref_txt=="ALL"

qui:do labelpref
encode pref_txt, gen(pref) label(lpref)
drop pref_txt

* 重複日の削除
sort pref date
bysort pref: gen tmp=date[_n] - date[_n-1]
drop if tmp==0 & td(28july2021)
drop tmp

* cum_death -> new_death
sort pref date
bysort pref: gen tmp_id = _n
bysort pref: gen new_death = cum_death[_n] - cum_death[_n-1] if tmp_id != 1
drop tmp_id

* saveing...
order date pref new_death cum_death
label data "New death by prefecture"
save covid_newdeath.dta, replace

/****　***** ***** ***** ***** *****
*
* ワクチン接種状況
* 
***** ***** ***** ***** ***** ****/

import excel "COVID19_data.xlsx", sheet("8月総接種ワクチン") cellrange(A3:D51) clear firstrow
rename 都道府県 pref_jp_txt
rename 接種回数 total_shot
rename 内１回目 first_shot
rename 内２回目 second_shot

drop if pref_jp_txt=="合計"

gen pref_jp_txt2 = regexr(pref_jp_txt, "^[0-9][0-9] ", "")
qui:do labelpref_jp
qui:do labelpref
encode pref_jp_txt2, gen(pref) label(lpref_jp)
label values pref lpref
drop pref_jp_txt*

gen date = td(30aug2021)

order date pref
label data "Vaccine by prefecture"
save covid_vaccine.dta, replace


/****　***** ***** ***** ***** *****
*
* 緊急事態宣言等
* 
***** ***** ***** ***** ***** ****/

import excel "COVID19_data.xlsx", sheet("緊急事態宣言") cellrange(B3:L50) clear firstrow

qui:do labelpref
encode prefecture, gen(pref) label(lpref)
drop prefecture

rename C w1
rename D w2
rename E w3
rename F w4
rename G w5
rename H w6
rename I w7
rename J w8
rename K w9
rename L w10

reshape long w, i(pref) j(week)

rename w mes

replace mes="0" if mes==""
replace mes="1" if mes=="man"
replace mes="2" if mes=="kin"
replace mes="2" if mes=="~kin"
label define prov 0 "none" 1 "man" 2 "kin"

destring mes, replace
rename mes prov
label values prov prov

replace week=td(23may2021) if week==1
list
replace week=td(21jun2021) if week==2
replace week=td(12jul2021) if week==3
replace week=td(28jul2021) if week==4
replace week=td(2aug2021)  if week==5
replace week=td(8aug2021)  if week==6
replace week=td(20aug2021) if week==7
replace week=td(27aug2021) if week==8
replace week=td(13sep2021) if week==9
replace week=td(30sep2021) if week==10
format %td week

rename week date

order date pref
label data "provision against COVID19"
save covid_provision.dta, replace

/****　***** ***** ***** ***** *****
*
* マージする
* 
***** ***** ***** ***** ***** ****/

use covid_newcase.dta, clear
merge m:m date pref using covid_newdeath, gen(merge1)
merge m:m pref using covid_vaccine,  gen(merge2)        // 30aug2021
merge m:m date pref using covid_provision,  gen(merge3)

drop merge*


label data "Combined dataset"
save Dataset_base, replace
