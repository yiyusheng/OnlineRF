function [diskRecessionPoint] = getRecessionPoint(smarts)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
disk_result = unique(smarts.sn_id);
disk_result = mat2cell(disk_result, ones(size(disk_result,1), 1));
disk_result(:,2) = disk_result(:,1);
disk_result(:,3) = disk_result(:,1);
disk_result(:,4) = disk_result(:,1);
disk_result(:,5) = disk_result(:,1);
disk_result(:,6) = disk_result(:,1);
disk_result(:,7) = disk_result(:,1);
disk_result(:,8) = disk_result(:,1);
disk_result(:,9) = disk_result(:,1);
for i = 1:size(disk_result, 1)
    disk = disk_result(i, :);
    smart = smarts(smarts.sn_id == disk{1}, :);
    
%     s5r = smart.S5rChange;
%     for j = size(s5r, 1):-1:2
%         if s5r(j) < 0
%             s5r(j-1) = s5r(j-1) + s5r(j);
%             s5r(j) = 0;
%         end
%     end
%     tmp = smart(s5r > 0, 'date');
    tmp = smart(smart.S5rChange > 0, 'date');
    if isempty(tmp)
        disk{2} = -1;
    else
        disk{2} = max(tmp.date);
    end
    
    s197r = smart.S197rChange;
    for j = size(s197r, 1):-1:2
        if s197r(j) < 0
            s197r(j-1) = s197r(j-1) + s197r(j);
            s197r(j) = 0;
        end
    end
    tmp = smart(s197r > 0, 'date');
    if isempty(tmp)
        disk{3} = -1;
    else
        disk{3} = max(tmp.date);
    end
    
    disk{4} = max(disk{2}, disk{3});
    disk{5} = smart;
    
    tmp = smart(smart.S183rChange > 0, 'date');
    if isempty(tmp)
        disk{6} = -1;
    else
        disk{6} = max(tmp.date);
    end
    
    tmp = smart(smart.S184rChange > 0, 'date');
    if isempty(tmp)
        disk{7} = -1;
    else
        disk{7} = max(tmp.date);
    end
    
    tmp = smart(smart.S187rChange > 0, 'date');
    if isempty(tmp)
        disk{8} = -1;
    else
        disk{8} = max(tmp.date);
    end

    tmp = smart(smart.S189rChange > 0, 'date');
    if isempty(tmp)
        disk{9} = -1;
    else
        disk{9} = max(tmp.date);
    end
    
    disk_result(i, :) = disk;
end
disk_result = cell2table(disk_result, 'VariableNames', {'sn_id', 's5rPoint', 's197rPoint', 'recessionPoint', 'disk_smart', ...
    's183rPoint', 's184rPoint', 's187rPoint', 's189rPoint'});
diskRecessionPoint = disk_result;
end

