% Generate RF model with smart1_test

%% Load data
clc;clear;
dir_mydata = '~/Data/OnlineRF/health_degree';
load(strcat(dir_mydata,'smart1.mat'));
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
metaNames = {'id','sn_id','class','health_degree','date','datenum'}; 
smart = smart1_test(:,[metaNames,predictorNames]);

%% Generate Model
inputTable = smart;
predictors = double(inputTable{:, predictorNames});

% value from 0 to 1 as health degree
response_01hd = inputTable.health_degree;
md_rfr_01hd = TreeBagger(100,predictors,response_01hd,'Method','regression');

% datenum as health degree
response_datenum = inputTable.datenum;
md_rfr_datenum = TreeBagger(100,predictors,response_datenum,'Method','regression');

%% Pred
pred_01hd = md_rfr_01hd.predict(predictors);
pred_datenum = md_rfr_datenum.predict(predictors);

%% Result Analysis
result = array2table([inputTable.datenum,pred_01hd,pred_datenum],...
    'VariableNames',{'datenum','pred_01hd','pred_dn'});       

result = sortrows(result,'datenum');
len_res = size(result,1);
result.g01 = zeros(len_res,1);
result.l01 = zeros(len_res,1);
result.gdn = zeros(len_res,1);
result.ldn = zeros(len_res,1);
h = waitbar(0,'Loop Processing');

for i = 1:len_res
    waitbar(i/len_res,h,['Loop Processing: ' num2str(i)]);
    cur_datenum = result.datenum(i);
    cur_pred_01hd = result.pred_01hd(i);
    cur_pred_dn = result.pred_dn(i);
    
    idx_e = find(result.datenum == cur_datenum);
    idx_g = (max(idx_e)+1):len_res;
    idx_l = 1:(min(idx_e-1));
    
    result.g01(i) = sum(result.pred_01hd(idx_g)<cur_pred_01hd);
    result.l01(i) = sum(result.pred_01hd(idx_l)>cur_pred_01hd);
    result.gdn(i) = sum(result.pred_dn(idx_g)<cur_pred_dn);
    result.ldn(i) = sum(result.pred_dn(idx_l)>cur_pred_dn);
end

%% Result Analysis for parallel loop
result = array2table([inputTable.datenum,pred_01hd,pred_datenum],...
    'VariableNames',{'datenum','pred_01hd','pred_dn'});       

result = sortrows(result,'datenum');
len_res = size(result,1);
rd = result.datenum;
rp01 = result.pred_01hd;
rpdn = result.pred_dn;

delete(gcp('nocreate'));
parfor (i=1:len_res,8)
    cur_datenum = rd(i);
    cur_pred_01hd = rp01(i);
    cur_pred_dn = rpdn(i);
    
    idx_e = find(rd == cur_datenum);
    idx_g = (max(idx_e)+1):len_res;
    idx_l = 1:(min(idx_e-1));
    
    g01(i) = sum(rp01(idx_g)<cur_pred_01hd);
    l01(i) = sum(rp01(idx_l)>cur_pred_01hd);
    gdn(i) = sum(rpdn(idx_g)<cur_pred_dn);
    ldn(i) = sum(rpdn(idx_l)>cur_pred_dn);
end
parpool close;

result.g01 = g01';
result.l01 = l01';
result.gdn = gdn';
result.ldn = ldn';










