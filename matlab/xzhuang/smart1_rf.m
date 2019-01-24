%% load
%load smart1_all_1.mat
%load numSamples1.mat
%load smart1.mat
clear;clc
run smart1_load.m
load('/home/xzhuang/Data/xzData20180711/mat/numSamples.mat')

predictorNames = {'smart_5_raw',...
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

npRadios = [3 5 8 10];
numOfMonth = [1,2,5,10,15,19];
numofMonth = 1:19;
start_date = min(smart1_train.date);
result = cell(19,length(npRadios),5);

%% model and pred
for i = numofMonth
    
    test_start = numSamples.numOfSmart1All(i) + 1;
    test_end   = numSamples.numOfSmart1All(i+1);
    smart_test = smart1_all(test_start:test_end, :);
    
    smart_test = scale_data(smart1_test, 1);
    
    train_start = 1;
    train_end = numSamples.numOfSmart1Train(i);
    smart_train = smart1_train(train_start:train_end, :);
    smart_train = scale_data(smart_train, 1);
    smart_pos = smart_train(smart_train.class == 1, :);
    smart_neg = smart_train(smart_train.class == 0, :);

    for j = 1:length(npRadios)
        npRadio = npRadios(j);
        ind = randperm(size(smart_neg, 1));
        smart_neg_p = smart_neg(ind(1:size(smart_pos, 1)*npRadio), :);
        smart_train = [smart_neg_p; smart_pos];
        smart_train = sortrows(smart_train, 'date', 'ascend');
        
        model = rf_train(smart_train, 0.01, predictorNames);
        result{i,j,1} = rf_test(model, smart_test, predictorNames);
        result{i,j,2} = sum(smart_train.class == 1);
        result{i,j,3} = sum(smart_train.class == 0);
        result{i,j,4} = i;
        result{i,j,5} = model;
        str_result = result{i,j,1};
        fprintf('numOfMonth used: %d\tnpRatio: %d\tresult: %s\n', i, npRadio,str_result);
    end
end

% result{1,:}
%result2_6_5 = cell2table(result, 'VariableNames', {'offlineRF_preResultOnSmart2All_eachMonth', 'numOfPosSample', 'numOfNegSample', 'numOfMonth', 'offlineRFModel'});
%result2_6_5A = cell2table(result, 'VariableNames', {'offlineRF_preResultOnSmart2All_eachMonth', 'numOfPosSample', 'numOfNegSample', 'numOfMonth'});
%save result2_6_5.mat result2_6_5 
