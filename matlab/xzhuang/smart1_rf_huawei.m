% Use xz's model to predict huawei data

%% load
clear;clc
run smart1_load.m
load('/home/xzhuang/Data/xzData20180711/mat/numSamples.mat')
DT_hw = readtable('/home/xzhuang/Data/Huawei/DT_hw_matched.csv');

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

npRadios = [3 5 8 10 15 20];
numOfMonth = [1,2,5,10,15,19];
numofMonth = 1:19;
start_date = min(smart1_train.date);
result = cell(19,length(npRadios),5);

%% load huawei data and preprocessing
DT_hw_test = DT_hw;
DT_hw_test.preclass = zeros(size(DT_hw_test,1),1);
DT_hw_test.healthFactor = ones(size(DT_hw_test,1),1);
DT_hw_test.health_degree = 1./DT_hw_test.datenum;
DT_hw_test.id = (1:size(DT_hw_test,1))';

sn_pos = DT_hw_test.sn(DT_hw_test.failure==1);
DT_hw_test.class = zeros(size(DT_hw_test,1),1);
DT_hw_test.class(ismember(DT_hw_test.sn,sn_pos)) =1;

sta_sn = cell2table(tabulate(DT_hw_test.sn));
sta_sn.sn_id = (1:size(sta_sn,1))'+10000;
sta_sn.Properties.VariableNames={'sn','X1','X2','sn_id'};
DT_hw_test = join(DT_hw_test,sta_sn(:,{'sn','sn_id'}));
DT_hw_test = DT_hw_test(:,smart1_test.Properties.VariableNames);

%% Generate train and test
i=19;j=6;

%prepare train
smart_train = scale_data(smart1_train, 1);
smart_pos = smart_train(smart_train.class == 1, :);
smart_neg = smart_train(smart_train.class == 0, :);

npRadio = npRadios(j);
ind = randperm(size(smart_neg, 1));
smart_neg_p = smart_neg(ind(1:size(smart_pos, 1)*npRadio), :);
smart_train = [smart_neg_p; smart_pos];
smart_train = sortrows(smart_train, 'date', 'ascend');

%prepare test
st = smart1_test;
smart_test = st(st.class==0 | (st.class==1 & st.datenum < 20),:);
smart_test = scale_data(smart_test, 1);

st = DT_hw_test;
smart_test_hw = st(st.class==0 | (st.class==1 & st.datenum < 20),:);
smart_test_hw = scale_data(smart_test_hw, 1);

%% model and test
model = rf_train(smart_train, 0.01, predictorNames);
[str_result,test_data,disk_result] = rf_test(model, smart_test_hw, predictorNames);
fprintf('numOfMonth used: %d\tnpRatio: %d\tresult: %s\n', i, npRadio,str_result);

error_data = disk_result(xor(disk_result.class,disk_result.preclass),:);
test_data_error = test_data(ismember(test_data.sn_id,error_data.sn_id),:);



