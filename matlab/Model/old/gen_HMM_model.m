% Generate HMM model, which consider time dependence between samples

%% Load data and generate train SN
clc;clear;
tic
disp('Load data and Generate train SN randomly...');

dir_mydata = '~/Data/OnlineRF/health_degree/';
addpath('../eval_Model/');
addpath('../gen_HD/');
load(strcat(dir_mydata,'smart1.mat'));
smart = smart1_dtest(smart1_dtest.class==1,:);

uni_disk = unique(smart.sn_id(smart.class==1,:));
len_ud = length(uni_disk);
sn_train = randsample(uni_disk,round(len_ud*0.666));
sta_sn = tabulate(smart.sn_id);
% predictorNames = predictorNames([2 4 8 14 15 21 24]);

metaNames = {'id','sn_id','class','date','datenum','hddn','hdsc','hdmd'}; 

toc

%% Add high-level datenum to group samples
tic
disp('group samples by datenum...');

smart = smart1_dtest(smart1_dtest.class==1,:);    
smart.dn1 = func_gen_tia_groups(smart.datenum,1,200);
smart.dn3 = func_gen_tia_groups(smart.datenum,3,200);
smart.dn5 = func_gen_tia_groups(smart.datenum,5,200);
smart.dn10 = func_gen_tia_groups(smart.datenum,10,200);
smart.dn20 = func_gen_tia_groups(smart.datenum,20,200);
smart.dn50 = func_gen_tia_groups(smart.datenum,50,200);

toc

%% Generate Model
tic
disp("build HMM model...");

smart_model = smart;
trainTable = smart_model(ismember(smart_model.sn_id,sn_train),:);
predictors = double(trainTable{:, predictorNames});

seq_days=10;
dnX = ['dn' num2str(seq_days)];
numGroups = 10;
idx_predictors = 14;

uni_dnX = sort(unique(smart_model.(dnX)));
smart_model.(dnX)(smart_model.(dnX)>uni_dnX(numGroups)) = uni_dnX(numGroups);
estimateTR = {};
estimateE = {};
observation_matrix_all=[];
obs_matrix_name = [regexp(sprintf('X%d ',1:seq_days),'\S+','match'),dnX,'sn_id'];

for i=1:numGroups
    trainTable_group = trainTable(trainTable.(dnX)==uni_dnX(i),{'sn_id','datenum',dnX,predictorNames{idx_predictors}});
    trainTable_group_unstack = unstack(trainTable_group,predictorNames{idx_predictors},'datenum');
    trainTable_group_unstack = fliplr(trainTable_group_unstack);
    trainTable_group_unstack.Properties.VariableNames = obs_matrix_name;
    observation_matrix_all = [observation_matrix_all;trainTable_group_unstack];
    
    trainTable_group_unstack.sn_id = [];
    trainTable_group_unstack.(dnX) = [];
    state_matrix = double(ones(size(trainTable_group_unstack)));
    observation_matrix = double(table2array(trainTable_group_unstack));
    
    [estimateTR{i},estimateE{i}] = hmmestimate(observation_matrix+1,state_matrix);

end

toc

%% Test Model and prepare to evaluate
disp('Test Model and prepare result to evaluate...');
testTable = smart_model(~ismember(smart_model.sn_id,sn_train),:);
uni_sn_test = unique(testTable.sn_id);

numSN = size(observation_matrix_all,1);
logprob_train = zeros(numSN,numGroups);
for i=1:numSN
    for j=1:numGroups
        seq_test = double(table2array(observation_matrix_all(i,3:end)))+1;
        if max(seq_test)>size(estimateE{j},2) | min(seq_test)<1
            continue
        end
        [PSTATES logprob_train(i,j)] = hmmdecode(seq_test,estimateTR{j},estimateE{j});
    end
end

logprob_train(isnan(logprob_train)) = -1e4; 
[~, logprob_train(:,numGroups+1)] = max(logprob_train,[],2);
observation_matrix_all.pred_hmm = logprob_train(:,numGroups+1);
observation_matrix_all.dn = ceil(observation_matrix_all.(dnX)/seq_days);
cost_hmm = func_eval_disk_time_order_bydatenum(observation_matrix_all,'dn','pred_hmm',10,10,0);

toc

