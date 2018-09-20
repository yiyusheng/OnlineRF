function [smart_train, smart_test, smart_dtest] = select_TrTsSmart(DiskModel, TimeWindow, PosExpansion, NPRadio)

disk_model = DiskModel;
diskp = disk_model(disk_model.class==1, :);
diskn = disk_model(disk_model.class==0, :);

indp = randperm(size(diskp, 1));
indn = randperm(size(diskn, 1));
TrTsRadio = 0.6;

smartp_train = select_sample(diskp(indp(1:int32(size(diskp, 1)*TrTsRadio)), :), TimeWindow, 30);
smartp_test  = select_sample(diskp(indp(int32(size(diskp, 1)*TrTsRadio)+1:end), :), TimeWindow, 30);
smartp_dtest  = select_sample(diskp(indp(int32(size(diskp, 1)*TrTsRadio)+1:end), :), 30, 30);
for i = 1:PosExpansion
    if i == 1
        smart_train = smartp_train;
        smart_test  = smartp_test;
    else
        smart_train = [smart_train; smartp_train];
        smart_test  = [smart_test; smartp_test];
    end
end

smartn_train = select_sample(diskn(indn(1:int32(size(diskn, 1)*TrTsRadio)), :), TimeWindow, 30);
smartn_test  = select_sample(diskn(indn(int32(size(diskn, 1)*TrTsRadio)+1:end), :), TimeWindow, 30);
smartn_dtest  = select_sample(diskn(indn(int32(size(diskn, 1)*TrTsRadio)+1:end), :), 30, 30);

ind = randperm(size(smartn_train, 1));
tmp = min(size(smart_train, 1)*NPRadio, size(smartn_train, 1));
smartn_train = smartn_train(ind(1:tmp), :);
ind = randperm(size(smartn_test, 1));
tmp = min(size(smart_test, 1)*NPRadio, size(smartn_test, 1));
smartn_test = smartn_test(ind(1:tmp), :);

smart_train = [smart_train; smartn_train];
smart_test  = [smart_test; smartn_test];
smart_dtest = [smartp_dtest; smartn_dtest];

smart_train = sortrows(smart_train,'date','ascend');

end