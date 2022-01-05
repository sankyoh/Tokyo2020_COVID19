* 重みをまとめた表を読み込み
import excel "211031重みの表.xlsx", firstrow clear
rename SyntheticControlWeight sw
rename RegressionWeight rw


do labelpref
encode Prefecture , gen(pref) label(lpref)

save weight_data, replace

use Dataset, clear

* コントロール・プールに入らない都道府県を削除する。
drop if pref==13 // 東京
drop if pref<=12 | pref==14 // 北海道・東北・関東
drop if pref==15 // 新潟
drop if pref==19 // 山梨
drop if pref==20 // 長野
drop if pref==22 // 静岡

merge m:1 pref using weight_data

* 各Conrol poolの府県で重み付きの値を算出する。
gen prop_new_case07_sw = prop_new_case07 * sw
gen prop_new_case07_rw = prop_new_case07 * rw

* Control poolの値を合算する
keep date pref prop_new_case07_sw prop_new_case07_rw
collapse (sum) prop_new_case07_sw prop_new_case07_rw, by(date)

* 合算したControl poolの値を保存する。
save Graph_data_CntlPool, replace

* 東京だけのデータを作る
use Dataset, clear
keep if pref==13 // 東京のみ
keep date prop_new_case07

* 東京だけのデータにControl poolのデータを合算する
merge 1:1 date using Graph_data_CntlPool
drop _merge

keep if td(01feb2021) <= date & date<=td(30sep2021)
compress
label data "SCweight & Regweight for graph"
save sum_result_for_graph, replace