% Generate RF model with smart1_test

%% Load data and generate train SN
clc;clear;
tic
disp('Load data and Generate train SN...');
dir_mydata = '~/Data/OnlineRF/health_degree/';
addpath('../eval_Model/');
addpath('../gen_HD/');
load(strcat(dir_mydata,'smart1.mat'));
smart1T = smart1_dtest(smart1_dtest.class==1,:);    %solutionA: failure prediction is accurate enough so that we only consider replace order of failed ones.

dt_pos = smart1T(smart1T.class==1,:);
uni_disk = unique(dt_pos.sn_id);
len_ud = length(uni_disk);
sn_train = randsample(uni_disk,round(len_ud*0.666));
sta_sn = tabulate(smart1T.sn_id);
toc

%% Generate Health degree
disp('Generate Health degree hddn,hdsc, and hdmd...');
f_sort=0;
days_train = 60;
days_cost = 5;
[hddn,smart1_hd,cost_hddn] = func_add_HD_datenum(smart1T,f_sort,predictorNames,sn_train,days_train,days_cost);
[hdsc,smart1_hd,cost_hdsc] = func_add_HD_SMART_center(smart1_hd,f_sort,predictorNames,sn_train,days_train,days_cost,10,2);
[hdmd,smart1_hd,cost_hdmd] = func_add_HD_mahalanobis_distance(smart1_hd,f_sort,predictorNames,sn_train,unique([0,3,6,11,16,23,30,days_train]),days_cost);
[cost_hddn,cost_hdsc,cost_hdmd]
metaNames = {'id','sn_id','class','date','datenum','hddn','hdsc','hdmd'}; 
toc

%% Generate Model
smart_model = smart1_hd;
trainTable = smart_model(ismember(smart_model.sn_id,sn_train),:);
predictors = double(trainTable{:, predictorNames});

% Build Model: rfr + hddn as response
disp('Build Model: rfr + hddn as response...');
response_hddn = trainTable.hddn;
md_rfr_hddn = TreeBagger(100,predictors,response_hddn,'Method','regression');

% Build Model: rfr + hdsc as response
disp('Build Model: rfr + hdsc as response...');
response_hdsc = trainTable.hdsc;
md_rfr_hdsc = TreeBagger(100,predictors,response_hdsc,'Method','regression');

% Build Model: rfr + hdmd as response
disp('Build Model: rfr + hdmd as response...');
response_hdmd = trainTable.hdmd;
md_rfr_hdmd = TreeBagger(100,predictors,response_hdmd,'Method','regression');
toc

%% Test Model and prepare to evaluate
disp('Test Model and prepare result to evaluate...');
testTable = smart_model(~ismember(smart_model.sn_id,sn_train),:);
pred_hddn = md_rfr_hddn.predict(double(testTable{:,predictorNames}));
pred_hdsc = md_rfr_hdsc.predict(double(testTable{:,predictorNames}));
pred_hdmd = md_rfr_hdmd.predict(double(testTable{:,predictorNames}));
toc

%% Result Evaluation: preprocess
disp('Preprocess predicted result...');
res = testTable;
res.pred_hddn = pred_hddn;
res.pred_hdsc = pred_hdsc;
res.pred_hdmd = pred_hdmd;

predictorNames_res=predictorNames;
metaNames_res = {'id','sn_id','datenum','pred_hddn','pred_hdsc','pred_hdmd'}; 
res = res(:,[metaNames_res,predictorNames_res]);
uni_sn = unique(res.sn_id);
toc

%% Result Evaluation: extract samples of each disk to compare. (repeat for num_random times)
disp('Evaluate predicted result...');
days=5 ;
num_random = 10;
smart_eval = smart_model;

cost_hddn = func_eval_disk_time_order_bydatenum(res,'pred_hddn',days,num_random);
cost_hdsc = func_eval_disk_time_order_bydatenum(res,'pred_hdsc',days,num_random);
cost_hdmd = func_eval_disk_time_order_bydatenum(res,'pred_hdmd',days,num_random);

cost_hddn_train = func_eval_disk_time_order_bydatenum(smart_eval(ismember(smart_eval.sn_id,sn_train) & smart_eval.class==1,:),'hddn',days,num_random);
cost_hdsc_train = func_eval_disk_time_order_bydatenum(smart_eval(ismember(smart_eval.sn_id,sn_train) & smart_eval.class==1,:),'hdsc',days,num_random);
cost_hdmd_train = func_eval_disk_time_order_bydatenum(smart_eval(ismember(smart_eval.sn_id,sn_train) & smart_eval.class==1,:),'hdmd',days,num_random);

r = [cost_hddn,cost_hdsc,cost_hdmd;cost_hddn_train,cost_hdsc_train,cost_hdmd_train];
r = array2table(r);
r.Properties.VariableNames = {'hddn','hdsc','hdmd'};
r.Properties.RowNames = {'Test','Train'};
r

toc

%% Result Evaluation: global time order by quantile
% cost_hdsc = func_eval_global_time_order_byquantile(res,'pred_hdsc');
% cost_hddn = func_eval_global_time_order_byquantile(res,'pred_hddn');
% cost_all = array2table([(1:100)',cost_hdsc',cost_hddn'],'VariableNames',{'quantile','cost_hdsc','cost_hddn'});
% plot(cost_all.quantile,cost_all.cost_hdsc);hold on;
% plot(cost_all.quantile,cost_all.cost_hddn);hold off;
% [mean(cost_hdsc),mean(cost_hdsc(1:5));
% mean(cost_hddn),mean(cost_hddn(1:5))]

%% Result Evaluation: global time order by days
% array_cutdays = [3 6 11 16 23 30];
% 
% cost_hdsc = func_eval_global_time_order_bydatenum(res,'pred_hdsc',array_cutdays);
% cost_hddn = func_eval_global_time_order_bydatenum(res,'pred_hddn',array_cutdays);
% cost_all = array2table([[array_cutdays,max(res.datenum)]',cost_hdsc',cost_hddn'],'VariableNames',{'days','cost_hdsc','cost_hddn'});
% idx = 1:(length(cost_all.days)-1);
% plot(cost_all.days(idx),cost_all.cost_hdsc(idx));hold on;
% plot(cost_all.days(idx),cost_all.cost_hddn(idx));hold off;
% [mean(cost_hdsc(idx)),mean(cost_hdsc(1:3));
% mean(cost_hddn(idx)),mean(cost_hddn(1:3))]


%% Result Evaluation: observe one disk (hddn v.s. dn)
% a = res(res.sn_id==uni_sn(56),:);
% plot(a.datenum,a.pred_hdsc);hold on;
% plot(a.datenum,(1-a.pred_hddn)*300);hold off

%% Result Evaluation: comparing 4 disks randomly for their datenum and predicted hddn
% uni_sn1 = uni_sn(round(rand*length(uni_sn)));
% uni_sn2 = uni_sn(round(rand*length(uni_sn)));
% uni_sn3 = uni_sn(round(rand*length(uni_sn)));
% uni_sn4 = uni_sn(round(rand*length(uni_sn)));
% 
% b1 = res(res.sn_id == uni_sn1,:);
% b2 = res(res.sn_id == uni_sn2,:);
% b3 = res(res.sn_id == uni_sn3,:);
% b4 = res(res.sn_id == uni_sn4,:);
% 
% plot(b1.datenum,(1-b1.pred_hddn));hold on;
% plot(b2.datenum,(1-b2.pred_hddn));hold on;
% plot(b3.datenum,(1-b3.pred_hddn));hold on;
% plot(b4.datenum,(1-b4.pred_hddn));hold off

%% Result Evaluation: plot distribution of predicted HD for all samples
% tic
% idx = ismember(res.datenum,1:10:max(res.datenum));
% boxplot(1-res.pred_hddn(idx),res.datenum(idx))
% 
% [G,groups] = findgroups(res.datenum);
% res_eval = [groups,...
%     splitapply(@mean,res.pred_hddn,G),...
%     splitapply(@std,res.pred_hddn,G)];
% res_eval = array2table(res_eval,'VariableNames',{'datenum','mean_pred','std_pred'});
% res_eval.cv = res_eval.std_pred./res_eval.mean_pred;
% cv60_mean = mean(res_eval.cv(res_eval.datenum<=60));
% toc

%% Result Analysis for parallel loop (sample v.s. sample)
% result = array2table([trainTable.datenum,pred_hddn,pred_datenum],...
%     'VariableNames',{'datenum','pred_hddn','pred_dn'});       
% 
% result = sortrows(result,'datenum');
% len_res = size(result,1);
% rd = result.datenum;
% rp01 = result.pred_hddn;
% rpdn = result.pred_dn;
% 
% delete(gcp('nocreate'));
% tic
% parpool(24)
% parfor (i=1:len_res,24)
%     cur_datenum = rd(i);
%     cur_pred_hddn = rp01(i);
%     cur_pred_dn = rpdn(i);
%     
%     idx_e = find(rd == cur_datenum);
%     idx_g = (max(idx_e)+1):len_res;
%     idx_l = 1:(min(idx_e-1));
%     
%     g01(i) = sum(rp01(idx_g)<cur_pred_hddn);
%     l01(i) = sum(rp01(idx_l)>cur_pred_hddn);
%     gdn(i) = sum(rpdn(idx_g)<cur_pred_dn);
%     ldn(i) = sum(rpdn(idx_l)>cur_pred_dn);
% end
% delete(gcp('nocreate'));
% toc
% 
% result.e01 = (g01'+l01')/len_res;
% result.edn = (gdn'+ldn')/len_res;
% error_hddn = mean(result.e01)/len_res;
% error_gdn = mean(result.edn)/len_res;
% 
%% Result Analysis for parallel loop (sample v.s. disk)
% result = array2table([trainTable.datenum,pred_hddn,pred_datenum],...
%     'VariableNames',{'datenum','pred_hddn','pred_dn'});       
% 
% result = sortrows(result,'datenum');
% len_res = size(result,1);
% rd = result.datenum;
% rp01 = result.pred_hddn;
% rpdn = result.pred_dn;
% [G,groups] = findgroups(trainTable.sn_id);
% fun_sample_error = @(x)[sum(x(x~=-1))/length(x(x~=-1))];
% 
% delete(gcp('nocreate'));
% parpool(24)
% tic
% parfor (i=1:len_res,24)
% % for (i=1:100)
%     disp(i);
%     cur_datenum = rd(i);
%     cur_pred_hddn = rp01(i);
%     cur_pred_dn = rpdn(i);
%     
%     idx_e = find(rd == cur_datenum);
%     idx_g = (max(idx_e)+1):len_res;
%     idx_l = 1:(min(idx_e-1));
%     
%     sample_eval_hddn = zeros(len_res,1);
%     sample_eval_hddn(idx_e) = -1;
%     sample_eval_hddn(rp01(idx_g)<cur_pred_hddn) = 1;
%     sample_eval_hddn(rp01(idx_l)>cur_pred_hddn) = 1;
%     r_hddn = splitapply(fun_sample_error,sample_eval_hddn,G);
%  
%     sample_eval_dn = zeros(len_res,1);
%     sample_eval_dn(idx_e) = -1;
%     sample_eval_dn(rpdn(idx_g)<cur_pred_dn) = 1;
%     sample_eval_dn(rpdn(idx_l)>cur_pred_dn) = 1;
%     r_dn = splitapply(fun_sample_error,sample_eval_dn,G);
%     
%     e01(i) = mean(r_hddn);
%     edn(i) = mean(r_dn);
%     
% end
% toc
% delete(gcp('nocreate'));
% 
% result.e01 = e01';
% result.edn = edn';
% error_hddn = mean(result.e01,'omitnan');
% error_gdn = mean(result.edn,'omitnan');
% 
%% Error analysis
% 
% [G,groups] = findgroups(result.datenum);
% error_datenum_hddn = splitapply(@mean,(result.e01),G);
% error_datenum_dn = splitapply(@mean,result.edn,G);
% error_datenum = array2table([groups,error_datenum_hddn,error_datenum_dn],...
%     'VariableNames',{'datenum','hddn','dn'});
% 
% plot(error_datenum.datenum,error_datenum.hddn)
% hold on
% plot(error_datenum.datenum,error_datenum.dn)
% hold off