function [pre_result, disk_result] = tree_test(smart_tr, smart_ts, training_instance, MaxNumSplits)
%UNTITLED3 此处显示有关此函数的摘要
%   此处显示详细说明

inputTable = smart_tr;
predictors = inputTable(:, training_instance);
response = inputTable.class;
time_start = cputime;
tree_model = fitctree(...
    predictors, ...
    response, ...
    'SplitCriterion', 'gdi', ...
    'MaxNumSplits', MaxNumSplits, ...
    'Surrogate', 'off', ...
    'ClassNames', [0; 1]);
train_time = cputime - time_start;

smarts = smart_ts;
time_start = cputime;
predicted_label = predict(tree_model, smarts(:, training_instance));
test_time = cputime - time_start;
smarts.class_pre = predicted_label;
disk_result = unique(smarts.sn_id);
disk_result(:,2) = disk_result(:,1);
disk_result(:,3) = disk_result(:,1);
disk_result(:,4) = disk_result(:,1);
parfor i = 1:size(disk_result, 1)
    disk = disk_result(i, :);
    smart = smarts(smarts.sn_id == disk(1), {'sn_id', 'class', 'class_pre', 'date'});
    disk(2) = max(smart.class);
    disk(3) = max(smart.class_pre);
    if disk(3) == 1
        smart = smart(smart.class_pre == 1, :);
        disk(4) = max(smart.date);
    else
        disk(4) = 0;
    end
    disk_result(i, :) = disk;
end
disk_result = array2table(disk_result, 'VariableNames', {'sn_id', 'class', 'class_pre', 'lead_time'});
tmp = disk_result(disk_result.class == 1 & disk_result.class_pre == 1, :);
avg_leadtime = mean(tmp.lead_time);
tp = sum(disk_result.class == 1 & disk_result.class_pre == 1);
fdr = tp / sum(disk_result.class == 1);
fp = sum(disk_result.class == 0 & disk_result.class_pre == 1);
far = fp / sum(disk_result.class == 0);
pre_result = {tp, fdr, fp, far, avg_leadtime, tree_model.NumNodes, train_time, test_time};

end

