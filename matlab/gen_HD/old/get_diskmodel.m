% get disk_model1_*.mat from smart_model1_*.mat
% smart_model = load('smart_model1_8.mat');
function [ disk_model ] = get_diskmodel( smart_model )

[sn, ia, ic] = unique(smart_model.serial_number);
disk_model = table(sn);
disk_model.maxdate = smart_model.date(ia);
disk_model.mindate = smart_model.date(ia);
disk_model.samplenum = smart_model.smart_1_raw(ia);
disk_model.class = smart_model.failure(ia);
disk_model.smarts = disk_model.sn;

disknum = size(disk_model,1);
tic;
parfor i = 1:disknum
    disk = disk_model(i, :);
    smarts = smart_model(strcmp(smart_model.serial_number,disk.sn{1}),:);
    smarts = sortrows(smarts, 1);
    disk.maxdate(1) = max(smarts.date);
    disk.mindate(1) = min(smarts.date);
    disk.samplenum(1) = size(smarts, 1);
    disk.class(1) = max(smarts.failure);
    disk.smarts{1} = smarts(:,[1,4:size(smarts, 2)]);
    disk_model(i, :) = disk;
    fprintf('%d\n',i);
end;toc;

end
% disk_model1_8 = get_diskmodel( smart_model );
% save('disk_model1_8.mat','disk_model1_8')
