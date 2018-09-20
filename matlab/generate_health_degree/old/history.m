start_date = min(smart_train.date);
k=1;
npRadio = 8;
pWeight = 0.1;
for i = 12:20
    smart_pos_p = smart_pos(smart_pos.date < (start_date + 30*i), :);
    smart_neg_p = smart_neg(smart_neg.date < (start_date + 30*i), :);
    for j = 1:5
        ind = randperm(size(smart_neg_p, 1));
        an = min(size(smart_pos_p, 1)*npRadio, size(smart_neg_p, 1));
        smart_neg_pp = smart_neg_p(ind(1:an), :);
        smart_train = [smart_neg_pp; smart_pos_p];
        smart_train = sortrows(smart_train, 'date', 'ascend');
        smart_train.weights = smart_train.class;
        smart_train.weights(smart_train.class==0) = 1;
        smart_train.weights(smart_train.class==1) = pWeight;
        
        model = dt_train(smart_train, 100, predictorNames);
        an = rf_dtest(model, smart_dtest, predictorNames)
        result2_3_dt_2{k,1} = an;
        result2_3_dt_2{k,2} = sum(smart_train.class == 1);
        result2_3_dt_2{k,3} = npRadio;
        result2_3_dt_2{k,4} = pWeight;
        result2_3_dt_2{k,5} = i;
        k = k+1;
        fprintf('numOfMonth = %d, %dth try\n', i, j);
    end
end
result2_3_dt_2 = cell2table(result2_3_dt_2, 'VariableNames', {'DT_preResultOnSmart1dtest', 'numOfPosSample', 'npRadio', 'pWeight', 'numOfMonth'});
save result2_3_dt_2.mat result2_3_dt_2
clear
load smart2_train_all.mat
load smart2_dtest.mat
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
smart_dtest = smart2_dtest;
smart_dtest = scale_data(smart_dtest, 1);
smart_train = smart2_train_all;
smart_train = scale_data(smart_train, 1);
smart_pos = smart_train(smart_train.class == 1, :);
smart_neg = smart_train(smart_train.class == 0, :);
start_date = min(smart_train.date);
k=1;
npRadio = 100;
pWeight = 0.01;
for i = 1:7
    smart_pos_p = smart_pos(smart_pos.date < (start_date + 30*i), :);
    smart_neg_p = smart_neg(smart_neg.date < (start_date + 30*i), :);
    for j = 1:5
        ind = randperm(size(smart_neg_p, 1));
        an = min(size(smart_pos_p, 1)*npRadio, size(smart_neg_p, 1));
        smart_neg_pp = smart_neg_p(ind(1:an), :);
        smart_train = [smart_neg_pp; smart_pos_p];
        smart_train = sortrows(smart_train, 'date', 'ascend');
        smart_train.weights = smart_train.class;
        smart_train.weights(smart_train.class==0) = 1;
        smart_train.weights(smart_train.class==1) = pWeight;
        
        model = dt_train(smart_train, 100, predictorNames);
        an = rf_dtest(model, smart_dtest, predictorNames)
        result2_3_dt_3{k,1} = an;
        result2_3_dt_3{k,2} = sum(smart_train.class == 1);
        result2_3_dt_3{k,3} = npRadio;
        result2_3_dt_3{k,4} = pWeight;
        result2_3_dt_3{k,5} = i;
        k = k+1;
        fprintf('numOfMonth = %d, %dth try\n', i, j);
    end
end
result2_3_dt_3 = cell2table(result2_3_dt_3, 'VariableNames', {'DT_preResultOnSmart1dtest', 'numOfPosSample', 'npRadio', 'pWeight', 'numOfMonth'});
save result2_3_dt_3.mat result2_3_dt_3
exit
%%-- 07/05/2018 09:47:38 AM --%%
exit
%%-- 07/05/2018 10:06:39 AM --%%
exit
%%-- 07/05/2018 10:07:12 AM --%%
exit
%%-- 07/05/2018 10:55:24 AM --%%
exit
%%-- 07/05/2018 11:49:07 AM --%%
load('tmp1.mat')
ls
who
disp(pre_r1)
q
exit
