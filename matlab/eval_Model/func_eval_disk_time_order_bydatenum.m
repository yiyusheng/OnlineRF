function cost = func_eval_disk_time_order_bydatenum(dt,dn,pred,num_period,num_random,rev)
    %% config
    summary_snid = tabulate(dt.sn_id);
    dt = dt(dt.(dn) <= num_period,:);
    dt = sortrows(dt,{'sn_id',dn},{'ascend','descend'});
    dt.id = [1:size(dt,1)]';
    uni_sn = unique(dt.sn_id);
    len_sn = length(uni_sn);
    
    %% extract samples of disks randomly
    [G,groups] = findgroups(dt.sn_id);
    extract_sample = @(x)randsample(x,num_random,true)';
    id_random = splitapply(extract_sample,dt.id,G)';
    
    %% compare datenum and pred
    cost_epoch = zeros(num_random,1);
    for i=1:num_random
        count_sn = 0;
        idr = id_random(i,:);
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
            count_sn = count_sn+size(cost_epoch,1);
        end
        num_compare = (1+len_idr)*len_idr/2;
        cost_epoch(i) = cost_epoch(i)/num_compare;
    end
    cost = mean(cost_epoch);
end