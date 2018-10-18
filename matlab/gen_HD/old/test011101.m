
start_date = min(smart2_train.date);
result2_1 = cell(20,3);
for i = 1:20
    for i_d = 1:size(disk2_train, 1)
        disk = disk2_train(i_d, :);
        smarts = disk.smarts{1};
        smarts = smarts(smarts.date < (start_date + 30*i), :);
        class = double(disk.class(1));
        sn_id = double(disk.sn_id(1));
        if class == 1 && disk.numOfNegPreclass == 0
            smart = smarts(smarts.datenum <= 7, :);
        end
        if class == 1 && disk.numOfNegPreclass > 0
            smart = smarts(smarts.datenum <= 2, :);
        end
        if class == 0 && disk.numOfNegPreclass == 5
            if size(smarts, 1) >= 4
                ind = randperm(size(smarts, 1));
                smart = smarts(ind(1:4), :);
            else
                smart = smarts;
            end
        end
        if class == 0 && disk.numOfNegPreclass < 5
            if size(smarts, 1) >= 3
                ind = randperm(size(smarts, 1));
                smart = smarts(ind(1:3), :);
            else
                smart = smarts;
            end
        end
        smart.class = linspace(class,class,size(smart, 1))';
        smart.sn_id = linspace(sn_id,sn_id,size(smart, 1))';
        if i_d == 1
            smart_train = smart;
        else
            smart_train = [smart_train; smart];
        end
    end
    smart_train = sortrows(smart_train, 'date','ascend');
    smart_train(:, 34:52) = []; smart_train = scale_data(smart_train, 1);
    model = rf_train(smart_train, 0.01);
    result2_1{i,1} = rf_dtest(model, smart2_dtest);
    result2_1{i,2} = sum(smart_train.class == 1);
    result2_1{i,3} = sum(smart_train.class == 0);
    result2_1{i,4} = smart_train;
    result2_1{i,5} = model;
    fprintf('%d\n', i);
end
result2_1 = cell2table(result2_1, 'VariableNames', {'preResultOnSmart2dtest', 'numOfPosSample', 'numOfNegSample', 'trainingSet', 'model'});

