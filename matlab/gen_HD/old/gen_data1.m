%% Load train data
clc;clear;
export = 0;
f_sort = 0;
dir_mydata = '~/Data/OnlineRF/oriorder/';
dir_mydata1 = '~/Data/OnlineRF/health_degree/';
dir_data = '/home/xzhuang/Data/xzData20180711/mat/';
load(strcat(dir_data,'smart1_all.mat'));
load(strcat(dir_data,'smart1_train_all.mat'));
load(strcat(dir_data,'smart1_dtest.mat'));
predictorNames = {...
    'smart_4_raw',... 
    'smart_5_raw',...
    'smart_7_raw',...  
    'smart_9_raw',...  
    'smart_12_raw',...  
    'smart_183_raw',...  
    'smart_184_raw',...  
    'smart_187_raw',...
    'smart_188_raw',...  
    'smart_189_raw',...  
    'smart_192_raw',...  
    'smart_193_raw',...  
    'smart_194_raw',...  
    'smart_197_raw',... 
    'smart_198_raw',...  
    'smart_199_raw',...  
    'smart_1_normalized',... 
    'smart_3_normalized',...  
    'smart_5_normalized',...  
    'smart_7_normalized',...  
    'smart_9_normalized',...  
    'smart_183_normalized',...  
    'smart_184_normalized',...  
    'smart_187_normalized',...  
    'smart_188_normalized',...  
    'smart_189_normalized',...  
    'smart_193_normalized',...  
    'smart_197_normalized',...  
    'smart_198_normalized'};
metaNames = {'sn_id','class','date','datenum'}; 
smart1_dtest = smart1_dtest(:,[metaNames,predictorNames]);
save(strcat(dir_mydata1,'smart1.mat'),'smart1_dtest','predictorNames','metaNames');

%% Preprocess for test set
% dt_pos = smart1T(smart1T.class==1,:);
% uni_disk = unique(dt_pos.sn_id);
% len_ud = length(uni_disk);
% sn_train = randsample(uni_disk,round(len_ud*0.666));
% sta_sn = tabulate(smart1T.sn_id);

%% Generate health degree variables
% tic 
% days_train = 60;
% days_cost = 5;
% [hddn,smart1_test,cost_hddn] = func_add_HD_datenum(smart1T,f_sort,predictorNames,sn_train,days_train,days_cost);
% [hdsc,smart1_test,cost_hdsc] = func_add_HD_SMART_center(smart1_test,f_sort,predictorNames,sn_train,days_train,days_cost,10,2);
% [hdmd,smart1_test,cost_hdmd] = func_add_HD_mahalanobis_distance(smart1_test,f_sort,predictorNames,sn_train,unique([0,3,6,11,16,23,30,days_train]),days_cost);
% [cost_hddn,cost_hdsc,cost_hdmd]
% metaNames = {'id','sn_id','class','date','datenum','hddn','hdsc','hdmd'}; 
% disp('Add health degree HAS DONE!!!');
% toc

%% Save data
% save(strcat(dir_mydata1,'smart1.mat'),'smart1_test','predictorNames','metaNames','sn_train','hddn','hdsc','hdmd');

%% test parameters for hdmd
% addpath('/home/xzhuang/Code/C/OnlineRF/matlab/Model/');
% smart1C = smart1_test;
% metaNamesC = setdiff(smart1C.Properties.VariableNames,predictorNames);
% metaNamesC = metaNamesC(~contains(metaNamesC,'smart') & ~ismember(metaNamesC,{'date','preclass','healthFactor'}));
% smart1C.Properties.VariableNames = func_simplify_smart_attributes(smart1C.Properties.VariableNames);
% predictorNamesC = func_simplify_smart_attributes(predictorNames);
% smart1C = smart1C(:,[metaNamesC,predictorNamesC]);
% 
% smart1C_pos_train = smart1C(ismember(smart1C.sn_id,sn_train) & smart1C.class==1,:);




%% Add health degree
% tic

% add health degree HDDN
% smart1_all = func_add_HD_datenum(smart1_all,f_sort);
% smart1_train = func_add_HD_datenum(smart1_train,f_sort);
% smart1_test = func_add_HD_datenum(smart1_test,f_sort,predictorNames,sn_train,60);

% add health degree HDSC
% smart1_all = func_add_HD_SMART_center(smart1_all,predictorNames);
% smart1_train = func_add_HD_SMART_center(smart1_train,predictorNames);
% [hdsc,smart1_test] = func_add_HD_SMART_center(smart1_test,f_sort,predictorNames,sn_train,60,10,2);
% [hdmd,smart1_test,cost_hdmd] = func_add_HD_mahalanobis_distance(smart1_test,f_sort,predictorNames,sn_train,100,10);

% metaNames = {'id','sn_id','class','date','datenum','hddn','hdsc'}; 
% save(strcat(dir_mydata1,'smart1.mat'),'smart1_test','predictorNames','metaNames','idx_train_hdsc');
%save(strcat(dir_mydata1,'smart1.mat'),'smart1_all','smart1_train','smart1_test','predictorNames','metaNames');

% disp('Add health degree HAS DONE!!!');toc

%% test parameter when add_HD
% K = [2,5,10,20,50,100]; % number of groups
% vwd = [1,2,3,5,7,10,20,30,60]; % valid weight days
% [X Y] = meshgrid(K,vwd);
% para = [X(:) Y(:)];
% 
% delete(gcp('nocreate'));
% st={};sn={};cost={};
% tic
% parpool(10)
% parfor (i=11:size(para,1),10)
%     [st{i},sn{i},cost{i}] = func_add_HD_SMART_center(smart1_test,f_sort,predictorNames,sn_train,60,para(i,1),para(i,2));
% end
% delete(gcp('nocreate'));
% toc

%%
% if export
% % For all
% smart1_all_data = smart1_all{:, predictorNames};
% smart1_all_labels = smart1_all.class;
% smart1_all_snids = smart1_all.sn_id;
% smart1_all_health = smart1_all.health_degree;
% smart1_all_time = smart1_all.datenum;
% 
% % For train
% smart1_train_data = smart1_train{:, predictorNames};
% smart1_train_labels = smart1_train.class;
% smart1_train_snids = smart1_train.sn_id;
% smart1_train_health = smart1_train.health_degree;
% smart1_train_time = smart1_train.datenum;
% 
% % For test
% smart1_test_data = smart1_test{:, predictorNames};
% smart1_test_labels = smart1_test.class;
% smart1_test_snids = smart1_test.sn_id;
% smart1_test_health = smart1_test.health_degree;
% smart1_test_time = smart1_test.datenum;
% 
% % export
% dlmwrite(strcat(dir_mydata,'smart1_all.data'), size(smart1_all_data), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_all.data'), smart1_all_data, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_all.labels'), size(smart1_all_labels), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_all.labels'), smart1_all_labels, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_all.snids'), size(smart1_all_snids), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_all.snids'), smart1_all_snids, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_all.health'), size(smart1_all_health), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_all.health'), smart1_all_health, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_all.time'), size(smart1_all_time), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_all.time'), smart1_all_time, 'delimiter', ' ', 'precision', '%u', '-append');
% 
% dlmwrite(strcat(dir_mydata,'smart1_train.data'), size(smart1_train_data), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_train.data'), smart1_train_data, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_train.labels'), size(smart1_train_labels), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_train.labels'), smart1_train_labels, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_train.snids'), size(smart1_train_snids), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_train.snids'), smart1_train_snids, 'delimiter', ' ', 'precision', '%u','-append');
% dlmwrite(strcat(dir_mydata,'smart1_train.health'), size(smart1_train_health), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_train.health'), smart1_train_health, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_train.time'), size(smart1_train_time), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_train.time'), smart1_train_time, 'delimiter', ' ', 'precision', '%u', '-append');
% 
% dlmwrite(strcat(dir_mydata,'smart1_test.data'), size(smart1_test_data), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_test.data'), smart1_test_data, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_test.labels'), size(smart1_test_labels), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_test.labels'), smart1_test_labels, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_test.snids'), size(smart1_test_snids), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_test.snids'), smart1_test_snids, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_test.health'), size(smart1_test_health), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_test.health'), smart1_test_health, 'delimiter', ' ', 'precision', '%u', '-append');
% dlmwrite(strcat(dir_mydata,'smart1_test.time'), size(smart1_test_time), 'delimiter', ' ', 'precision', '%u');
% dlmwrite(strcat(dir_mydata,'smart1_test.time'), smart1_test_time, 'delimiter', ' ', 'precision', '%u', '-append');
% end
