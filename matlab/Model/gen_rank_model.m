% generate rank model
% In process
%   last code file:
%   next code file:

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

load(strcat(dir_mat,'ST4_pos_features_4rank.mat'));
load(strcat(dir_mat,'predictorNames.mat'));
toc

%% Set parameters
disp('Set parameters...');

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

rankNames = 'datenum';
dir_jar = '/home/xzhuang/Code/J/RankLib/RankLib-2.10.jar';
tr2 = strcat(dir_csv,['ST4traind30q2tr' num2str(days_train) '.txt']);
te1 = strcat(dir_csv,['ST4testd30te.txt']);
tr2_dfp = strcat(dir_csv,['ST4traindfp' num2str(days_train) '.txt']);
te1_dfp = strcat(dir_csv,['ST4testdfp.txt']);
mdsav1 = strcat(dir_csv,['model_dfp' num2str(days_train) '.txt']);
scsav1 = strcat(dir_csv,['score_dfp' num2str(days_train) '.txt']);
mdsav1_dfp = strcat(dir_csv,['model_dfp' num2str(days_train) '.txt']);
scsav1_dfp = strcat(dir_csv,['score_dfp' num2str(days_train) '.txt']);

metaNames_model = {'id','sn_id','datenum','class','date','dn1','dn3','dn5','dn10',...
    'hddn','hdsc','hdmd','pred_hddn','pred_hdsc','pred_hdmd','pred_rank'}; 

toc

%% Build and Test HD Prediction Model(pointwise algorithms)
predictors = double(trainTable{:, predictorNamesDiff});

% Build Model: rfr + hddn as response
disp('Build Model: rfr + hddn as response...');
response_hddn = trainTable.hddn;
md_rfr_hddn = c(100,predictors,response_hddn,'Method','regression');

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
testTable.pred_hddn = md_rfr_hddn.predict(double(testTable{:,predictorNamesDiff}));
testTable.pred_hdsc = md_rfr_hdsc.predict(double(testTable{:,predictorNamesDiff}));
testTable.pred_hdmd = md_rfr_hdmd.predict(double(testTable{:,predictorNamesDiff}));
trainTable.pred_hddn = md_rfr_hddn.predict(double(trainTable{:,predictorNamesDiff}));
trainTable.pred_hdsc = md_rfr_hdsc.predict(double(trainTable{:,predictorNamesDiff}));
trainTable.pred_hdmd = md_rfr_hdmd.predict(double(trainTable{:,predictorNamesDiff}));

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
testTable = testTable(:,[metaNames_model,predictorNamesDiff]);
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
       
        summary_all = [summary_all;summary_eval_my];

    end
end
toc

disp('gen rank model Done!!!');


%% SAVE result for figure plot
% save(strcat(dir_mat,sprintf('result_for_eval_tit%s.mat',num2str(testistrain))),'trainTable','testTable','summary_all');