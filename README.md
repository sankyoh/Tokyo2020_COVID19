# The Causal Effect of the Tokyo 2020 Olympic and Paralympic Games on the Number of COVID-19 Cases under COVID-19 Pandemic: An Ecological Study Using the Synthetic Control Method
This work is the analytical source code and raw data for a study that examined the impact ofTokyo 2020 on the number of COVID-19 new cases. The raw data contains only public data in Japan..

Please also refer to the Workflow.md
https://github.com/sankyoh/Tokyo2020_COVID19/blob/main/Workflow.md.

## master.do file
By executing this Sata do file, it calls the do file to read and analyze the raw data into Stata.
### Read and organizing Excel data.
The following Stata do-files read and organize Excel files.
These do-files converts the Excel file into Stata dta file.
crDataset.do, crDataset_cum_case.do, crDataset_population.do, and crDataset_variant.
### Merge and Make Variable.
The "crMerge.do" file combine all data files with prefecture and date as keys.
And, the "crVariable.do" file generate the variables for analysis.
The completed dataset is a file named Dataset.dta.
### Detect peek day
Check the Tokyo wave peek on a 7-day moving average basis by anDetectPeek.do.
## anSCM_simple2.do and anSCM_simple2_sa.do
Run the SCM analysis on these files. In the _sa file, we calculate the in space placebo effect.
### crConvert_LongtoWide.do
Convert Dataset.dta (Long data) to Dataset_wide_for_regwt.dta (Wide data).
Also, output the same data as df_wide_for_regwt.xlsx.
### anRegWt_SCM2.py, anRegWt_SCM2.ipynb
Run SCM with Regression weight. For this analysis, we need df_wide_for_regwt.xlsx output by crConvert_LongtoWide.do.
Output w_reg.csv as the weight for Synthetic Tokyo, and RegWt_SCM2_result.csv as the result of calculating the In space placebo effect.
### Graph drawing
anDraw_graph_for_excel_newcase.do: generate the Excel file for graph.
anDraw_graph_newcase.do: Graph drawing
## DATA
We download these public website.
