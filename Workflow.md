For this analysis, we used Stata 17.0/MP4, user-driven command "synth" 0.0.7, Python 3.7.4, Numpy 1.18.1, Pandas 0.25.3, Jupyter notebook 6.0.2. The do files, py files, and ipynb file were created by Toshiharu Mitsuhashi for this study.

(Workflow Figure 1)
Public data files (number of new infections, vaccinations, population, and delta variants) by prefecture were converted from Excel files to Stata dta files. Three do files were used: crDataset.do, crDataset_population.do, and crDataset_variant.do. The converted Stata dta files were merged using the prefecture as the key. This was done by crMerge.do. For this file, we calculated the percentage of population and the percentage of vaccination. This was done by crVariables.do. The file was named Dataset.dta and saved. Next, we divided the study period based on the peaks and troughs in the number of infections in Tokyo. In order to divide the period, the boundary days were identified using anDetectPeek.do.
![image](https://user-images.githubusercontent.com/67684585/150675349-95d8a606-f8b8-4a5e-b847-c7df308616f5.png)

(Workflow Figure 2)
Normal SCM was performed with anSCM_simple2.do. To perform SCM with Regression weight, Long type data was converted to Wide type data. This was done using crConvert_LongtoWide.do. The converted file was output as an Excel file. This file was named df_wide_for_regwt.xlsx. SCM with Regression weight was performed on this file. For this analysis, we used anRegWt_SCM2.py. Then, anRegWt_SCM2.ipynb was run to obtain the in-space placebo effect. These files output the weights for each prefecture.
 ![image](https://user-images.githubusercontent.com/67684585/150675364-66cb0999-a4c1-4621-982c-3b01775ae916.png)

(Workflow Figure 3)
Based on the weights, we will draw a graph. To draw a graph, we first merge the weights and the number of newly infected people in anDraw_graph_for_excel_newcase.do, and then create a data file for drawing the graph. The data file for drawing is named sum_result_for_graph.dta. Next, we used anDraw_graph_newcase.do to draw the graph.
![image](https://user-images.githubusercontent.com/67684585/150675388-a850f6bd-9073-4bae-962e-c50ae4399f1c.png)
