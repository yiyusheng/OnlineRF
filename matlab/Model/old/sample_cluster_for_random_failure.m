%% Load data
clc;clear;
export = 1;
f_sort = 0;
dir_mydata = '~/Data/OnlineRF/oriorder/';
dir_data = '/home/xzhuang/Data/xzData20180711/mat/';
load(strcat(dir_data,'smart1_all.mat'));
load(strcat(dir_data,'smart1_train_all.mat'));
load(strcat(dir_data,'smart1_dtest.mat'));
predictorNames = {...
    'smart_5_raw',...
    'smart_187_raw',...
    'smart_197_raw',...
    'smart_1_normalized',...
    'smart_4_raw',...
    'smart_7_normalized',...
    'smart_9_normalized',...
    'smart_12_raw',...
    'smart_183_raw',...
    'smart_184_raw',...
    'smart_189_raw',...
    'smart_193_normalized',...
    'smart_198_raw',...
    'smart_199_raw',...
    'smart_3_normalized',...
    'smart_5_normalized',...
    'smart_7_raw',...
    'smart_9_raw',...
    'smart_183_normalized',...
    'smart_184_normalized',...
    'smart_187_normalized',...
    'smart_188_normalized',...
    'smart_188_raw',...
    'smart_189_normalized',...
    'smart_192_raw',...
    'smart_193_raw',...
    'smart_194_raw',...
    'smart_197_normalized',...
    'smart_198_normalized'};

c = {'id','sn_id','date','datenum','class'};
smart = smart1_dtest;
% smart = smart1_all;
size_smart = size(smart);
smart.id = (1:size_smart(1))';
smart_meta = smart(:,metaNames);

fail_snid = unique(smart.sn_id(smart.class==1));
smart_fail = smart(ismember(smart.sn_id,fail_snid),[metaNames,predictorNames]);
% a = sortrows(smart_fail,'sn_id');

%% cluster by predictorNames
data1 = double(smart_fail{:,predictorNames});
% [Idx3,C3,sumD3] = kmeans(data1,3);
% [Idx5,C5,sumD5] = kmeans(data1,5);
% [Idx10,C10,sumD10] = kmeans(data1,10);
% [Idx50,C50,sumD50] = kmeans(data1,50);
[Idx100,C100,sumD100] = kmeans(data1,100,'Replicates',10);
tab100 = tabulate(Idx100);
idx_largepart = tab100(tab100(:,2)>200,1);
% idx_largepart = tab100(tab100(:,3)>5,1);


%% add class
% idx = table(Idx3,Idx5,Idx10,Idx50,Idx100,'VariableNames',{'idx3','idx5','idx10','idx50','idx100'});
idx = table(Idx100,'VariableNames',{'idx100'});
smart_fail_meta = [smart_fail(:,metaNames),idx];
smart_fail_meta.idx = smart_fail_meta.idx100;
smart_fail_meta.idx(~ismember(smart_fail_meta.idx,idx_largepart)) = 0;
len_idx = length(unique(smart_fail_meta.idx));
%a = tabulate(smart_fail_meta.idx);

%% calculate mean and std for rest time of each samples
[G,groups] = findgroups(smart_fail_meta.idx);
tab_idx = tabulate(smart_fail_meta.idx);
sta_resttime = zeros(len_idx,4);   
sta_resttime(:,1) = groups;
sta_resttime(:,2) = tab_idx(find(tab_idx(:,1)==groups),2);
sta_resttime(:,3) = splitapply(@mean,smart_fail_meta.datenum,G);
sta_resttime(:,4) = splitapply(@std,smart_fail_meta.datenum,G);
idx_maxnum = sta_resttime(find(sta_resttime(:,2)==max(sta_resttime(:,2))),1);
%a =sortrows(sta_resttime,4);

%% plot figure1 (mean and std) and figure2 (cdf of mean)
scatter(sta_resttime(:,3),sta_resttime(:,4))
ecdf(smart_fail_meta.datenum(smart_fail_meta.idx==idx_maxnum));    
