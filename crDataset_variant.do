/****　***** ***** ***** ***** *****
*
* 変異株についてインポート・整理
* 
***** ***** ***** ***** ***** ****/

import excel "変異株データ.xlsx", sheet("変異株PCR検査陽性率") cellrange(A4:B50) clear

rename A pref_txt
rename B variant

qui:do labelpref
encode pref_txt, gen(pref) label(lpref)
drop pref_txt

gen date=td(25july2021)
format %td date

order date pref 
label data "Variant between 7/19-7/25 by prefecture"
save Dataset_variant, replace