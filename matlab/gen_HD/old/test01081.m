load disk_model1.mat

[smart1_train_1, ~, ~] = select_TrTsSmart(disk_model1, 7, 1, 3);
smart1_train_1(:, 34:52) = []; smart1_train_1 = scale_data(smart1_train_1, 1);
model1 = rf_train(smart1_train_1); fprintf('model1 trained\n');
[a, b] = model_test(model1, disk_model1); fprintf('model1 tested\n');
disk_model1.preclass1 = b;
result = {a};

[smart1_train_2, ~, ~] = select_TrTsSmart(disk_model1, 7, 1, 3);
smart1_train_2(:, 34:52) = []; smart1_train_2 = scale_data(smart1_train_2, 1);
model2 = rf_train(smart1_train_2); fprintf('model2 trained\n');
[a, b] = model_test(model2, disk_model1); fprintf('model2 tested\n');
disk_model1.preclass2 = b;
result{2,1} = a;

[smart1_train_3, ~, ~] = select_TrTsSmart(disk_model1, 7, 1, 3);
smart1_train_3(:, 34:52) = []; smart1_train_3 = scale_data(smart1_train_3, 1);
model3 = rf_train(smart1_train_3); fprintf('model3 trained\n');
[a, b] = model_test(model3, disk_model1); fprintf('model3 tested\n');
disk_model1.preclass3 = b;
result{3,1} = a;

[smart1_train_4, ~, ~] = select_TrTsSmart(disk_model1, 7, 1, 3);
smart1_train_4(:, 34:52) = []; smart1_train_4 = scale_data(smart1_train_4, 1);
model4 = rf_train(smart1_train_4); fprintf('model4 trained\n');
[a, b] = model_test(model4, disk_model1); fprintf('model4 tested\n');
disk_model1.preclass4 = b;
result{4,1} = a;

[smart1_train_5, ~, ~] = select_TrTsSmart(disk_model1, 7, 1, 3);
smart1_train_5(:, 34:52) = []; smart1_train_5 = scale_data(smart1_train_5, 1);
model5 = rf_train(smart1_train_5); fprintf('model5 trained\n');
[a, b] = model_test(model5, disk_model1); fprintf('model5 tested\n');
disk_model1.preclass5 = b;
result{5,1} = a;

result1_1 = result;

load disk_model2.mat

[smart2_train_1, ~, ~] = select_TrTsSmart(disk_model2, 7, 1, 3);
smart2_train_1(:, 34:52) = []; smart2_train_1 = scale_data(smart2_train_1, 1);
model1 = rf_train(smart2_train_1); fprintf('model1 trained\n');
[a, b] = model_test(model1, disk_model2); fprintf('model1 tested\n');
disk_model2.preclass1 = b;
result = {a};

[smart2_train_2, ~, ~] = select_TrTsSmart(disk_model2, 7, 1, 3);
smart2_train_2(:, 34:52) = []; smart2_train_2 = scale_data(smart2_train_2, 1);
model2 = rf_train(smart2_train_2); fprintf('model2 trained\n');
[a, b] = model_test(model2, disk_model2); fprintf('model2 tested\n');
disk_model2.preclass2 = b;
result{2,1} = a;

[smart2_train_3, ~, ~] = select_TrTsSmart(disk_model2, 7, 1, 3);
smart2_train_3(:, 34:52) = []; smart2_train_3 = scale_data(smart2_train_3, 1);
model3 = rf_train(smart2_train_3); fprintf('model3 trained\n');
[a, b] = model_test(model3, disk_model2); fprintf('model3 tested\n');
disk_model2.preclass3 = b;
result{3,1} = a;

[smart2_train_4, ~, ~] = select_TrTsSmart(disk_model2, 7, 1, 3);
smart2_train_4(:, 34:52) = []; smart2_train_4 = scale_data(smart2_train_4, 1);
model4 = rf_train(smart2_train_4); fprintf('model4 trained\n');
[a, b] = model_test(model4, disk_model2); fprintf('model4 tested\n');
disk_model2.preclass4 = b;
result{4,1} = a;

[smart2_train_5, ~, ~] = select_TrTsSmart(disk_model2, 7, 1, 3);
smart2_train_5(:, 34:52) = []; smart2_train_5 = scale_data(smart2_train_5, 1);
model5 = rf_train(smart2_train_5); fprintf('model5 trained\n');
[a, b] = model_test(model5, disk_model2); fprintf('model5 tested\n');
disk_model2.preclass5 = b;
result{5,1} = a;

result2_1 = result;

load disk_model5.mat

[smart5_train_1, ~, ~] = select_TrTsSmart(disk_model5, 7, 10, 3);
smart5_train_1(:, 34:52) = []; smart5_train_1 = scale_data(smart5_train_1, 1);
model1 = rf_train(smart5_train_1); fprintf('model1 trained\n');
[a, b] = model_test(model1, disk_model5); fprintf('model1 tested\n');
disk_model5.preclass1 = b;
result = {a};

[smart5_train_2, ~, ~] = select_TrTsSmart(disk_model5, 7, 10, 3);
smart5_train_2(:, 34:52) = []; smart5_train_2 = scale_data(smart5_train_2, 1);
model2 = rf_train(smart5_train_2); fprintf('model2 trained\n');
[a, b] = model_test(model2, disk_model5); fprintf('model2 tested\n');
disk_model5.preclass2 = b;
result{2,1} = a;

[smart5_train_3, ~, ~] = select_TrTsSmart(disk_model5, 7, 10, 3);
smart5_train_3(:, 34:52) = []; smart5_train_3 = scale_data(smart5_train_3, 1);
model3 = rf_train(smart5_train_3); fprintf('model3 trained\n');
[a, b] = model_test(model3, disk_model5); fprintf('model3 tested\n');
disk_model5.preclass3 = b;
result{3,1} = a;

[smart5_train_4, ~, ~] = select_TrTsSmart(disk_model5, 7, 10, 3);
smart5_train_4(:, 34:52) = []; smart5_train_4 = scale_data(smart5_train_4, 1);
model4 = rf_train(smart5_train_4); fprintf('model4 trained\n');
[a, b] = model_test(model4, disk_model5); fprintf('model4 tested\n');
disk_model5.preclass4 = b;
result{4,1} = a;

[smart5_train_5, ~, ~] = select_TrTsSmart(disk_model5, 7, 10, 3);
smart5_train_5(:, 34:52) = []; smart5_train_5 = scale_data(smart5_train_5, 1);
model5 = rf_train(smart5_train_5); fprintf('model5 trained\n');
[a, b] = model_test(model5, disk_model5); fprintf('model5 tested\n');
disk_model5.preclass5 = b;
result{5,1} = a;

result5_1 = result;

load disk_model6.mat

[smart6_train_1, ~, ~] = select_TrTsSmart(disk_model6, 7, 10, 3);
smart6_train_1(:, 34:52) = []; smart6_train_1 = scale_data(smart6_train_1, 1);
model1 = rf_train(smart6_train_1); fprintf('model1 trained\n');
[a, b] = model_test(model1, disk_model6); fprintf('model1 tested\n');
disk_model6.preclass1 = b;
result = {a};

[smart6_train_2, ~, ~] = select_TrTsSmart(disk_model6, 7, 10, 3);
smart6_train_2(:, 34:52) = []; smart6_train_2 = scale_data(smart6_train_2, 1);
model2 = rf_train(smart6_train_2); fprintf('model2 trained\n');
[a, b] = model_test(model2, disk_model6); fprintf('model2 tested\n');
disk_model6.preclass2 = b;
result{2,1} = a;

[smart6_train_3, ~, ~] = select_TrTsSmart(disk_model6, 7, 10, 3);
smart6_train_3(:, 34:52) = []; smart6_train_3 = scale_data(smart6_train_3, 1);
model3 = rf_train(smart6_train_3); fprintf('model3 trained\n');
[a, b] = model_test(model3, disk_model6); fprintf('model3 tested\n');
disk_model6.preclass3 = b;
result{3,1} = a;

[smart6_train_4, ~, ~] = select_TrTsSmart(disk_model6, 7, 10, 3);
smart6_train_4(:, 34:52) = []; smart6_train_4 = scale_data(smart6_train_4, 1);
model4 = rf_train(smart6_train_4); fprintf('model4 trained\n');
[a, b] = model_test(model4, disk_model6); fprintf('model4 tested\n');
disk_model6.preclass4 = b;
result{4,1} = a;

[smart6_train_5, ~, ~] = select_TrTsSmart(disk_model6, 7, 10, 3);
smart6_train_5(:, 34:52) = []; smart6_train_5 = scale_data(smart6_train_5, 1);
model5 = rf_train(smart6_train_5); fprintf('model5 trained\n');
[a, b] = model_test(model5, disk_model6); fprintf('model5 tested\n');
disk_model6.preclass5 = b;
result{5,1} = a;

result6_1 = result;
