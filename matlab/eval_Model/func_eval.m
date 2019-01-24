% export evaluation result for special parameters
function [r_my r_ndcg] = func_eval(evalTable,dnX,days_eval,num_random,q1,q2)
    % my metric
    rev = 1;
    my_rand = func_eval_disk_time_order_bydatenum(evalTable,dnX,'pred_rand',days_eval,num_random,rev);
    my_hddn = func_eval_disk_time_order_bydatenum(evalTable,dnX,'pred_hddn',days_eval,num_random,rev);
    my_hdsc = func_eval_disk_time_order_bydatenum(evalTable,dnX,'pred_hdsc',days_eval,num_random,rev);
    my_hdmd = func_eval_disk_time_order_bydatenum(evalTable,dnX,'pred_hdmd',days_eval,num_random,rev);
    my_rank = func_eval_disk_time_order_bydatenum(evalTable,dnX,'pred_rank',days_eval,num_random,rev);
    r_my = [my_rand,my_hddn,my_hdsc,my_hdmd,my_rank];
    r_my = array2table(r_my);
    r_my.Properties.VariableNames = {'rand','hddn','hdsc','hdmd','rank'};
    r_my.Properties.RowNames = {sprintf('my_metric:%d days_q1%s_q2%s',days_eval,num2str(q1),num2str(q2))};
    
    % ndcg
    n_k = 10;
    evalNDCG = evalTable(evalTable.datenum < days_eval,:);
    ndcg_rand = func_ndcg_at_k(n_k,evalNDCG.pred_rand',1./evalNDCG.(dnX)');
    ndcg_hddn = func_ndcg_at_k(n_k,evalNDCG.pred_hddn',1./evalNDCG.(dnX)');
    ndcg_hdsc = func_ndcg_at_k(n_k,evalNDCG.pred_hdsc',1./evalNDCG.(dnX)');
    ndcg_hdmd = func_ndcg_at_k(n_k,evalNDCG.pred_hdmd',1./evalNDCG.(dnX)');
    ndcg_rank = func_ndcg_at_k(n_k,evalNDCG.pred_rank',1./evalNDCG.(dnX)');
    r_ndcg = [ndcg_rand(end),ndcg_hddn(end),ndcg_hdsc(end),ndcg_hdmd(end),ndcg_rank(end)];
    r_ndcg = array2table(r_ndcg);
    r_ndcg.Properties.VariableNames = {'rand','hddn','hdsc','hdmd','rank'};
    r_ndcg.Properties.RowNames = {sprintf('NDCG@%d:%d days',n_k,days_eval)};
    
end
