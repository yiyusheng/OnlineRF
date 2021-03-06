% Generate features for ranking and disk failure prediction
% In process:
%   last code file: /home/xzhuang/Code/C/OnlineRF/matlab/Model
%   next code file: /home/xzhuang/Code/C/OnlineRF/matlab/Model

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

load(strcat(dir_mat,'predictorNames.mat'));
metaNames = {'sn_id','date','class','datenum'};
smart = smart(:,[metaNames,predictorNames]);

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
isIncludeNeg_ranking = 0;
warning off;                                                % Turn off warning


rankNames = 'datenum';
dir_jar = '/home/xzhuang/Code/J/RankLib/RankLib-2.10.jar';
tr2 = strcat(dir_csv,['ST4traind30q2tr' num2str(days_train) '.txt']);
te1 = strcat(dir_csv,['ST4testd30te.txt']);
tr2_dfp = strcat(dir_csv,['ST4traindfp' num2str(days_train) '.txt']);
te1_dfp = strcat(dir_csv,['ST4testdfp.txt']);
mdsav1_dfp = strcat(dir_csv,['model_dfp' num2str(days_train) '.txt']);
scsav1_dfp = strcat(dir_csv,['score_dfp' num2str(days_train) '.txt']);
isIncludeNeg_dfp = 1;
toc

%% filter sn without enough days data
disp('Filter sn without enough days data...');
    
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
%[limit days when generating features. It is better to limit days in trainTable generation]
disp('Generate diff + datenum 1/3/5/10 + Health degree hddn, hdsc, and hdmd...');
smart_feature = smart;

% diff
smart_feature = func_gen_diff(smart_feature,predictorNames);
predictorNamesDiff = [predictorNames strcat(predictorNames,'_diff')];

% datenum
max_dn = min([max(smart_feature.datenum) 200]);
smart_feature.dn1 = func_gen_tia_groups(smart_feature.datenum,1,max_dn);
smart_feature.dn3 = func_gen_tia_groups(smart_feature.datenum,3,max_dn);
smart_feature.dn5 = func_gen_tia_groups(smart_feature.datenum,5,max_dn);
smart_feature.dn10 = func_gen_tia_groups(smart_feature.datenum,10,max_dn);

% health degree
smart_feature = func_scale_smart_attributes(smart_feature,predictorNamesDiff);
smart_feature = func_add_HD_datenum(smart_feature,need_oriorder);
smart_feature = func_add_HD_SMART_center(smart_feature,need_oriorder,predictorNamesDiff,K_kmeans,key_days);
smart_feature = func_add_HD_mahalanobis_distance(smart_feature,need_oriorder,predictorNamesDiff,sn_train,rankCut);

% train and test
smart_gen_HD_model = smart_feature;
trainTable = smart_gen_HD_model(ismember(smart_gen_HD_model.sn_id,sn_train) & smart_gen_HD_model.datenum <= days_train,:);
testTable = smart_gen_HD_model(~ismember(smart_gen_HD_model.sn_id,sn_train),:);
if(testistrain==1)
    testTable = trainTable;
end

save(strcat(dir_mat,'ST4_pos_features_4rank.mat'),'testTable','trainTable');

toc

%% Prepare data for Ranklib 
disp('Prepare data for Ranklib...');

data_tr2_rank = func_convert_to_rank(trainTable,predictorNamesDiff,rankNames,rankCut,2,tr2,isIncludeNeg_ranking);  % build the model of two qid
data_te1_rank = func_convert_to_rank(testTable,predictorNamesDiff,rankNames,rankCut,1,te1,isIncludeNeg_ranking);     % group1 for model qid:1

toc

%% Prepare data for DFP for hddn and rank
disp('Prepare data for DFP for hddn and rank...');

load(strcat(dir_mat,'ST4_neg_d5.mat')); 
load(strcat(dir_mat,'ST4_pos_d100.mat'));   
load(strcat(dir_mat,'predictorNames.mat'));

% set class
smart_train_pos.class(:)=1;
smart_test_pos.class(:)=1;
smart_train_neg.class(:)=0;
smart_test_neg.class(:)=0;

% build train and test
smart_train_dfp = [smart_train_pos(smart_train_pos.datenum<days_train,:);smart_train_neg];
smart_train_dfp = func_gen_diff(smart_train_dfp,predictorNames);
smart_train_dfp = func_add_HD_datenum(smart_train_dfp,need_oriorder);
smart_train_dfp.hddn(smart_train_dfp.class==0) = 0;
smart_test_dfp = [smart_test_pos(smart_test_pos.datenum<days_train,:);;smart_test_neg];
smart_test_dfp = func_gen_diff(smart_test_dfp,predictorNames);
smart_test_dfp = func_add_HD_datenum(smart_test_dfp,need_oriorder);
smart_test_dfp.hddn(smart_test_dfp.class==0) = 0;

save(strcat(dir_mat,'ST4_4dfp.mat'),'smart_train_dfp','smart_test_dfp');

% save data for rank
data_tr2_dfp = func_convert_to_rank(smart_train_dfp,predictorNames,rankNames,rankCut,2,tr2_dfp,isIncludeNeg_dfp);  % generate train data for dfp
data_te1_dfp = func_convert_to_rank(smart_test_dfp,predictorNames,rankNames,rankCut,1,te1_dfp,isIncludeNeg_dfp);   % generate test data for dfp
toc

disp('gen feature Done!!!');
