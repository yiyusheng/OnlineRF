function [result test_data disk_result] = rf_dtest(Model, TestData, predictorNames)
model = Model;
test_data = TestData;

if isstruct(model)
    test_data.preclass = model.predictFcn(test_data);
else
    test_data.preclass = predict(model, test_data{:, predictorNames});
end

disk_result = unique(test_data.sn_id);
disk_result(:,2) = disk_result(:,1);
disk_result(:,3) = disk_result(:,1);
disk_result(:,4) = disk_result(:,1);
disk_result(:,5) = disk_result(:,1);

for i = 1:size(disk_result, 1)
    disk = disk_result(i, :);
    smart = test_data(test_data.sn_id == disk(1), {'sn_id', 'class', 'preclass', 'datenum'});
    disk(2) = sum(smart.class);
    disk(3) = sum(smart.preclass);
    if disk(3) >= 1
        smart = smart(smart.preclass == 1, :);
        disk(4) = max(smart.datenum);
    else
        disk(4) = 0;
    end
    disk(5) = size(smart,1);
    disk_result(i, :) = disk;
end
disk_result = array2table(disk_result, 'VariableNames', {'sn_id', 'class', 'preclass', 'lead_time','count'});

tp = sum(disk_result.class >= 1 & disk_result.preclass >= 1);
totalp = sum(disk_result.class >= 1);
fdr = tp / totalp;
fp = sum(disk_result.class == 0 & disk_result.preclass >= 1);
totaln = sum(disk_result.class == 0);
far = fp / totaln;
fn = sum(disk_result.class >= 1 & disk_result.preclass == 0);
test_error = (fn + fp) / size(disk_result, 1);

result = sprintf('testError->%.4f FDR->%d/%d->%.4f, FAR->%d/%d->%.4f',test_error, tp, totalp, fdr, fp, totaln, far);
test_data = test_data(:,{'sn_id','datenum','class','preclass'});

end