% Disk Failure Prediction

%% Load data
clc;clear;
tic

dir_healthdegree = '~/Data/OnlineRF/health_degree/';
dir_csv = '/home/xzhuang/Data/OnlineRF/csv/';
dir_mat = '/home/xzhuang/Data/OnlineRF/mat/';

addpath('../eval_Model/');
addpath('../gen_HD/');
addpath('../Load/');

load(strcat(dir_mat,'ST4_4dfp.mat')); 
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

%% DFP by Random Forest
disp('DFP by Random Forest...')
predictors = double(smart_train_dfp{:, predictorNamesDiff});
response_hddn = smart_train_dfp.hddn;
md_rfr_hddn = TreeBagger(100,predictors,response_hddn,'Method','regression');
smart_test_dfp.pred_hddn_dfp = md_rfr_hddn.predict(double(smart_test_dfp{:,predictorNamesDiff}));
toc

%% DFP by rank
disp('DFP by rank...')
[status,cmdout] = system(sprintf('java -jar %s -train %s -test %s -ranker %d -tvs 0.8 -gmax %d -silent -metric2t ERR@10 -metric2T ERR@10 -save %s',...
    dir_jar,tr2_dfp,te1_dfp,ranker_id,7,mdsav1_dfp));
[status,cmdout] = system(sprintf('java -jar %s -load %s -rank %s -score %s -silent',dir_jar,mdsav1_dfp,te1_dfp,scsav1_dfp));
testpred = readtable(scsav1_dfp,'ReadVariableNames',false);
smart_test_dfp.pred_rank_dfp = table2array(testpred(:,3));
toc

%% filter attributes
evalDFP = smart_test_dfp;
evalDFP(:,predictorNamesDiff)=[];

%% SAVE
save(strcat(dir_mat,'ST4_dfp_pred.mat'),'evalDFP');