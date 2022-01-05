


capture program drop draw_graphs 
program draw_graphs
local day_intv = td(23july2021) // 開会式 
tsset _time
gen diff = _Y_treated - _Y_synthetic

twoway (tsline _Y_treated) (tsline _Y_synthetic), tline(`day_intv') ttext(100 100) scheme(sj) name(graph1) ///
	ytitle("New case per 100,000") xtitle("Date")
twoway (tsline diff), tline(`day_intv') ttext(100 100) scheme(sj) name(graph2) ///
	ytitle("Difference between Tokyo and synth.Tokyo") xtitle("Date")

gen     cumY_treated = _Y_treated if _time == td(01feb2021)
replace cumY_treated = cumY_treated[_n-1] + _Y_treated if cumY_treated==.
gen     cumY_synthetic = _Y_synthetic if _time == td(01feb2021)
replace cumY_synthetic = cumY_synthetic[_n-1] + _Y_synthetic if cumY_synthetic==.

gen cum_diff = cumY_treated - cumY_synthetic

twoway (tsline cumY_treated) (tsline cumY_synthetic), tline(`day_intv') ttext(100 100) scheme(sj) name(graph3) ///
	ytitle("Cumulative case per 100,000") xtitle("Date")
twoway (tsline cum_diff), tline(`day_intv') ttext(100 100) scheme(sj) name(graph4) ///
	ytitle("Difference between Tokyo and synth.Tokyo") xtitle("Date")

forvalues x=1/4{
	graph export ./graph/scm_reusult2_`1'_`x'.png, as(png) name(graph`x') replace
	graph save graph`x' ./graph/scm_result2_`1'_`x'.gph, replace
}
end

* Synthetic Control weightによるグラフ
use sum_result_for_graph, clear
rename date _time
rename prop_new_case07 _Y_treated
rename prop_new_case07_sw _Y_synthetic
capture graph drop *
draw_graphs sw

* Regression weightによるグラフ
use sum_result_for_graph, clear
rename date _time
rename prop_new_case07 _Y_treated
rename prop_new_case07_rw _Y_synthetic
capture graph drop *
draw_graphs rw