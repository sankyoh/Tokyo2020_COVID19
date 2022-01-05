/****　***** ***** ***** ***** *****
*
* SimpleにSCMを実行する
* 感度分析（In-Space Placebo Effect）
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

/*
* 開催地のみ削除する方針
drop if pref== 1 // 北海道
drop if pref== 4 // 宮城
drop if pref== 7 // 福島
drop if pref== 8 // 茨城
drop if pref==11 // 埼玉
drop if pref==12 // 千葉
drop if pref==14 // 神奈川
drop if pref==22 // 静岡
*/

drop if pref==13 // 感度分析では東京も除外

* 研究対象期間
keep if td(01feb2021) <= date & date<=td(30sep2021)

local day_intv = td(23july2021) // 開会式
local day_intv = td(01july2021) // NHKニュース入国本格化

tsset pref date

label data "感度分析ISPE用"
save Dataset_for_simple2_sa, replace

* バランスをとる変数の設定
local day0 = td(01feb2021)
local day2 = td(08mar2021)
local day1 = (`day0' + `day2' + 1)/2
local day4 = td(13may2021)
local day3 = (`day2' + `day4')/2
local day6 = td(15jun2021)
local day5 = (`day4' + `day6'+1)/2
local day8 = `day_intv'-1
local day7 = (`day6' + `day8'+1)/2

* SCM準備
local y prop_new_case07

mat tmp = (13, 1.1695138, 8.3940859, 7.1774149)
forvalues prefnum = 1/47 {
qui {
	
	if (`prefnum'== 1 | `prefnum'== 4 | `prefnum'== 7) continue
	if (`prefnum'== 8 | `prefnum'==11 | `prefnum'==12) continue
	if (`prefnum'==13 | `prefnum'==14 | `prefnum'==22) continue
	
	use Dataset_for_simple2_sa, clear
	synth `y' ///
		`y'(`day0'(1)`day1') ///
		`y'(`day1'(1)`day2') ///	
		`y'(`day2'(1)`day3') ///
		`y'(`day3'(1)`day4') ///
		`y'(`day4'(1)`day5') ///
		`y'(`day5'(1)`day6') ///
		`y'(`day6'(1)`day7') ///
		`y'(`day7'(1)`day8') ///
		prop_second_shot ///
		variant ///
		prop_15_64 ///
		prop_65_ov ///
		, trunit(`prefnum') trperiod(22484) keep(scm_result2_sa) replace

	local rmspe = e(RMSPE)[1,1]

	* 効果量推定のための変数作成
	use scm_result2_sa, clear
	capture graph drop *
	format %td _time 
	tsset _time
	gen diff = _Y_treated - _Y_synthetic

	gen     cumY_treated = _Y_treated if _time == td(01feb2021)
	replace cumY_treated = cumY_treated[_n-1] + _Y_treated if cumY_treated==.
	gen     cumY_synthetic = _Y_synthetic if _time == td(01feb2021)
	replace cumY_synthetic = cumY_synthetic[_n-1] + _Y_synthetic if cumY_synthetic==.

	gen cum_diff = cumY_treated - cumY_synthetic
}
	/* 効果量の推定
	gen cum_diff2 = cum_diff - cum_diff[172] // cum_diffから開会式前日の累積数を引く
	di "prefecture No = `prefnum'"
	local est       = cum_diff2[242]
	di `est'
	local est_per_u = `est'/`rmspe'                // rmspeあたりの期間中増加数を出す
	di `est_per_u'
	mat prefdata = (`prefnum', `est', `rmspe', `est_per_u')
	mat list prefdata
	mat rowjoin tmp = tmp prefdata*/
	
	* Ratio of post/pre RMSPE
	gen diff2 = diff^2
	egen total_diff2_pre  = mean(diff2) if _time      <  `day_intv'
	egen total_diff2_post = mean(diff2) if `day_intv' <= _time
	gen  rmspe_pre        = sqrt(total_diff2_pre)
	gen  rmspe_post       = sqrt(total_diff2_post)
	
	local rmspe_pre   = rmspe_pre[1]
	local rmspe_post  = rmspe_post[180]
	local ratio_rmspe = `rmspe_post' / `rmspe_pre'
	
	mat prefdata = (`prefnum', `rmspe_pre', `rmspe_post', `ratio_rmspe')
	mat rowjoin tmp = tmp prefdata

}
// mat colname tmp = pref_no estimate rmspe est/rmspe
mat colname tmp = Pref_No Pre-RMSPE Post-RMSPE Post/Pre-ratio
mat list tmp

putexcel set result_ippe_simple2_dash.xlsx, replace
putexcel A1 = matrix(tmp), colnames nformat(0.000)
putexcel save