function cost = func_eval_global_time_order_bydatenum(dt,pred,array_cutdays)
    value2quantile = @(x)size(dt.datenum(dt.datenum <= x),1)/size(dt,1);
    
    qvalue_dn = [0,array_cutdays,max(dt.datenum)];
    q_pred = [1,1-arrayfun(value2quantile,array_cutdays),0];
    qvalue_pred = quantile(dt.(pred),q_pred);

    for i=1:(numel(qvalue_pred)-1)
        id_dn = dt.id(dt.datenum > qvalue_dn(i) & dt.datenum <= qvalue_dn(i+1));
        id_pred = dt.id(dt.(pred)> qvalue_pred(i+1) & dt.(pred) <= qvalue_pred(i));
        cost(i) = sum(ismember(id_pred,id_dn))/length(id_dn);
%         [length(id_dn),length(id_pred)]
    end
    
%     dt_dn = dt(ismember(dt.id,id_dn),metaNames_res);
%     dt_pred = dt(ismember(dt.id,id_pred),metaNames_res);
end