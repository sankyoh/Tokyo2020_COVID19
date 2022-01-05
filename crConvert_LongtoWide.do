/****　***** ***** ***** ***** *****
*
* DatasetをRegression weightを計算できる形に直す
* wide type
* 
***** ***** ***** ***** ***** ****/

* Import Dataset
use Dataset, clear

* コントロール・プールに入らない都道府県を削除する。

drop if pref<=12 | pref==14 // 北海道・東北・関東
drop if pref==15 // 新潟
drop if pref==19 // 山梨
drop if pref==20 // 長野
drop if pref==22 // 静岡

* 研究対象期間
keep if td(01feb2021) <= date & date<=td(30sep2021)

* Regresion weightを使ったSCMで不使用の変数を削除する
keep date pref variant prop_15_64 prop_65_ov prop_second_shot prop_new_case07

* その他不都合な点を修正
bysort pref: replace prop_second_shot = prop_second_shot[_n-1] if prop_second_shot==.
rename prop_new_case07 y

* wide typeにするとでSIFが大きすぎるので、変換
gen tmp = date - td(31jan2021) // 01feb2021を「1」とする変換
drop date
rename tmp date

/****　***** ***** ***** ***** *****
*
*
* 介入前アウトカムの縮約を行う。
* 通常のSCMと同様に8区分に分ける。
*
* 
***** ***** ***** ***** ***** ****/

* Long type => Wide type
reshape wide y, i(pref) j(date)

local day_intv = td(23july2021) // 開会式 

* バランスをとる変数の設定
// これは、anSCM_simple2.doからのコピペ
local day0 = td(01feb2021)
local day2 = td(08mar2021)
local day1 = (`day0' + `day2' + 1)/2
local day4 = td(13may2021)
local day3 = (`day2' + `day4')/2
local day6 = td(15jun2021)
local day5 = (`day4' + `day6'+1)/2
local day8 = `day_intv'-1
local day7 = (`day6' + `day8'+1)/2

forvalues x = 0/8 {
	display %td `day`x''
}
/*
// 01feb2021を「1」とする変換
forvalues x = 0/8 {
	local day`x' = `day`x'' - td(31jan2021)
}

forvalues x = 1/8 {
	local y = `x'-1
	egen interval`x' = rowmean(y`day`y''-y`day`x'')
}

display "開会式前日=`day8'"
drop y1-y172
*/
gen intv = (pref==13)
order pref intv prop_15_64 prop_65_ov prop_second_shot variant interval1-interval8 y173-y242

compress
label data "Calc. Regression weight for Python"
save Dataset_wide_for_regwt, replace

export excel using df_wide_for_regwt.xlsx, first(var) replace