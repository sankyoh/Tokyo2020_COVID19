/****　***** ***** ***** ***** *****
*
* 人口についてインポート・整理
* 
***** ***** ***** ***** ***** ****/

import excel "統計局人口　2021.xlsx", sheet("年齢別") cellrange(B6:G53) clear
rename B pref_jp_txt
rename C pop_total
rename D pop_00_14
rename E pop_15_64
rename F pop_65_ov
rename G pop_75_ov

drop if pref_jp_txt == "全国"

gen     pref_jp_txt2 = regexr(pref_jp_txt , "$", "県")
replace pref_jp_txt2 = "北海道" if pref_jp_txt2=="北海道県"
replace pref_jp_txt2 = "東京都" if pref_jp_txt2=="東京県"
replace pref_jp_txt2 = "大阪府" if pref_jp_txt2=="大阪県"
replace pref_jp_txt2 = "京都府" if pref_jp_txt2=="京都県"

qui:do labelpref_jp
qui:do labelpref

encode pref_jp_txt2, gen(pref) label(lpref_jp)
label values pref lpref
drop pref_jp_txt*

gen date = td(01aug2020)
format %td date

order date pref 
label data "Population at 2019"
save Dataset_pop, replace