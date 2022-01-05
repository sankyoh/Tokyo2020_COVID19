/****　***** ***** ***** ***** *****
*
* Make variable
* 
***** ***** ***** ***** ***** ****/

* Data import
use Dataset_full, clear
tsset pref date

* Convert number per 100,000. 人口10万人あたり数に変換する
gen prop_new_case  = (new_case  / pop_total) * 100
gen prop_new_death = (new_death / pop_total) * 100
gen prop_cum_case  = (cum_case  / pop_total) * 100
gen prop_cum_death = (cum_death / pop_total) * 100


* Calculate proportion age category. 各年齢の割合
gen prop_00_14 = pop_00_14 / pop_total
gen prop_15_64 = pop_15_64 / pop_total
gen prop_65_ov = pop_65_ov / pop_total
gen prop_75_ov = pop_75_ov / pop_total

* Calculate vaccinate proportion. 接種割合
gen prop_total_shot = total_shot / (pop_total * 1000)
gen prop_first_shot = first_shot / (pop_total * 1000)
gen prop_second_shot = second_shot / (pop_total * 1000)

* Make moving average (7day and 28day) 移動平均を作る（7日移動平均と28日移動平均）
tsset pref date

foreach x of varlist prop_new_case prop_new_death prop_cum_case prop_cum_death {
	tssmooth ma `x'07 = `x', window( 6 1 0)
	tssmooth ma `x'28 = `x', window(27 1 0)
}

label data "Data for analysis"
save Dataset, replace