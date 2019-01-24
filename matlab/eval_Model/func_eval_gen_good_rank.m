function sn_good_rank = func_eval_gen_good_rank(evalTable,q1,q2)
    ET = evalTable;
    predNames = {'pred_rand','pred_hddn','pred_hdsc','pred_hdmd','pred_rank'};

    %% Generate mean of pred result for all samples according datenum
    disp('Generate mean of pred result...');

    [G groups] = findgroups(ET.datenum);
    len_dn = length(unique(ET.datenum));
    len_pred = length(predNames);

    % pred_mean = zeros(len_dn,len_pred+1);
    pred_mean = unique(ET.datenum);
    for i=1:len_pred
        pred_mean(:,i+1) = splitapply(@mean,ET.(predNames{i}),G);
    end

    pred_mean = array2table(pred_mean);
    pred_mean.Properties.VariableNames = [{'datenum'} predNames];

    %% Generate the distance of pred result between each disk and the mean generated above.
    disp('Generate distance of pred result for disk...')
    [G groups] = findgroups(ET.sn_id);
    len_id = length(unique(ET.sn_id));

    id_dist = unique(ET.sn_id);
    [C idx] = ismember(ET.datenum,pred_mean.datenum);
    pdist2_my = @(x,y)sqrt(sum((x-y).^2));

    for i= 1:len_pred
        pred_value = pred_mean.(predNames{i});
        id_dist(:,i+1) = splitapply(pdist2_my,ET.(predNames{i}),pred_value(idx),G);
    end
    id_dist = array2table(id_dist);
    id_dist.Properties.VariableNames = [{'sn_id'} predNames];

    %% save sn being good to rank
    sn_good_rank = id_dist.sn_id(id_dist.pred_rank <= quantile(id_dist.pred_rank,0.5) & id_dist.pred_hddn >= quantile(id_dist.pred_hddn,0.5));
end