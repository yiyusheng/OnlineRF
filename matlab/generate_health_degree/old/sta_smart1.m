run generate_data_model1.m

train_pos = smart1_train(smart1_train.class==1,:);
train_neg = smart1_train(smart1_train.class==0,:);
test_pos = smart1_test(smart1_test.class==1,:);
test_neg = smart1_test(smart1_test.class==0,:);
all_pos = smart1_all(smart1_all.class==1,:);  
all_neg = smart1_all(smart1_all.class==0,:);

size(unique(train_pos.sn_id))
size(unique(train_neg.sn_id))
size(unique(test_pos.sn_id))
size(unique(test_neg.sn_id))
size(unique(all_pos.sn_id))
size(unique(all_neg.sn_id))
