function smart = func_add_HD_SMART_center(dt,need_oriorder,predictorNames,K,key_days)
    %% if f_sort == 0 then keep original order else sort by 'sn_id' and 'datenum'
    id = 1:size(dt,1);
    dt.id = id';
    dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});

    dt_neg = dt(dt.class==0,:);
    dt_pos = dt(dt.class==1,:);

    
    %% Add health degree for neg samples
    dt_neg.hdsc = zeros(size(dt_neg,1),1);
    
  %% Cluster samples of pos_train
  [idx_pt,C_pt] = kmeans(double(table2array(dt_pos(:,predictorNames))),K);
  
  %% Gen weight for each group
  [G,groups] = findgroups(idx_pt);
  group_weight = [groups,...
      splitapply(@mean,dt_pos.datenum,G),...
      splitapply(@numel,dt_pos.datenum,G)];
  
  %% Gen sum of distance between samples and each group centers
  sample_dist = pdist2(double(table2array(dt_pos(:,predictorNames))),C_pt);
  for i=1:size(sample_dist,2)
      sample_dist(:,i) = sample_dist(:,i)/group_weight(i,2)*group_weight(i,3);
  end
  dt_pos.hdsc = sum(sample_dist,2);
  
  %% Combine pos and neg
  dt_combine = [dt_pos;dt_neg];
  if ~need_oriorder
    smart = dt_combine;
  else
    smart = sortrows(dt_combine,'id');
  end
end
