function cost = func_eval_disk_time_order_bynaturalday(dt,dn,pred,limited_days,random_days,rev,window_days)
    %% config
    dt = dt(dt.(dn) <= limited_days,:);
    dt = sortrows(dt,{'sn_id',dn},{'ascend','descend'});
    dt.id = [1:size(dt,1)]';
      
    dt.date_window = func_gen_tia_groups(dt.date,window_days);
    summary_date = cell2table(tabulate(dt.date_window));
    effective_date = summary_date(summary_date{:,2}>window_days*5,1);
    selected_date = randsample(effective_date{:,1},min(size(effective_date,1),random_days),false);
    random_days = length(selected_date);
   
    
    %% compare datenum and pred
    cost_epoch = zeros(random_days,1);
    for i=1:random_days
        idr = sort(dt.id(dt.date_window == selected_date(i)));
        len_idr = length(idr);
        for j=1:(len_idr-1)
            cur_dn = dt.(dn)(idr(j));
            cur_pred = dt.(pred)(idr(j));
            
            dt_comp = [cur_dn(ones(len_idr-j,1)),...
                dt.(dn)(idr((j+1):len_idr)),...
                cur_pred(ones(len_idr-j,1)),...
                dt.(pred)(idr((j+1):len_idr))];
            
            if rev
                dt_comp(:,5) = (dt_comp(:,1)< dt_comp(:,2)) + (dt_comp(:,3)> dt_comp(:,4));
                dt_comp(:,6) = (dt_comp(:,1)==dt_comp(:,2)) + (dt_comp(:,3)==dt_comp(:,4));
                dt_comp(:,7) = (dt_comp(:,1)> dt_comp(:,2)) + (dt_comp(:,3)< dt_comp(:,4));
            else
                dt_comp(:,5) = (dt_comp(:,1)< dt_comp(:,2)) + (dt_comp(:,3)< dt_comp(:,4));
                dt_comp(:,6) = (dt_comp(:,1)==dt_comp(:,2)) + (dt_comp(:,3)==dt_comp(:,4));
                dt_comp(:,7) = (dt_comp(:,1)> dt_comp(:,2)) + (dt_comp(:,3)> dt_comp(:,4));
            end
             dt_comp(:,8) = all(dt_comp(:,5:7)~=2,2);
            
            cost_epoch(i) = cost_epoch(i)+sum(dt_comp(:,8));
            
        end
        num_compare = (1+len_idr)*len_idr/2;
        cost_epoch(i) = cost_epoch(i)/num_compare;
    end
    cost = mean(cost_epoch);
end