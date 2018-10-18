function [result] = svm_dtest(Model, TestData, predictorNames)
model = Model;
test_data = scale_disk1(TestData,2);

% predictorNames = {'smart_5_raw',...
%     'smart_187_raw',...
%     'smart_197_raw',... 
%     'smart_1_normalized',... 
%     'smart_4_raw',... 
%     'smart_7_normalized',...  
%     'smart_9_normalized',...  
%     'smart_12_raw',...  
%     'smart_183_raw',...  
%     'smart_184_raw',...  
%     'smart_189_raw',...  
%     'smart_193_normalized',...  
%     'smart_198_raw',...  
%     'smart_199_raw',...  
%     'smart_3_normalized',...  
%     'smart_5_normalized',...  
%     'smart_7_raw',...  
%     'smart_9_raw',...  
%     'smart_183_normalized',...  
%     'smart_184_normalized',...  
%     'smart_187_normalized',...  
%     'smart_188_normalized',...  
%     'smart_188_raw',...  
%     'smart_189_normalized',...  
%     'smart_192_raw',...  
%     'smart_193_raw',...  
%     'smart_194_raw',...  
%     'smart_197_normalized',...  
%     'smart_198_normalized'};

predictors = test_data{:, predictorNames};
response = test_data.class;

test_data.preclass = svmpredict(response, predictors, model);

disk_result = unique(test_data.sn_id);
disk_result(:,2) = disk_result(:,1);
disk_result(:,3) = disk_result(:,1);
disk_result(:,4) = disk_result(:,1);
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
    disk_result(i, :) = disk;
end
disk_result = array2table(disk_result, 'VariableNames', {'sn_id', 'class', 'preclass', 'lead_time'});
% tmp = disk_result(disk_result.class == 1 & disk_result.class_pre == 1, :);
% avg_leadtime = mean(tmp.lead_time);

tp = sum(disk_result.class >= 1 & disk_result.preclass >= 1);
totalp = sum(disk_result.class >= 1);
fdr = tp / totalp;
fp = sum(disk_result.class == 0 & disk_result.preclass >= 1);
totaln = sum(disk_result.class == 0);
far = fp / totaln;
fn = sum(disk_result.class >= 1 & disk_result.preclass == 0);
test_error = (fn + fp) / size(disk_result, 1);

result = sprintf('testError->%.4f FDR->%d/%d->%.4f, FAR->%d/%d->%.4f',test_error, tp, totalp, fdr, fp, totaln, far);

end