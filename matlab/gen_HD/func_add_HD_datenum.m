function [hddn,smart,cost_hddn] = func_add_HD_datenum(dt,f_sort,predictorNames,sn_train,days_train,days_cost)
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

  
  %% Add health degree for dt_neg and dt_pos_test
    dt_neg.hddn = zeros(size(dt_neg,1),1);
    dt_pos_test.hddn = zeros(size(dt_pos_test,1),1);
    
    %% Add HD for dt_pos_train
    len_dt_pos = size(dt_valid_pos_train,1);

    x_left = 1;
    for i = 2:len_dt_pos
      if dt_valid_pos_train.sn_id(i) == dt_valid_pos_train.sn_id(x_left) && i ~= len_dt_pos
          continue;
      else
          if(i==len_dt_pos)
            x_right=len_dt_pos+1;
          else
            x_right=i;
          end
          dt_valid_pos_train.hddn(x_left:(x_right-1)) = round(linspace(0.0001,1,(x_right-x_left)),4);  %DSN14 method: datenum to [-1,0], we set datenum to [0,1];
          x_left = i;
      end
    end
  
  %% evaluate cost of train
  addpath('/home/xzhuang/Code/C/OnlineRF/matlab/eval_Model/');
  cost_hddn = func_eval_disk_time_order_bydatenum(dt_valid_pos_train,'hddn',days_cost,10);
  
  %% combine pos and neg
  dt_combine = [dt_valid_pos_train;dt_pos_test;dt_neg];
  if f_sort
    smart = dt_combine;
  else
    smart = sortrows(dt_combine,'id');
  end
  hddn = smart.hddn;
end
