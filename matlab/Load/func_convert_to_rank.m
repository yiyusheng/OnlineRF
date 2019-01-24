function data_output = func_convert_to_rank(data,predictorNames,rankNames,rankCut,numQ,path,isIncludeNeg)
    rankCut = sort(unique([rankCut max(data.(rankNames))]));
    lenRank = length(rankCut)-1;  
    
    discRank = discretize(data.(rankNames),rankCut,lenRank:-1:1);
    if(isIncludeNeg)
        discRank(data.class==0)=0;
        discRank = discRank+1;
    end
    valRank = sprintfc('%d',discRank);
    
    lenvRank = size(valRank,1);
    valqid = repmat({'qid:1'},lenvRank,1);
    if numQ>=2
        rand_idx = randi(numQ,lenvRank,1);
        for i=2:numQ
            valqid(rand_idx==i)={sprintf('qid:%d',i)};
        end
    elseif numQ==-1
        valqid(end) = {'qid:2'};
    elseif numQ==-2
        valqid(:)={'qid:2'};
    end
        
    data_output = table(valRank,valqid);
%     predictorNames = [predictorNames {'datenum'}]; %NOTE: for experiment
    
    for i=1:length(predictorNames)
        valpredix = repmat({[num2str(i) ':']},size(valRank,1),1);
        valnum = sprintfc('%.5f',data.(predictorNames{i}));
        valSMART = strcat(valpredix,valnum);
        data_output = [data_output,valSMART];
    end
    
    writetable(data_output,path,'Delimiter',' ','WriteVariableNames',false);
end