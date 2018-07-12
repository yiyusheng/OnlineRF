function [smart] = add_health_degree(dt)
  dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});
  size_dt = size(dt);
  id = 1:size_dt(1);
  dt.id = id';
  dt_pos = dt(dt.class==1,:);
  dt_neg = dt(dt.class==0,:);

  % Add health degree
  size_dt_neg = size(dt_neg);
  dt_neg.health_degree = zeros(size_dt_neg(1),1);

  %dt_pos = sortrows(dt_pos,{'sn_id','date'});
  size_dt_pos = size(dt_pos);
  health_degree = zeros(size_dt_pos(1),1);

  x_left = 1;
  for i = 2:size_dt_pos(1)
      if dt_pos.sn_id(i) == dt_pos.sn_id(x_left)
          continue;
      else
          health_degree(x_left:(i-1)) = round(linspace(0,1,(i-x_left)),4);
          x_left = i;
      end
  end
  dt_pos.health_degree = health_degree;
  dt_hldgr = [dt_pos;dt_neg];
  smart = sortrows(dt_hldgr,'id');
end
