function [pre_result, disk_result] = svm_test(smart_tr, smart_ts, training_instance, gamma, cost)
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明

svm_option = sprintf('-s 0 -t 2 -g %g -c %g', gamma, cost);
smarts = smart_tr;
time_start = cputime;
model = svmtrain(smarts.class, smarts{:, training_instance}, svm_option);
train_time = cputime - time_start;

smarts = smart_ts;
time_start = cputime;
[predicted_label, accuracy, decision_values] = svmpredict(smarts.class, smarts{:, training_instance}, model);
test_time = cputime - time_start;
smarts.class_pre = predicted_label;
disk_result = unique(smarts.sn_id);
disk_result(:,2) = disk_result(:,1);
disk_result(:,3) = disk_result(:,1);
disk_result(:,4) = disk_result(:,1);
for i = 1:size(disk_result, 1)
    smart = smarts(smarts.sn_id == disk_result(i), {'sn_id', 'class', 'class_pre', 'date'});
    disk_result(i, 2) = max(smart.class);
    disk_result(i, 3) = max(smart.class_pre);
    if disk_result(i, 3) == 1
        smart = smart(smart.class_pre == 1, :);
        disk_result(i, 4) = max(smart.date);
    else
        disk_result(i, 4) = 0;
    end
end
disk_result = array2table(disk_result, 'VariableNames', {'sn_id', 'class', 'class_pre', 'lead_time'});
tmp = disk_result(disk_result.class == 1 & disk_result.class_pre == 1, :);
avg_leadtime = mean(tmp.lead_time);
tp = sum(disk_result.class == 1 & disk_result.class_pre == 1);
fdr = tp / sum(disk_result.class == 1);
fp = sum(disk_result.class == 0 & disk_result.class_pre == 1);
far = fp / sum(disk_result.class == 0);
pre_result = {tp, fdr, fp, far, accuracy(1), avg_leadtime, model.nSV(1), model.nSV(2), train_time, test_time};

end

