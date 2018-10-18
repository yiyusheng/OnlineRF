run generate_data_model2.m

train_pos = smart2_train(smart2_train.class==1,:);
train_neg = smart2_train(smart2_train.class==0,:);
test_pos = smart2_test(smart2_test.class==1,:);
test_neg = smart2_test(smart2_test.class==0,:);
all_pos = smart2_all(smart2_all.class==1,:);  
all_neg = smart2_all(smart2_all.class==0,:);

size(unique(train_pos.sn_id))
size(unique(train_neg.sn_id))
size(unique(test_pos.sn_id))
size(unique(test_neg.sn_id))
size(unique(all_pos.sn_id))
size(unique(all_neg.sn_id))
