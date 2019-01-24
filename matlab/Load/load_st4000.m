% Load complete ST4000 data
% last code is
% /home/yiyusheng/Code/R/SMART/backblaze/gen_data_ST4000DM000.R @ cu02
% next code is 
%% config
clc;clear;
dir_csv = '/home/xzhuang/Data/OnlineRF/csv/';
dir_mat = '/home/xzhuang/Data/OnlineRF/mat/';

%% Load and Save pos and neg
smart_ST4000_pos = readtable(strcat(dir_csv,'ST4000_pos.csv'));
smartNames = smart_ST4000_pos.Properties.VariableNames;
pos_sn = tabulate(smart_ST4000_pos.sn);
pos_sn(:,4) = num2cell(1:size(pos_sn,1));
[idxA, idxB] = ismember(smart_ST4000_pos.sn,pos_sn(:,1));
smart_ST4000_pos.sn_id = cell2mat(pos_sn(idxB,4));
smart_ST4000_pos = smart_ST4000_pos(:,[{'sn_id'} smartNames]);
max_sn_id_pos = max(smart_ST4000_pos.sn_id);

smart_ST4000_neg = readtable(strcat(dir_csv,'ST4000_neg.csv'));
neg_sn = tabulate(smart_ST4000_neg.sn);
neg_sn(:,4) = num2cell(1+max_sn_id_pos:size(neg_sn,1)+max_sn_id_pos);  %max pos sn_id +1 = min neg sn_id
[idxA, idxB] = ismember(smart_ST4000_neg.sn,neg_sn(:,1));
smart_ST4000_neg.sn_id = cell2mat(neg_sn(idxB,4));
smart_ST4000_neg = smart_ST4000_neg(:,[{'sn_id'} smartNames]);

save(strcat(dir_mat,'ST4000_pos.mat'),'smart_ST4000_pos','pos_sn','-v7.3');
save(strcat(dir_mat,'ST4000_neg.mat'),'smart_ST4000_neg','neg_sn','-v7.3');
load(strcat(dir_mat,'predictorNames.mat'));

%% seperate neg and neg then into train(70%) and test(30%) by sn_id
pos_id = unique(smart_ST4000_pos.sn_id);
neg_id = unique(smart_ST4000_neg.sn_id);

train_id = [randsample(pos_id,round(length(pos_id)*0.7),false);...
    randsample(neg_id,round(length(neg_id)*0.7),false)];

test_id = setdiff([pos_id;neg_id],train_id);

save(strcat(dir_mat,'ST4000_sn.mat'),'pos_id','neg_id','train_id','test_id');
days_limit_pos = 100;
days_limit_neg = 5;

%% generate and save train and test for pos
trainset = smart_ST4000_pos(ismember(smart_ST4000_pos.sn_id,train_id),:);
testset = smart_ST4000_pos(ismember(smart_ST4000_pos.sn_id,test_id),:);
smart_train_pos = trainset(trainset.datenum<=days_limit_pos,:);
smart_test_pos = testset(testset.datenum<=days_limit_pos,:);
fn = ['ST4_pos_d' num2str(days_limit_pos) '.mat'];
save(strcat(dir_mat,fn),'smart_train_pos','smart_test_pos');

%% generate and save train and test for neg
smart_ST4000_neg.datenum = smart_ST4000_neg.datenum+500; %add datenum for neg samples;
trainset = smart_ST4000_neg(ismember(smart_ST4000_neg.sn_id,train_id),:);
testset = smart_ST4000_neg(ismember(smart_ST4000_neg.sn_id,test_id),:);
smart_train_neg = trainset(trainset.datenum<=days_limit_neg+500,:);
smart_test_neg = testset(testset.datenum<=days_limit_neg+500,:);
fn = ['ST4_neg_d' num2str(days_limit_neg) '.mat'];
save(strcat(dir_mat,fn),'smart_train_neg','smart_test_neg');
