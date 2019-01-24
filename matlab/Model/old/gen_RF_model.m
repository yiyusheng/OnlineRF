% Generate RF model with smart1_test

%% Load data and generate train SN
clc;clear;
tic
disp('Load data and Generate train SN...');
dir_mydata = '~/Data/OnlineRF/health_degree/';
addpath('../eval_Model/');
addpath('../gen_HD/');
load(strcat(dir_mydata,'smart1.mat'));
smart1T = smart1_dtest(smart1_dtest.class==1,:);   

smart1T = func_gen_diff(smart1T,predictorNames);
smart1T.dn1 = func_gen_tia_groups(smart1T.datenum,1,200);
smart1T.dn3 = func_gen_tia_groups(smart1T.datenum,3,200);
smart1T.dn5 = func_gen_tia_groups(smart1T.datenum,5,200);
smart1T.dn10 = func_gen_tia_groups(smart1T.datenum,10,200);

dt_pos = smart1T(smart1T.class==1,:);
uni_disk = unique(dt_pos.sn_id);
len_ud = length(uni_disk);
sn_train = randsample(uni_disk,round(len_ud*0.666));
sta_sn = tabulate(smart1T.sn_id);
predictorNames = [predictorNames strcat(predictorNames,'_diff')];
idx_pred = [1 3 4 5 12 13 17 18 20 21 27];
% predictorNames = predictorNames(idx_pred);
toc

%% Generate Health degree
disp('Generate Health degree hddn, hdsc, and hdmd...');
f_sort=0;
days_train = 200;
days_cost = 5; %no need
smart1_hd = smart1T;
smart1_hd = func_scale_smart_attributes(smart1_hd,predictorNames);


[hddn,smart1_hd,cost_hddn] = func_add_HD_datenum(smart1_hd,f_sort,predictorNames,sn_train,days_train,days_cost);
[hdsc,smart1_hd,cost_hdsc] = func_add_HD_SMART_center(smart1_hd,f_sort,predictorNames,sn_train,days_train,days_cost,10,2);
[hdmd,smart1_hd,cost_hdmd] = func_add_HD_mahalanobis_distance(smart1_hd,f_sort,predictorNames,sn_train,unique([0,3,6,11,16,23,30,days_train]),days_cost);
metaNames = {'id','sn_id','class','date','datenum','hddn','hdsc','hdmd'}; 

toc

%% Generate HD Prediction Model
smart_model = smart1_hd;
trainTable = smart_model(ismember(smart_model.sn_id,sn_train),:);
predictors = double(trainTable{:, predictorNames});

% Build Model: rfr + hddn as response
disp('Build Model: rfr + hddn as response...');
response_hddn = trainTable.hddn;
md_rfr_hddn = TreeBagger(100,predictors,response_hddn,'Method','regression');

% Build Model: rfr + hdsc as response
disp('Build Model: rfr + hdsc as response...');
response_hdsc = trainTable.hdsc;
md_rfr_hdsc = TreeBagger(100,predictors,response_hdsc,'Method','regression');

% Build Model: rfr + hdmd as response
disp('Build Model: rfr + hdmd as response...');
response_hdmd = trainTable.hdmd;
md_rfr_hdmd = TreeBagger(100,predictors,response_hdmd,'Method','regression');
toc

%% Test Model and prepare to evaluate
disp('Test Model and prepare result to evaluate...');
metaNames_model = {'id','sn_id','datenum','date',...
    'dn1','dn3','dn5','dn10',...
    'hddn','hdsc','hdmd',...
    'pred_hddn','pred_hdsc','pred_hdmd'}; 
testTable = smart_model(~ismember(smart_model.sn_id,sn_train),:);

testTable.pred_hddn = md_rfr_hddn.predict(double(testTable{:,predictorNames}));
testTable.pred_hdsc = md_rfr_hdsc.predict(double(testTable{:,predictorNames}));
testTable.pred_hdmd = md_rfr_hdmd.predict(double(testTable{:,predictorNames}));
testTable = testTable(:,[metaNames_model,predictorNames]);
uni_sn = unique(testTable.sn_id);

trainTable = smart_model(ismember(smart_model.sn_id,sn_train),:);
trainTable.pred_hddn = md_rfr_hddn.predict(double(trainTable{:,predictorNames}));
trainTable.pred_hdsc = md_rfr_hdsc.predict(double(trainTable{:,predictorNames}));
trainTable.pred_hdmd = md_rfr_hdmd.predict(double(trainTable{:,predictorNames}));
trainTable = trainTable(:,[metaNames_model,predictorNames]);
uni_sn_train = unique(trainTable.sn_id);

toc

%% Test for lambdaRank
idx_days_limit = trainTable.datenum < days_train;

Xtrain = trainTable(idx_days_limit, predictorNames);
Ytrain = ceil(trainTable.dn3(idx_days_limit)/3);
Xtest = testTable(:, predictorNames);
Ytest = ceil(testTable.dn3/3);

csvwrite(strcat(dir_mydata,'xtrain'),Xtrain{:,:});
csvwrite(strcat(dir_mydata,'ytrain'),Ytrain);
csvwrite(strcat(dir_mydata,'xtest'),Xtest{:,:});
csvwrite(strcat(dir_mydata,'ytest'),Ytest);

% status = system('python /home/xzhuang/Code/P/lambdaRank/lambdaRank.py');

% testpred = readtable(strcat(dir_mydata,'result_lambdaRank_test'),'ReadVariableNames',false);
% trainpred = readtable(strcat(dir_mydata,'result_lambdaRank_train'),'ReadVariableNames',false);

% testTable.pred_lmdrank = testpred.Var1;
testTable.pred_lmdrank = zeros(size(testTable,1),1);
trainTable.pred_lmdrank = zeros(size(trainTable,1),1);
toc

%% Result Evaluation: extract samples of each disk to compare. (repeat for num_random times)
disp('Evaluate predicted result for random samples of each fault disk...');
num_random = 10;
limited_days = 30;
dnX = 'dn1';
rev = 1;

cost_hddn = func_eval_disk_time_order_bydatenum(testTable,dnX,'pred_hddn',limited_days,num_random,rev);
cost_hdsc = func_eval_disk_time_order_bydatenum(testTable,dnX,'pred_hdsc',limited_days,num_random,rev);
cost_hdmd = func_eval_disk_time_order_bydatenum(testTable,dnX,'pred_hdmd',limited_days,num_random,rev);
cost_rank = func_eval_disk_time_order_bydatenum(testTable,dnX,'pred_lmdrank',limited_days,num_random,rev);
r = [cost_hddn,cost_hdsc,cost_hdmd,cost_rank];
r = array2table(r);
r.Properties.VariableNames = {'hddn','hdsc','hdmd','rank'};
r.Properties.RowNames = {'Test_pred'};
r


len_prednames = length(predictorNames);
cost_s = ones(len_prednames,1);
for i=1:len_prednames
    cost_s(i) = func_eval_disk_time_order_bydatenum(testTable,dnX,predictorNames{i},limited_days,num_random,rev);
end
find(cost_s<0.6)

toc

%% Result Analysis
idx_anl = {'id','sn_id','datenum','date','dn1','dn3','dn5','dn10','hddn','hdsc','hdmd','pred_hddn','pred_hdsc','pred_hdmd','pred_lmdrank'};
anlRes = testTable(:,idx_anl);

unstack_hddn = unstack(anlRes(:,{'sn_id','datenum','pred_hddn'}),'pred_hddn','sn_id');
unstack_hdsc = unstack(anlRes(:,{'sn_id','datenum','pred_hdsc'}),'pred_hdsc','sn_id');
unstack_hdmd = unstack(anlRes(:,{'sn_id','datenum','pred_hdmd'}),'pred_hdmd','sn_id');
unstack_rank = unstack(anlRes(:,{'sn_id','datenum','pred_lmdrank'}),'pred_lmdrank','sn_id');


rowmean_hddn = nanmean(table2array(unstack_hddn(:,2:end)),2);
rowmean_hdsc = nanmean(table2array(unstack_hdsc(:,2:end)),2);
rowmean_hdmd = nanmean(table2array(unstack_hdmd(:,2:end)),2);
rowmean_rank = nanmean(table2array(unstack_rank(:,2:end)),2);

rowmean = [(1:length(rowmean_hddn))',rowmean_hddn,rowmean_hdsc,rowmean_hdmd,rowmean_rank];

plot(rowmean(1:200,1),rowmean(1:200,3));
toc

%% Result Evaluation: extract samples of each disk to compare. (repeat for num_random times)
% disp('Evaluate predicted result for random days for each fault disks...');
% window_days = 3;
% limited_days = 30;
% random_days = 10;
% dnX = ['dn' num2str(window_days)];
% rev = 1;
% 
% cost_hddn = func_eval_disk_time_order_bynaturalday(testTable,dnX,'pred_hddn',window_days,limited_days,random_days,rev);
% cost_hdsc = func_eval_disk_time_order_bynaturalday(testTable,dnX,'pred_hdsc',window_days,limited_days,random_days,rev);
% cost_hdmd = func_eval_disk_time_order_bynaturalday(testTable,dnX,'pred_hdmd',window_days,limited_days,random_days,rev);
% cost_rank = func_eval_disk_time_order_bynaturalday(testTable,dnX,'pred_lmdrank',window_days,limited_days,random_days,rev);
% 
% cost_hddn_train_label = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'hddn',window_days,limited_days,random_days,rev);
% cost_hdsc_train_label = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'hdsc',window_days,limited_days,random_days,rev);
% cost_hdmd_train_label = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'hdmd',window_days,limited_days,random_days,rev);
% cost_rank_train_label = 0;
% 
% cost_hddn_train_pred = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'pred_hddn',window_days,limited_days,random_days,rev);
% cost_hdsc_train_pred = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'pred_hdsc',window_days,limited_days,random_days,rev);
% cost_hdmd_train_pred = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'pred_hdmd',window_days,limited_days,random_days,rev);
% cost_rank_train_pred = func_eval_disk_time_order_bynaturalday(trainTable,dnX,'pred_lmdrank',window_days,limited_days,random_days,rev);
% 
% 
% r = [cost_hddn,cost_hdsc,cost_hdmd,cost_rank;...
%     cost_hddn_train_label,cost_hdsc_train_label,cost_hdmd_train_label,cost_rank_train_label;...
%     cost_hddn_train_pred,cost_hdsc_train_pred,cost_hdmd_train_pred,cost_rank_train_pred];
% r = array2table(r);
% r.Properties.VariableNames = {'hddn','hdsc','hdmd','rank'};
% r.Properties.RowNames = {'Test_pred','Train_label','Train_pred'};
% r
% 
% toc
%% Parse result