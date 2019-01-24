% evaluate disk failure prediction
function r = func_eval_dfp(dfp,pred_disk,predstr,G,threshold)
    eval_dfp = @(x,thred)any(x>thred);
    len_dfp = size(dfp,1);
    len_thred = length(threshold);
    dfp.(predstr) = (dfp.(predstr) - min(dfp.(predstr)))/(max(dfp.(predstr))-min(dfp.(predstr)));
    
    r = zeros(size(len_thred,1),3);
    for i=1:length(threshold)
        pred_disk.(predstr) = splitapply(eval_dfp,dfp.(predstr),ones(len_dfp,1)*threshold(i),G);
        TP = sum(pred_disk.real==1 & pred_disk.(predstr)==1);
        FP = sum(pred_disk.real==0 & pred_disk.(predstr)==1);
        TN = sum(pred_disk.real==0 & pred_disk.(predstr)==0);
        FN = sum(pred_disk.real==1 & pred_disk.(predstr)==0);
        FDR = TP/(TP+FN);
        FAR = FP/(FP+TN);
        r(i,:) = [threshold(i) FDR FAR];
    end
    
    r = array2table(r);
    r.Properties.VariableNames = {'threshold','FDR','FAR'};

end