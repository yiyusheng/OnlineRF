function DT = func_gen_diff(DT,predictorNames)
    for i=1:length(predictorNames)
        cur_attr = predictorNames{i};
        DT.([cur_attr '_diff']) = [0;diff(DT.(cur_attr))];
    end
    DT.id = (1:size(DT,1))';
    [G groups] = findgroups(DT.sn_id);
    id_invalid = splitapply(@min,DT.id,G);
    DT(id_invalid,:)=[];
    DT.id = [];
end