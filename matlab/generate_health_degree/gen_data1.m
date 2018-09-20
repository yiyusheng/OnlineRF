% Load train data
clc;clear;
export = 0;
f_sort = 0;
dir_mydata = '~/Data/OnlineRF/oriorder/';
dir_mydata1 = '~/Data/OnlineRF/health_degree';
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
save(strcat(dir_mydata1,'smart1.mat'),'smart1_all','smart1_train','smart1_test');

%%
% For all
smart1_all_data = smart1_all{:, predictorNames};
smart1_all_labels = smart1_all.class;
smart1_all_snids = smart1_all.sn_id;
smart1_all_health = smart1_all.health_degree;
smart1_all_time = smart1_all.datenum;

% For train
smart1_train_data = smart1_train{:, predictorNames};
smart1_train_labels = smart1_train.class;
smart1_train_snids = smart1_train.sn_id;
smart1_train_health = smart1_train.health_degree;
smart1_train_time = smart1_train.datenum;

% For test
smart1_test_data = smart1_test{:, predictorNames};
smart1_test_labels = smart1_test.class;
smart1_test_snids = smart1_test.sn_id;
smart1_test_health = smart1_test.health_degree;
smart1_test_time = smart1_test.datenum;

% export
if export
dlmwrite(strcat(dir_mydata,'smart1_all.data'), size(smart1_all_data), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_all.data'), smart1_all_data, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_all.labels'), size(smart1_all_labels), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_all.labels'), smart1_all_labels, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_all.snids'), size(smart1_all_snids), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_all.snids'), smart1_all_snids, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_all.health'), size(smart1_all_health), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_all.health'), smart1_all_health, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_all.time'), size(smart1_all_time), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_all.time'), smart1_all_time, 'delimiter', ' ', 'precision', '%u', '-append');

dlmwrite(strcat(dir_mydata,'smart1_train.data'), size(smart1_train_data), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_train.data'), smart1_train_data, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_train.labels'), size(smart1_train_labels), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_train.labels'), smart1_train_labels, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_train.snids'), size(smart1_train_snids), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_train.snids'), smart1_train_snids, 'delimiter', ' ', 'precision', '%u','-append');
dlmwrite(strcat(dir_mydata,'smart1_train.health'), size(smart1_train_health), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_train.health'), smart1_train_health, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_train.time'), size(smart1_train_time), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_train.time'), smart1_train_time, 'delimiter', ' ', 'precision', '%u', '-append');

dlmwrite(strcat(dir_mydata,'smart1_test.data'), size(smart1_test_data), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_test.data'), smart1_test_data, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_test.labels'), size(smart1_test_labels), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_test.labels'), smart1_test_labels, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_test.snids'), size(smart1_test_snids), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_test.snids'), smart1_test_snids, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_test.health'), size(smart1_test_health), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_test.health'), smart1_test_health, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite(strcat(dir_mydata,'smart1_test.time'), size(smart1_test_time), 'delimiter', ' ', 'precision', '%u');
dlmwrite(strcat(dir_mydata,'smart1_test.time'), smart1_test_time, 'delimiter', ' ', 'precision', '%u', '-append');
end
