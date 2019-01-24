function smart = func_add_HD_datenum(dt,need_oriorder)
    %% if f_sort == 0 then keep original order else sort by 'sn_id' and 'datenum'
    id = 1:size(dt,1);
    dt.id = id';
    dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});

    dt_neg = dt(dt.class==0,:);
    dt_pos = dt(dt.class==1,:);
  
    %% Add health degree for dt_neg and dt_pos_test
    dt_neg.hddn = zeros(size(dt_neg,1),1);
    
    %% Add HD for dt_pos_train
    dt_pos.hddn = 1./dt_pos.datenum;

    %% combine pos and neg
    dt_combine = [dt_pos;dt_neg];
    if ~need_oriorder
      smart = dt_combine;
    else
      smart = sortrows(dt_combine,'id');
    end
end
