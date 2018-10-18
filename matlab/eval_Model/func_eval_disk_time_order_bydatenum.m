function cost = func_eval_disk_time_order_bydatenum(dt,pred,days,num_random)
    %% config
    summary_snid = tabulate(dt.sn_id);
    dt = dt(dt.datenum <= days & ismember(dt.sn_id,summary_snid(summary_snid(:,2)>num_random,1)),:);
    dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});
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
        idr = id_random(i,:);
        for j=1:(len_sn-1)
            cur_dn = dt.datenum(idr(j));
            cur_pred = dt.(pred)(idr(j));
            
            dt_comp = [cur_dn(ones(len_sn-j,1)),...
                dt.datenum(idr((j+1):len_sn)),...
                cur_pred(ones(len_sn-j,1)),...
                dt.(pred)(idr((j+1):len_sn))];
            
            cost_epoch(i) = cost_epoch(i)+sum(xor(dt_comp(:,1)<=dt_comp(:,2),dt_comp(:,3)>=dt_comp(:,4)));
        end
    end
    cost = mean(cost_epoch/(len_sn*(len_sn-1)/2));
end