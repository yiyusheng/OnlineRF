function [hdsc,smart,cost_hdsc] = func_add_HD_SMART_center(dt,f_sort,predictorNames,sn_train,days_train,days_cost,K,valid_weight_days)
    %% scale smart
    dt = func_scale_smart_attributes(dt,predictorNames);
  
    %% if f_sort == 0 then keep original order else sort by 'sn_id' and 'datenum'
    id = 1:size(dt,1);
    dt.id = id';
    dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});

    dt_neg = dt(dt.class==0,:);
    dt_pos = dt(dt.class==1,:);

    id_valid_pos_train = unique(dt_pos.sn_id(ismember(dt_pos.sn_id,sn_train) & dt_pos.datenum >= days_train));
    dt_valid_pos_train = dt_pos(ismember(dt_pos.sn_id,id_valid_pos_train) & dt_pos.datenum <= days_train,:);   
    id_pos_test = unique(dt_pos.sn_id(~ismember(dt_pos.sn_id,sn_train)));
    dt_pos_test = dt_pos(ismember(dt_pos.sn_id,id_pos_test),:);   

    %% Add health degree for neg samples
    dt_neg.hdsc = zeros(size(dt_neg,1),1);
    dt_pos_test.hdsc = zeros(size(dt_pos_test,1),1);
    
  %% Cluster samples of pos_train
  [idx_pt,C_pt] = kmeans(double(table2array(dt_valid_pos_train(:,predictorNames))),K);
  
  %% Gen weight for each group
  [G,groups] = findgroups(idx_pt);
  func_group_weight = @(x)sum(1./x(x<=valid_weight_days))/numel(x);
  group_weight = [groups,...
      splitapply(func_group_weight,dt_valid_pos_train.datenum,G),...
      splitapply(@numel,dt_valid_pos_train.datenum,G)];
  
  %% Gen sum of distance between samples and each group centers
  for i=1:size(dt_valid_pos_train,1)
      sample_dist = pdist2(double(table2array(dt_valid_pos_train(i,predictorNames))),C_pt);
      dt_valid_pos_train.hdsc(i) = sum((1./sample_dist').*group_weight(:,2).*group_weight(:,3));
      if mod(i,10000)==0
%           disp(i)
      end
  end
  
  %% evaluate cost of train
  addpath('/home/xzhuang/Code/C/OnlineRF/matlab/eval_Model/');
  cost_hdsc = func_eval_disk_time_order_bydatenum(dt_valid_pos_train,'hdsc',days_cost,10);

  %% Combine pos and neg
  dt_combine = [dt_valid_pos_train;dt_pos_test;dt_neg];
  if f_sort
    smart = dt_combine;
  else
    smart = sortrows(dt_combine,'id');
  end
  hdsc = smart.hdsc;
end
