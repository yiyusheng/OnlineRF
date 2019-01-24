% Convert trainset and testset of st4000 into SVMrank format and save them
%% config
clc;clear;
dir_csv = '/home/xzhuang/Data/OnlineRF/csv/';
dir_mat = '/home/xzhuang/Data/OnlineRF/mat/';

%% load
load(strcat(dir_mat,'ST4000_pos.mat'));
load(strcat(dir_mat,'ST4000_neg.mat'));
load(strcat(dir_mat,'ST4000_sn.mat'));
load(strcat(dir_mat,'predictorNames.mat'));

%% generate trainset and testset
smart_ST4000_neg.datenum = smart_ST4000_neg.datenum+500; %add datenum for neg samples;

% only for pos sn
train_id = intersect(train_id,pos_id);  
test_id = intersect(test_id,pos_id);

trainset = [smart_ST4000_neg(ismember(smart_ST4000_neg.sn_id,train_id),:);...
    smart_ST4000_pos(ismember(smart_ST4000_pos.sn_id,train_id),:)];

testset = [smart_ST4000_neg(ismember(smart_ST4000_neg.sn_id,test_id),:);...
    smart_ST4000_pos(ismember(smart_ST4000_pos.sn_id,test_id),:)]; 

%% seperate config
% predictorNames = smart_ST4000_pos.Properties.VariableNames(5:end);
rankNames = 'datenum';
rankCut = [0 3 6 11 16 23 30];
rankCut4 = [0 3 6 11];

%% save mat format data
smart_train = trainset(trainset.datenum<=30,:);
smart_test = testset(testset.datenum<=30,:);
% save(strcat(dir_mat,'ST4_pos_d30.mat'),'smart_train','smart_test');

%% generate SVMrank format data and save with some condition

% for samples with datenum less than 30 + 7 rank levels + full features + qid=[1,2] 
func_convert_to_rank(trainset(trainset.datenum<=30,:),predictorNames,rankNames,rankCut,2,strcat(dir_csv,'ST4traind30q2'));  % build the model of two qie
func_convert_to_rank(testset(testset.datenum<=30,:),predictorNames,rankNames,rankCut,2,strcat(dir_csv,'ST4testd30q2'));     % useless
func_convert_to_rank(testset(testset.datenum<=30,:),predictorNames,rankNames,rankCut,1,strcat(dir_csv,'ST4testd30Q1'));     % group1 for model qid:1
func_convert_to_rank(testset(testset.datenum<=30,:),predictorNames,rankNames,rankCut,-2,strcat(dir_csv,'ST4testd30Q2'));    % group2 for model qid:2

% for samples with datenum less than 30 + 7 rank levels + full features + qid=[1,2,3,4,5]
func_convert_to_rank(trainset(trainset.datenum<=30,:),predictorNames,rankNames,rankCut,5,strcat(dir_csv,'ST4traind30q5'));
func_convert_to_rank(testset(testset.datenum<=30,:),predictorNames,rankNames,rankCut,5,strcat(dir_csv,'ST4testd30q5'));

% for samples with datenum less than 30 + 7 rank levels + full features + qid=[1,2,3,4,5,6,7,8,9,10]
func_convert_to_rank(trainset(trainset.datenum<=30,:),predictorNames,rankNames,rankCut,10,strcat(dir_csv,'ST4traind30q10'));
func_convert_to_rank(testset(testset.datenum<=30,:),predictorNames,rankNames,rankCut,10,strcat(dir_csv,'ST4testd30q10'));

%% generate SVMrank format data for all and save
func_convert_to_rank(trainset,predictorNames,rankNames,rankCut,strcat(dir_csv,'ST4train'));
func_convert_to_rank(testset,predictorNames,rankNames,rankCut,strcat(dir_csv,'ST4test'));

