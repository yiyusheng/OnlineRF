% Generate RF model with smart1_test

%% Load data
clc;clear;
dir_mydata = '~/Data/OnlineRF/health_degree/';
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
smart = smart(smart.class==1,:);    %solutionA: failure prediction is accurate enough so that we only consider replace order of failed ones.

%% Generate Model and Pred
tic
inputTable = smart;
predictors = double(inputTable{:, predictorNames});

% value from 0 to 1 as health degree
response_01hd = inputTable.health_degree;
md_rfr_01hd = TreeBagger(100,predictors,response_01hd,'Method','regression');

% datenum as health degree
response_datenum = inputTable.datenum;
md_rfr_datenum = TreeBagger(100,predictors,response_datenum,'Method','regression');

pred_01hd = md_rfr_01hd.predict(predictors);
pred_datenum = md_rfr_datenum.predict(predictors);
toc

%% Result Analysis for parallel loop (sample v.s. sample)
result = array2table([inputTable.datenum,pred_01hd,pred_datenum],...
    'VariableNames',{'datenum','pred_01hd','pred_dn'});       

result = sortrows(result,'datenum');
len_res = size(result,1);
rd = result.datenum;
rp01 = result.pred_01hd;
rpdn = result.pred_dn;

delete(gcp('nocreate'));
tic
parpool(24)
parfor (i=1:len_res,24)
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
delete(gcp('nocreate'));
toc

result.e01 = (g01'+l01')/len_res;
result.edn = (gdn'+ldn')/len_res;
error_hd01 = mean(result.e01)/len_res;
error_gdn = mean(result.edn)/len_res;
%% Result Analysis for parallel loop (sample v.s. disk)
result = array2table([inputTable.datenum,pred_01hd,pred_datenum],...
    'VariableNames',{'datenum','pred_01hd','pred_dn'});       

result = sortrows(result,'datenum');
len_res = size(result,1);
rd = result.datenum;
rp01 = result.pred_01hd;
rpdn = result.pred_dn;
[G,groups] = findgroups(inputTable.sn_id);
fun_sample_error = @(x)[sum(x(x~=-1))/length(x(x~=-1))];

delete(gcp('nocreate'));
parpool(24)
tic
parfor (i=1:len_res,24)
% for (i=1:100)
    disp(i);
    cur_datenum = rd(i);
    cur_pred_01hd = rp01(i);
    cur_pred_dn = rpdn(i);
    
    idx_e = find(rd == cur_datenum);
    idx_g = (max(idx_e)+1):len_res;
    idx_l = 1:(min(idx_e-1));
    
    sample_eval_hd01 = zeros(len_res,1);
    sample_eval_hd01(idx_e) = -1;
    sample_eval_hd01(rp01(idx_g)<cur_pred_01hd) = 1;
    sample_eval_hd01(rp01(idx_l)>cur_pred_01hd) = 1;
    r_hd01 = splitapply(fun_sample_error,sample_eval_hd01,G);
 
    sample_eval_dn = zeros(len_res,1);
    sample_eval_dn(idx_e) = -1;
    sample_eval_dn(rpdn(idx_g)<cur_pred_dn) = 1;
    sample_eval_dn(rpdn(idx_l)>cur_pred_dn) = 1;
    r_dn = splitapply(fun_sample_error,sample_eval_dn,G);
    
    e01(i) = mean(r_hd01);
    edn(i) = mean(r_dn);
    
end
toc
delete(gcp('nocreate'));

result.e01 = e01';
result.edn = edn';
error_hd01 = mean(result.e01,'omitnan');
error_gdn = mean(result.edn,'omitnan');

%% Error analysis

[G,groups] = findgroups(result.datenum);
error_datenum_hd01 = splitapply(@mean,(result.e01),G);
error_datenum_dn = splitapply(@mean,result.edn,G);
error_datenum = array2table([groups,error_datenum_hd01,error_datenum_dn],...
    'VariableNames',{'datenum','hd01','dn'});

plot(error_datenum.datenum,error_datenum.hd01)
hold on
plot(error_datenum.datenum,error_datenum.dn)
hold off