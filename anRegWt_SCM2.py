import pandas as pd
import numpy as np

df = pd.read_excel('df_wide_for_regwt.xlsx', index_col=1)
# print(df)

# Define Matrix
# Tokyo (Intervention group)
mat_x1 = np.matrix(df[df.pref=='Tokyo'].loc[:,'prop_15_64':'interval8'].values.tolist()).T
mat_x1 = np.insert(mat_x1,0,1,axis=0)
mat_y1 = np.matrix(df[df.pref=='Tokyo'].loc[:,'y173':'y242'].values.tolist()).T

# Other prefecture (Control pool)
mat_x0 = np.matrix(df[df.pref!='Tokyo'].loc[:,'prop_15_64':'interval8'].values.tolist()).T
mat_x0 = np.insert(mat_x0,0,1,axis=0)
mat_y0 = np.matrix(df[df.pref!='Tokyo'].loc[:,'y173':'y242'].values.tolist()).T

# Other matrix
# number of Control pool = 29
iota   = np.matrix(np.ones(29),dtype=float).T

# Regression weight
w_reg  = np.dot(np.dot(mat_x0.T,np.linalg.inv(np.dot(mat_x0,mat_x0.T))),mat_x1)
type(w_reg)

np.savetxt("w_reg.csv", w_reg, delimiter=",")

sum_of_weight = np.dot(iota.T,w_reg)
print('sum_of_weight = ', sum_of_weight) # sum_of_weight =  [[1.]]があればOK

# Calculate pre-intervention values of synthetic control
syn_cntr_x = np.dot(mat_x0,w_reg)
print('Synthetic Control of Pre_trt\n', syn_cntr_x)

# Pre-RMSPE
mat_pre_diff1 = mat_x1 - syn_cntr_x   # 人口割合等も含む縦ベクトル
mat_pre_diff2 = mat_pre_diff1[5:13,:] # 感染者数の差のみの縦ベクトル

mat_pre_diff1sq = np.square(mat_pre_diff1) # 2乗
mat_pre_diff2sq = np.square(mat_pre_diff2)

pre_rmspe1 = np.sqrt(np.sum(mat_pre_diff1sq)/len(mat_pre_diff1sq)) # 平均をの平方根
pre_rmspe2 = np.sqrt(np.sum(mat_pre_diff2sq)/len(mat_pre_diff2sq))


# Calculate post-intervention values of synthetic control
syn_cntr_y = np.dot(mat_y0, w_reg)

# Post-RMSPE
mat_post_diff = mat_y1 - syn_cntr_y

mat_post_diffsq = np.square(mat_post_diff) # 2乗

post_rmspe = np.sqrt(np.sum(mat_post_diffsq)/len(mat_post_diffsq))

# Output
print("Tokyo")
print("Pre-RMSPE =", pre_rmspe2)
print("Post-RMSPE=", post_rmspe)


