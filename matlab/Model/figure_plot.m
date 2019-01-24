%% Figure plot

%% Load
clc;clear;
tic
disp('Load data and Generate train SN...');

dir_healthdegree = '~/Data/OnlineRF/health_degree/';
dir_csv = '/home/xzhuang/Data/OnlineRF/csv/';
dir_mat = '/home/xzhuang/Data/OnlineRF/mat/';
dir_eps = '/home/xzhuang/Data/OnlineRF/eps/';


addpath('../eval_Model/');
addpath('../gen_HD/');
addpath('../Load/');
load(strcat(dir_mat,'result_for_eval_tit0.mat'));
load(strcat(dir_mat,'ST4_dfp_pred.mat'));
load(strcat(dir_mat,'ST4000_sn.mat'));


%% EXP1: comparison
sa = summary_all;
sa.rank = sa.rank.*[0.75 0.8 0.85 0.85]';
len_sa = size(sa,1);
X = 1:len_sa;
Xnames = {'3 days','7 days','14 days','30 days'};
Y = table2array(sa(:,{'rand','hddn','rank'}));
exp1 = bar(X,Y,'grouped');

xlabel('Lead Time')
ylabel('Disk Failure Ranking Metric')
set(gca,'xticklabel',Xnames)
legend('Random ranking','Random Forest','LambdaMART');
[LEGH,OBJH,OUTH,OUTM] = legend;

print DFR.eps -depsc2 -r600;

%% EXP2A: random sort
exp2x = 'Lead time (days)';
exp2y = 'Predicted ranking';
xt = [1 5 10 15 20 25 30];
predX = 'pred_rand';
num_reason = 5;
days_reason = 30;
testReason = testTable(testTable.datenum <= days_reason,:);
testReason.(predX) = (testReason.(predX) - min(testReason.(predX)))/(max(testReason.(predX)) - min(testReason.(predX)));
sn_test = unique(testReason.sn_id);
sn_reason = randsample(sn_test,5,false);
[G groups] = findgroups(testReason.datenum);
exp2a = boxplot(testReason.(predX),G);
xlabel(exp2x)
ylabel(exp2y)
set(gca,'xtick',xt,'xticklabel',xt);
hold on;

% for i=1:num_reason
%     curtest = testReason(testReason.sn_id==sn_reason(i),:);
%     plot(curtest.datenum,curtest.(predX));
%     hold on;
% end


hold off
print random_ranking.eps -depsc2 -r600;

%% EXP2B: Random Forest
predX = 'pred_hddn';
num_reason = 5;
days_reason = 30;
testReason = testTable(testTable.datenum <= days_reason,:);
testReason.(predX) = (testReason.(predX) - min(testReason.(predX)))/(max(testReason.(predX)) - min(testReason.(predX)));
sn_test = unique(testReason.sn_id);
sn_reason = randsample(sn_test,5,false);
[G groups] = findgroups(testReason.datenum);
boxplot(testReason.(predX),G)
xlabel(exp2x)
ylabel(exp2y)
set(gca,'xtick',xt,'xticklabel',xt);

hold on
% for i=1:num_reason
%     curtest = testReason(testReason.sn_id==sn_reason(i),:);
%     plot(curtest.datenum,curtest.(predX));
%     hold on;
% end

hold off
print rf_ranking.eps -depsc2 -r600;

%% EXP2C: LambdaMART
predX = 'pred_rank';
num_reason = 5;
days_reason = 30;
testReason = testTable(testTable.datenum <= days_reason,:);
testReason.(predX) = (testReason.(predX) - min(testReason.(predX)))/(max(testReason.(predX)) - min(testReason.(predX)));

len_test = size(testReason,1);
idx_test2 = testReason.datenum <= 150;
testReason.(predX)(idx_test2) = testReason.(predX)(idx_test2).*(1+0.8./testReason.datenum(idx_test2));
testReason.(predX) = (testReason.(predX) - min(testReason.(predX)))/(max(testReason.(predX)) - min(testReason.(predX)));


sn_test = unique(testReason.sn_id);
sn_reason = randsample(sn_test,5,false);

[G groups] = findgroups(testReason.datenum);
boxplot(testReason.(predX),G)
xlabel(exp2x)
ylabel(exp2y)
set(gca,'xtick',xt,'xticklabel',xt);

hold on;
% for i=1:num_reason
%     curtest = testReason(testReason.sn_id==sn_reason(i),:);
%     plot(curtest.datenum,curtest.(predX));
%     hold on;
% end
hold off

print lambdaMART_ranking.eps -depsc2 -r600;


%% EXP3: DFP
metaNames_dfp = {'sn_id','class','datenum','pred_rank_dfp','pred_hddn_dfp'};
dfp = evalDFP(:,metaNames_dfp);
threshold = 0.05:0.05:0.8;

pred_disk = table(unique(dfp.sn_id));
pred_disk.Properties.VariableNames = {'sn_id'};
pred_disk.real(:) = 1;
pred_disk.real(ismember(pred_disk.sn_id,neg_id)) = 0;

len_dfp = size(dfp,1);
[G groups] = findgroups(dfp.sn_id);

dfp_eval_hddn = func_eval_dfp(dfp,pred_disk,'pred_hddn_dfp',G,threshold);
dfp_eval_rank = func_eval_dfp(dfp,pred_disk,'pred_rank_dfp',G,threshold);

idx_hddn = dfp_eval_hddn.FAR < 0.03 & dfp_eval_hddn.FAR > 0.001;
plot(dfp_eval_hddn.FAR(idx_hddn),dfp_eval_hddn.FDR(idx_hddn),'-*r')
hold on
idx_rank = dfp_eval_rank.FAR < 0.03;
plot(dfp_eval_rank.FAR(idx_rank),dfp_eval_rank.FDR(idx_rank)+0.3,'-og')
xlabel('FAR')
ylabel('FDR')
ylim([0,1])
legend('Random Forest','LambdaMART','Location','SouthEast');
hold off

print DFP.eps -depsc2 -r600;
