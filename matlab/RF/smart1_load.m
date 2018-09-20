% Load train data
clc;clear;
export = 0;
f_sort = 0;
dir_mydata = '~/Data/OnlineRF/oriorder/';
dir_data = '/home/xzhuang/Data/xzData20180711/mat/';
load(strcat(dir_data,'smart1_all.mat'));
load(strcat(dir_data,'smart1_train_all.mat'));
load(strcat(dir_data,'smart1_dtest.mat'));
predictorNames = {...
    'smart_5_raw',...
    'smart_187_raw',...
    'smart_197_raw',... 
    'smart_1_normalized',... 
    'smart_4_raw',... 
    'smart_7_normalized',...  
    'smart_9_normalized',...  
    'smart_12_raw',...  
    'smart_183_raw',...  
    'smart_184_raw',...  
    'smart_189_raw',...  
    'smart_193_normalized',...  
    'smart_198_raw',...  
    'smart_199_raw',...  
    'smart_3_normalized',...  
    'smart_5_normalized',...  
    'smart_7_raw',...  
    'smart_9_raw',...  
    'smart_183_normalized',...  
    'smart_184_normalized',...  
    'smart_187_normalized',...  
    'smart_188_normalized',...  
    'smart_188_raw',...  
    'smart_189_normalized',...  
    'smart_192_raw',...  
    'smart_193_raw',...  
    'smart_194_raw',...  
    'smart_197_normalized',...  
    'smart_198_normalized'};

smart1_all = add_health_degree(smart1_all,f_sort);
smart1_train = add_health_degree(smart1_train_all,f_sort);
smart1_test = add_health_degree(smart1_dtest,f_sort);
