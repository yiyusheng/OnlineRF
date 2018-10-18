% 

function [smart_t] = select_sample(Disk_Model, NumOfPosSample, NumOfNegSample)

disk_model = Disk_Model;
time_window = NumOfPosSample;

for i = 1:size(disk_model, 1)
    disk = disk_model(i, :);
    smarts = disk.smarts{1};
    class = double(disk.class(1));
    sn_id = double(disk.sn_id(1));
    if class == 1
        smart = smarts(smarts.datenum <= time_window, :);
    else
        if size(smarts, 1) > time_window+NumOfNegSample
            ind = randperm(size(smarts, 1) - time_window);
            smart = smarts(ind(1:NumOfNegSample) + time_window, :);
        end
    end
    smart.class = linspace(class,class,size(smart, 1))';
    smart.sn_id = linspace(sn_id,sn_id,size(smart, 1))';
    if i == 1
        smart_t = smart;
    else
        smart_t = [smart_t; smart];
    end
end
smart_t = sortrows(smart_t, 'date','ascend');

end
