% Generate Rank model with smart1_test

%% Load data and generate train SN
clc;clear;
tic
disp('Load data and Generate train SN...');
dir_mydata = '~/Data/OnlineRF/health_degree/';
addpath('../eval_Model/');
addpath('../gen_HD/');
load(strcat(dir_mydata,'smart1.mat'));

smart1T = smart1_dtest(smart1_dtest.class==1,:);    %solutionA: failure prediction is accurate enough so that we only consider replace order of failed ones.
smart1T.dn1 = func_gen_tia_groups(smart1T.datenum,1,200);
smart1T.dn3 = func_gen_tia_groups(smart1T.datenum,3,200);
smart1T.dn5 = func_gen_tia_groups(smart1T.datenum,5,200);
smart1T.dn10 = func_gen_tia_groups(smart1T.datenum,10,200);

dt_pos = smart1T(smart1T.class==1,:);
uni_disk = unique(dt_pos.sn_id);
len_ud = length(uni_disk);
sn_train = randsample(uni_disk,round(len_ud*0.666));
sta_sn = tabulate(smart1T.sn_id);
smart1_hd = smart1T;
% predictorNames = predictorNames([2 4 8 14 15 21 24]);
toc

%% Generate train data
addpath(genpath('~/packages/mlr-1.1'));

smart_model = smart1_hd;
trainTable = smart_model(ismember(smart_model.sn_id,sn_train),:);

Xtrain = trainTable(:, predictorNames);
Xtrain = Xtrain(:,[2 4 8 14 15 21 24]);
Ytrain = ceil(trainTable.dn10/10);

csvwrite(strcat(dir_mydata,'xtrain'),Xtrain{:,:});
csvwrite(strcat(dir_mydata,'ytrain'),Ytrain);

toc

%% Generate test data
disp('Test Model and prepare result to evaluate...');


testTable = smart_model(~ismember(smart_model.sn_id,sn_train),:);
Xtest = testTable(:, predictorNames);
Xtest = Xtest(:,[2 4 8 14 15 21 24]);
Ytest = ceil(testTable.dn10/10);

csvwrite(strcat(dir_mydata,'xtest'),Xtest{:,:});
csvwrite(strcat(dir_mydata,'ytest'),Ytest);

toc

%% Read tested data and evaluate
pred = readtable(strcat(dir_mydata,'result_lambdaRank'),'ReadVariableNames',false);
metaNames_eval = {'sn_id','datenum','date','dn1','dn3','dn5','dn10'}; 
evalTable = testTable(:,metaNames_eval);
evalTable.pred_lmdrank = pred.Var1;
window_days = 1;
limited_days = 200;
random_days = 10;
num_random = 30;
dnX = ['dn' num2str(window_days)];
rev = 1;

cost_rank_dn = func_eval_disk_time_order_bydatenum(evalTable,dnX,'pred_lmdrank',limited_days,num_random,rev);
cost_rank_nt = func_eval_disk_time_order_bynaturalday(evalTable,dnX,'pred_lmdrank',window_days,limited_days,random_days,rev);

