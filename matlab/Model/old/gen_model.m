% Generate model with smart from disk model ST4000. model contains RF and
% lambdaMART. Health degree contrains datenum, smart center and mahalanobis
% distance

%% Load data 
clc;clear;
tic
disp('Load data and Generate test SN...');

dir_healthdegree = '~/Data/OnlineRF/health_degree/';
dir_csv = '/home/xzhuang/Data/OnlineRF/csv/';
dir_mat = '/home/xzhuang/Data/OnlineRF/mat/';

addpath('../eval_Model/');
addpath('../gen_HD/');
addpath('../Load/');

%all are pos sn
load(strcat(dir_mat,'ST4_pos_d100.mat'));   
smart = [smart_train_pos;smart_test_pos];
smart.class(:) = 1;

%xzhuang data
% load(strcat(dir_healthdegree,'smart1.mat'));
% smart = smart1_dtest(smart1_dtest.class == 1,:);
% smart.sn = smart.sn_id;

load(strcat(dir_mat,'predictorNames.mat'));
metaNames = {'sn_id','date','class','datenum'};
smart = smart(:,[metaNames,predictorNames]);

toc

%% filter sn without enough days data and set model parameters
disp('Filter sn without enough days data and set model parameters...');
% model parameters
days_train = 30;
days_eval = [3,7,14,28];
num_random = 10;                                            %sample extraction count for each disk in my metric
rankCut = sort(unique([0 3 6 11 16 23 30 days_train]));     %rankcut and mahalanobis cut
need_oriorder=0;                                            % Should keep origical order when add health degree
daysLimit_pos = days_train;                                 % Condition1: pos sn in trainset must have more than numLimit_pos days data
daysLimit_neg = 20;                                         % Condition2: neg sn in trainset must have more than numLimit_neg days data
key_days = 2;                                               % For HD SMART_center
K_kmeans = round(days_train/3);                             % Fwor HD SMART_center
ranker_id = 6;                                              % Rank method
testistrain = 0;
warning off;                                                % Turn off warning
    
% statistic sn
uni_disk = unique(smart.sn_id);
sta_sn = array2table(tabulate(smart.sn_id));
sta_sn.Properties.VariableNames={'sn_id','count','rate'};
pos_sn = unique(smart.sn_id(smart.class==1));
sta_sn.ispos = ismember(sta_sn.sn_id,pos_sn);

% set trainset sn
% len_ud = length(uni_disk);
% sn_train = randsample(uni_disk,round(len_ud*0.666));
% save(strcat(dir_mat,'sn_train_1124.mat'),'sn_train','uni_disk');
load(strcat(dir_mat,'sn_train_1124.mat'));
% sn_train = unique(sta_sn.sn_id);

% filter sn in trainset
sta_sn.intrain = ismember(sta_sn.sn_id,sn_train);
sta_sn.isinvalid_as_train_pos = sta_sn.intrain & sta_sn.ispos & sta_sn.count<daysLimit_pos;
sta_sn.isinvalid_as_train_neg = sta_sn.intrain & ~sta_sn.ispos & sta_sn.count<daysLimit_neg;

%select good sn
load(strcat(dir_mat,'sn_good_rank_1126.mat'));
sta_sn = sta_sn(ismember(sta_sn.sn_id,sn_good_rank),:);

smart = smart(~ismember(smart.sn_id,sta_sn.sn_id(sta_sn.isinvalid_as_train_pos | sta_sn.isinvalid_as_train_neg)),:);

toc

%% Generate diff + 1/3/5/10 days datenum + hddn/hdsc/hdmd (health degree) and seperate data into train and test
%[limit days when generating features.It is better to limit days in trainTable generation]
disp('Generate diff + datenum 1/3/5/10 + Health degree hddn, hdsc, and hdmd...');
smart_feature = smart;

% diff
smart_feature = func_gen_diff(smart_feature,predictorNames);
predictorNames = [predictorNames strcat(predictorNames,'_diff')];

% datenum
max_dn = min([max(smart_feature.datenum) 200]);
smart_feature.dn1 = func_gen_tia_groups(smart_feature.datenum,1,max_dn);
smart_feature.dn3 = func_gen_tia_groups(smart_feature.datenum,3,max_dn);
smart_feature.dn5 = func_gen_tia_groups(smart_feature.datenum,5,max_dn);
smart_feature.dn10 = func_gen_tia_groups(smart_feature.datenum,10,max_dn);

% health degree
smart_feature = func_scale_smart_attributes(smart_feature,predictorNames);
smart_feature = func_add_HD_datenum(smart_feature,need_oriorder);
smart_feature = func_add_HD_SMART_center(smart_feature,need_oriorder,predictorNames,K_kmeans,key_days);
smart_feature = func_add_HD_mahalanobis_distance(smart_feature,need_oriorder,predictorNames,sn_train,rankCut);

% train and test
smart_gen_HD_model = smart_feature;
trainTable = smart_gen_HD_model(ismember(smart_gen_HD_model.sn_id,sn_train) & smart_gen_HD_model.datenum <= days_train,:);
testTable = smart_gen_HD_model(~ismember(smart_gen_HD_model.sn_id,sn_train),:);
if(testistrain==1)
    testTable = trainTable;
end

toc

%% Build and Test HD Prediction Model(pointwise algorithms)
predictors = double(trainTable{:, predictorNames});

% Build Model: rfr + hddn as response
disp('Build Model: rfr + hddn as response...');
response_hddn = trainTable.hddn;
md_rfr_hddn = TreeBagger(100,predictors,response_hddn,'Method','regression');

% Build Model: rfr + hdsc as response
disp('Build Model: rfr + hdsc as response...');
response_hdsc = trainTable.hdsc;
% md_rfr_hdsc = TreeBagger(100,predictors,response_hdsc,'Method','regression');
md_rfr_hdsc = md_rfr_hddn;

% Build Model: rfr + hdmd as response
disp('Build Model: rfr + hdmd as response...');
response_hdmd = trainTable.hdmd;
% md_rfr_hdmd = TreeBagger(100,predictors,response_hdmd,'Method','regression');
md_rfr_hdmd = md_rfr_hddn;

% Test Model
disp('Test Model and prepare result to evaluate...');
testTable.pred_hddn = md_rfr_hddn.predict(double(testTable{:,predictorNames}));
testTable.pred_hdsc = md_rfr_hdsc.predict(double(testTable{:,predictorNames}));
testTable.pred_hdmd = md_rfr_hdmd.predict(double(testTable{:,predictorNames}));
trainTable.pred_hddn = md_rfr_hddn.predict(double(trainTable{:,predictorNames}));
trainTable.pred_hdsc = md_rfr_hdsc.predict(double(trainTable{:,predictorNames}));
trainTable.pred_hdmd = md_rfr_hdmd.predict(double(trainTable{:,predictorNames}));

toc

%% Prepare data for Ranklib 
disp('Prepare data for Ranklib ');

rankNames = 'datenum';

dir_jar = '/home/xzhuang/Code/J/RankLib/RankLib-2.10.jar';
tr2 = strcat(dir_csv,['ST4traind30q2tr' num2str(days_train) '.txt']);
te1 = strcat(dir_csv,['ST4testd30te.txt']);
mdsav1 = strcat(dir_csv,['model_tr' num2str(days_train) '.txt']);
scsav1 = strcat(dir_csv,['score_tr' num2str(days_train) '.txt']);

data_tr2 = func_convert_to_rank(trainTable,predictorNames,rankNames,rankCut,2,tr2);  % build the model of two qid
data_te1 = func_convert_to_rank(testTable,predictorNames,rankNames,rankCut,1,te1);     % group1 for model qid:1

toc
%% Build and Test Rank Model(listwise algorithms)
disp('Build and Test Rank Model');

[status,cmdout] = system(sprintf('java -jar %s -train %s -test %s -ranker %d -tvs 0.8 -gmax %d -silent -metric2t ERR@10 -metric2T ERR@10 -save %s',...
    dir_jar,tr2,te1,ranker_id,length(rankCut)-1,mdsav1));
[status,cmdout] = system(sprintf('java -jar %s -load %s -rank %s -score %s -silent',dir_jar,mdsav1,te1,scsav1));

testpred = readtable(scsav1,'ReadVariableNames',false);
testTable.pred_rank = table2array(testpred(:,3));

toc

%% Result Evaluation: extract samples of each disk to compare. (repeat for num_random times)
disp('Evaluate predicted result for random samples of each fault disk...');
metaNames_model = {'id','sn_id','datenum','class','date','dn1','dn3','dn5','dn10',...
    'hddn','hdsc','hdmd','pred_hddn','pred_hdsc','pred_hdmd','pred_rank'}; 
testTable = testTable(:,[metaNames_model,predictorNames]);
testTable.pred_rand = rand(size(testTable,1),1);

evalTable = testTable(:,metaNames_model);
evalTableX = evalTable(evalTable.datenum <= 10,:);
summary_all = table();


for q1=0.5:0.1:0.5
    for q2=0.5:0.1:0.5
        sn_good_rank = func_eval_gen_good_rank(testTable,q1,q2);
        evalTable = testTable(ismember(testTable.sn_id,sn_good_rank),:);

        dnX = 'dn1';
        rev = 1;

        summary_eval_my = table();
        summary_eval_ndcg = table();
        for i=1:length(days_eval)
            [r_my r_ndcg] = func_eval(evalTable,dnX,days_eval(i),num_random,q1,q2);
            summary_eval_my = [summary_eval_my;r_my];
            summary_eval_ndcg = [summary_eval_ndcg;r_ndcg];

        end
        
        summary_eval_my
%         summary_eval_ndcg
        
        summary_all = [summary_all;summary_eval_my];

    end
end
toc

%% Disk Failure Prediction
load(strcat(dir_mat,'ST4_neg_d5.mat')); 
load(strcat(dir_mat,'predictorNames.mat'));

% set class
smart_train_pos.class(:)=1;
smart_test_pos.class(:)=1;
smart_train_neg.class(:)=0;
smart_test_neg.class(:)=0;

% build train and test
smart_train_dfp = [smart_train_pos;smart_train_neg];
smart_train_dfp = func_gen_diff(smart_train_dfp,predictorNames);
smart_train_dfp = func_add_HD_datenum(smart_train_dfp,need_oriorder);
smart_test_dfp = [smart_test_pos;smart_test_neg];
smart_test_dfp = func_gen_diff(smart_test_dfp,predictorNames);
smart_test_dfp = func_add_HD_datenum(smart_test_dfp,need_oriorder);
predictorNames = [predictorNames strcat(predictorNames,'_diff')];
toc

% for hddn
predictors = double(smart_train_dfp{:, predictorNames});
response_hddn = smart_train_dfp.hddn;
md_rfr_hddn = TreeBagger(100,predictors,response_hddn,'Method','regression');
smart_test_dfp.pred_hddn_dfp = md_rfr_hddn.predict(double(smart_test_dfp{:,predictorNames}));
toc

% for rank
rankNames = 'datenum';
dir_jar = '/home/xzhuang/Code/J/RankLib/RankLib-2.10.jar';
tr2 = strcat(dir_csv,['ST4traindfp' num2str(days_train) '.txt']);
te1 = strcat(dir_csv,['ST4testdfp.txt']);
mdsav1 = strcat(dir_csv,['model_dfp' num2str(days_train) '.txt']);
scsav1 = strcat(dir_csv,['score_dfp' num2str(days_train) '.txt']);
data_tr2 = func_convert_to_rank(smart_train_dfp,predictorNames,rankNames,rankCut,2,tr2);  % build the model of two qid
data_te1 = func_convert_to_rank(smart_test_dfp,predictorNames,rankNames,rankCut,1,te1);     % group1 for model qid:1
[status,cmdout] = system(sprintf('java -jar %s -train %s -test %s -ranker %d -tvs 0.8 -gmax %d -silent -metric2t ERR@10 -metric2T ERR@10 -save %s',...
    dir_jar,tr2,te1,ranker_id,length(rankCut)-1,mdsav1));
[status,cmdout] = system(sprintf('java -jar %s -load %s -rank %s -score %s -silent',dir_jar,mdsav1,te1,scsav1));
testpred = readtable(scsav1,'ReadVariableNames',false);
smart_test_dfp.pred_rank_dfp = table2array(testpred(:,3));
toc

% filter attributes
evalDFP = smart_test_dfp;
evalDFP(:,predictorNames)=[];

%% SAVE result for figure plot
% save(strcat(dir_mat,sprintf('result_for_eval_tit%s.mat',num2str(testistrain))),'trainTable','testTable','summary_all','evalDFP');


%% SMART observe for descending attributes
% days_observe = 10;
% smartObserve = smart_feature(smart_feature.datenum <= days_observe,:);
% [G groups] = findgroups(smartObserve.datenum);
% len_predictor = length(predictorNames);
% 
% for i=1:len_predictor
%     subplot(8,8,i)
%     cur_predictor = predictorNames{i};
%     y = splitapply(@mean,smartObserve.(cur_predictor),G);
%     plot(y)
% end



%% test predictor attribtues and choose them
% len_prednames = length(predictorNames);
% cost_s = ones(len_prednames,1);
% for i=1:len_prednames
%     cost_s(i) = func_eval_disk_time_order_bydatenum(testTable,dnX,predictorNames{i},limited_days,num_random,rev);
% end
% find(cost_s<0.6)

% toc
%% Result Analysis
% idx_anl = {'id','sn_id','datenum','date','dn1','dn3','dn5','dn10','hddn','hdsc','hdmd','pred_hddn','pred_hdsc','pred_hdmd','pred_lmdrank'};
% anlRes = testTable(:,idx_anl);
% 
% unstack_hddn = unstack(anlRes(:,{'sn_id','datenum','pred_hddn'}),'pred_hddn','sn_id');
% unstack_hdsc = unstack(anlRes(:,{'sn_id','datenum','pred_hdsc'}),'pred_hdsc','sn_id');
% unstack_hdmd = unstack(anlRes(:,{'sn_id','datenum','pred_hdmd'}),'pred_hdmd','sn_id');
% unstack_rank = unstack(anlRes(:,{'sn_id','datenum','pred_lmdrank'}),'pred_lmdrank','sn_id');
% 
% 
% rowmean_hddn = nanmean(table2array(unstack_hddn(:,2:end)),2);
% rowmean_hdsc = nanmean(table2array(unstack_hdsc(:,2:end)),2);
% rowmean_hdmd = nanmean(table2array(unstack_hdmd(:,2:end)),2);
% rowmean_rank = nanmean(table2array(unstack_rank(:,2:end)),2);
% 
% rowmean = [(1:length(rowmean_hddn))',rowmean_hddn,rowmean_hdsc,rowmean_hdmd,rowmean_rank];
% 
% plot(rowmean(1:200,1),rowmean(1:200,3));
% toc

