function cost = func_eval_global_time_order_byquantile(dt,pred)
  %% gen cost for pred
  quantile_dn = quantile(dt.datenum,0:0.01:1);
  quantile_pred = quantile(dt.(pred),1:-0.01:0);
  
  for i=1:(numel(quantile_pred)-1)
      id_dn = dt.id(dt.datenum > quantile_dn(i) & dt.datenum <= quantile_dn(i+1));
      id_pred = dt.id(dt.(pred)> quantile_pred(i+1) & dt.(pred) <= quantile_pred(i));
      cost(i) = sum(ismember(id_pred,id_dn))/length(id_dn);
  end
  
end