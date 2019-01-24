% select sn by their correlation between datenum and smartattr

%% Load
clc;clear;
tic
disp('Load data and Generate train SN...');

dir_healthdegree = '~/Data/OnlineRF/health_degree/';
dir_csv = '/home/xzhuang/Data/OnlineRF/csv/';
dir_mat = '/home/xzhuang/Data/OnlineRF/mat/';

addpath('../eval_Model/');
addpath('../gen_HD/');
addpath('../Load/');

load(strcat(dir_mat,'ST4_pos_d100.mat'));   %all are pos sn
load(strcat(dir_mat,'predictorNames.mat'));
smart = [smart_train;smart_test];
smart.class(:) = 1;

metaNames = {'sn_id','sn','date','class','datenum'};
smart = smart(:,[metaNames,predictorNames]);

toc


%% Generate the correlation result for each disk.
disp('Generate the correlation result for each disk...')

CR = smart;
len_id = length(unique(CR.sn_id));
len_pred = length(predictorNames);
[G groups] = findgroups(CR.sn_id);
id_dist = unique(CR.sn_id);
corr2_my = @(x,y)abs(corr2(x,y));

for i= 1:len_pred
    cur_predictor = CR.(predictorNames{i});
    id_dist(:,i+1) = splitapply(corr2_my,CR.datenum,cur_predictor,G);
end
id_dist(isnan(id_dist)) = 0;
id_dist = array2table(id_dist);
id_dist.Properties.VariableNames = [{'sn_id'} predictorNames];
id_dist.sum_corr2 = sum(table2array(id_dist(:,2:end)),2);

toc
%% save sn 
sn_good_rank = id_dist.sn_id(id_dist.sum_corr2 >= quantile(id_dist.sum_corr2,0.9));
save(strcat(dir_mat,'sn_good_rank_1126.mat'),'sn_good_rank');

