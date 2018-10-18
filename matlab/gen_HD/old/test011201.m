smart1_all_data = smart1_all{:, predictorNames};
smart1_all_labels = smart1_all.class;
smart1_all_snids = smart1_all.sn_id;
dlmwrite('smart1_all.data', size(smart1_all_data), 'delimiter', ' ', 'precision', '%u');
dlmwrite('smart1_all.data', smart1_all_data, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite('smart1_all.labels', size(smart1_all_labels), 'delimiter', ' ', 'precision', '%u');
dlmwrite('smart1_all.labels', smart1_all_labels, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite('smart1_all.snids', size(smart1_all_snids), 'delimiter', ' ', 'precision', '%u');
dlmwrite('smart1_all.snids', smart1_all_snids, 'delimiter', ' ', 'precision', '%u', '-append');

smart1_train_1_data = smart1_train_1{:, predictorNames};
smart1_train_1_labels = smart1_train_1.class;
smart1_train_1_snids = smart1_train_1.sn_id;
dlmwrite('smart1_train_1.data', size(smart1_train_1_data), 'delimiter', ' ', 'precision', '%u');
dlmwrite('smart1_train_1.data', smart1_train_1_data, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite('smart1_train_1.labels', size(smart1_train_1_labels), 'delimiter', ' ', 'precision', '%u');
dlmwrite('smart1_train_1.labels', smart1_train_1_labels, 'delimiter', ' ', 'precision', '%u', '-append');
dlmwrite('smart1_train_1.snids', size(smart1_train_1_snids), 'delimiter', ' ', 'precision', '%u');
dlmwrite('smart1_train_1.snids', smart1_train_1_snids, 'delimiter', ' ', 'precision', '%u', '-append');
