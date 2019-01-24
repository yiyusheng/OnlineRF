% Select better attributes for order and generate highly related features

%% Load data and generate train SN
clc;clear;
tic
disp('Load data and Generate train SN...');
dir_hd = '~/Data/OnlineRF/health_degree/';
dir_csv = '~/Data/OnlineRF/csv/';
dir_mat = '~/Data/OnlineRF/mat/';
addpath('../eval_Model/');
addpath('../gen_HD/');


load(strcat(dir_hd,'smart1.mat'));
load(strcat(dir_mat,'ST4000_pos.mat'));
load(strcat(dir_mat,'names.mat'));

smart = smart_ST4000_pos;
smart.failure = ones(size(smart,1),1);
smart_array = table2array(smart(:,predictorNames));
smart = smart(all(smart_array~=-1,2),:);
smart.dn1 = func_gen_tia_groups(smart.datenum,1,200);
smart.dn3 = func_gen_tia_groups(smart.datenum,3,200);
smart.dn5 = func_gen_tia_groups(smart.datenum,5,200);
smart.dn10 = func_gen_tia_groups(smart.datenum,10,200);
toc

%% Visualize difference of distribution between groups
attrX = predictorNames{14};
dnX = 'dn10';
days_window = unique(smart_dist.(dnX));

for i = 1:length(days_window)
    [h stats] = cdfplot(log10(smart.(attrX)(smart.(dnX)==days_window(i))));
    hold on
end
legend(string(days_window))
hold off

cdfplot(log10(smart.(attrX)))

histogram(smart.(attrX))
set(gca,'yscale','log')
set(gca,'xscale','log')

%% Evaluate difference of distribution between groups
tic
smart_dist = smart;
dnX = 'dn10';

days_window = unique(smart_dist.(dnX));
len_days = length(days_window)-1;

len_prednames = length(predictorNames);
eval_diff_dist = cell(len_prednames,1);
eval_diff_dist_attr = zeros(len_prednames,1);

for i=1:len_prednames
    mtx = zeros(len_days,len_days);
    for j=1:len_days
        x1 = double(smart_dist.(predictorNames{i})(smart_dist.dn10==days_window(j)));
        for k=1:len_days
            x2= double(smart_dist.(predictorNames{i})(smart_dist.dn10==days_window(k)));
            mtx(j,k) = kstest2(x1,x2);
        end
    end
    eval_diff_dist{i} = mtx;
    eval_diff_dist_attr(i) = sum(sum(mtx));
    toc
end

%% plot heatmap for predictorNames_14
mtx = array2table(eval_diff_dist{3}*(-1)+1);
len_mtx = size(mtx,1);
mtx.row = [1:len_mtx]';
mtx_melt = stack(mtx,1:len_mtx);
mtx_melt.Properties.VariableNames={'days_levelA','days_levelB','similarity'};
mtx_melt.days_levelB = double(strrep(mtx_melt.days_levelB,'Var',''));
mtx_melt.similarity(mtx_melt.days_levelA==mtx_melt.days_levelB)=2;
h=heatmap(mtx_melt,'days_levelA','days_levelB','ColorVariable','similarity');

%% check key attributes
metaNames = {'sn','date','failure','datenum'};
idx_pnames = [2 4 8 14 15 21 24];
days_check = 100;
dnX = 'dn1';
idx=2;

smart_check = smart(smart.datenum<days_check,[metaNames,dnX,predictorNames(idx_pnames)]);

attr_unstack = unstack(smart_check(:,{'sn',dnX,predictorNames{idx}}),predictorNames{idx},dnX,'AggregationFunction',@mean);
attr_unstack = sortrows(attr_unstack,attr_unstack.Properties.VariableNames(2:3));

idx_missing = ismissing(attr_unstack(:,2:end));
attr_unstack{:,2:end}(idx_missing) = -1;

attr_stack = stack(attr_unstack(1900:2000,:),2:size(attr_unstack,2));
attr_stack.Properties.VariableNames={'sn','days','value'};
attr_stack.days = double(strrep(attr_stack.days,'x',''));
attr_stack.value = log10(attr_stack.value+2);

h = heatmap(attr_stack,'days','sn','ColorVariable','value');

%% check obvious disks
metaNames = {'sn','date','failure','datenum'};
idx_pnames = [2 4 8 14 15 21 24];
days_check = 200;
dnX = 'dn1';
idx=14;

smart_check = smart(smart.datenum<days_check,[metaNames,dnX,predictorNames(idx_pnames)]);

attr_unstack = unstack(smart_check(:,{'sn',dnX,predictorNames{idx}}),predictorNames{idx},dnX,'AggregationFunction',@mean);
attr_unstack = sortrows(attr_unstack,attr_unstack.Properties.VariableNames(2:3));

idx_missing = ismissing(attr_unstack(:,2:end));
attr_unstack{:,2:end}(idx_missing) = -1;

attr_unstack_obvious_disks = attr_unstack(attr_unstack{:,end}>0,:);
len_obvious_disks = size(attr_unstack_obvious_disks,1);
idx_disk = len_obvious_disks-10:len_obvious_disks-8;

x_days = (size(attr_unstack_obvious_disks,2)-1):-1:1;
for i=1:length(idx_disk)
    h=plot(x_days',log2(attr_unstack_obvious_disks{idx_disk(i),2:end}'));
    hold on
end
hold off


