function [smart] = add_health_degree(dt,f_sort)
  size_dt = size(dt);
  id = 1:size_dt(1);
  dt.id = id';
  dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});
  dt_pos = dt(dt.class==1,:);
  dt_neg = dt(dt.class==0,:);

  % Add health degree
  size_dt_neg = size(dt_neg);
  dt_neg.health_degree = zeros(size_dt_neg(1),1);

  size_dt_pos = size(dt_pos);
  health_degree = zeros(size_dt_pos(1),1);

  x_left = 1;
  for i = 2:size_dt_pos(1)
      if dt_pos.sn_id(i) == dt_pos.sn_id(x_left) && i ~= size_dt_pos(1)
          continue;
      else
          if(i==size_dt_pos)
            x_right=size_dt_pos(1)+1;
          else
            x_right=i;
          end
          health_degree(x_left:(x_right-1)) = round(linspace(0.0001,1,(x_right-x_left)),4);
          x_left = i;
      end
  end
  dt_pos.health_degree = health_degree;
  dt_combine = [dt_pos;dt_neg];
  if f_sort
    smart = dt_combine;
  else
    smart = sortrows(dt_combine,'id');
  end
end
