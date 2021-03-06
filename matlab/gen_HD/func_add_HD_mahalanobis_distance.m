function smart = func_add_HD_mahalanobis_distance(dt,need_oriorder,predictorNames,sn_train,days_window)
    %% if f_sort == 0 then keep original order else sort by 'sn_id' and 'datenum'
    id = 1:size(dt,1);
    dt.id = id';
    dt = sortrows(dt,{'sn_id','datenum'},{'ascend','descend'});

    dt_neg = dt(dt.class==0,:);
    dt_pos = dt(dt.class==1,:);
    
    id_pos_train = unique(dt_pos.sn_id(ismember(dt_pos.sn_id,sn_train)));
    dt_pos_train = dt_pos(ismember(dt_pos.sn_id,id_pos_train),:);  
    dt_pos_test = dt_pos(~ismember(dt_pos.sn_id,id_pos_train),:);  

    %% generate health degree for neg samples
    dt_neg.hdmd = zeros(size(dt_neg,1),1);
    dt_pos_test.hdmd = zeros(size(dt_pos_test,1),1);
    
    %% split valid positive disk into 10 groups by days
    dt_pos_train.groups = discretize(dt_pos_train.datenum,days_window);
    numLoops = length(days_window)-1;
    
    %% generate MD value(HD) for positive samples based on $numGroups$ MD spaces
    MD_value = zeros(size(dt_pos_train,1),numLoops+1);
    frac_samples_group = zeros(numLoops,1);     % ratio of number of samples in each group to the whole number of samples
    
    for i=1:numLoops
        dt_pos_group = dt_pos_train(dt_pos_train.groups==i,:);
        
        % tag invalid attribute leading to sigular matrix
        use_attr = ones(length(predictorNames),1);
        for j=1:length(predictorNames)
            use_attr(j) = length(unique(dt_pos_group{:,predictorNames(j)}));
        end
        
        % generate MD value for all samples in pos_train based on the MD
        % space built by pos_valid group
        MD_value(:,i) = mahal(double(dt_pos_train{:,predictorNames(use_attr~=1)}),double(dt_pos_group{:,predictorNames(use_attr~=1)}));  
        frac_samples_group(i) = size(dt_pos_group,1)/size(dt_pos_train,1);
    end   

    %% Generate weighted MD for each samples based on number of samples and number of disks in each group
    MD_value(:,(numLoops+1)) = zeros(size(MD_value,1),1);
    for i=1:numLoops
        MD_value(:,(numLoops+1)) = MD_value(:,(numLoops+1)) + (1./MD_value(:,i))*(1/days_window(i+1))*frac_samples_group(i);
    end
    dt_pos_train.hdmd = MD_value(:,(numLoops+1));
    

    %% combine pos and neg
    dt_pos_train.groups = [];
    dt_combine = [dt_pos_train;dt_pos_test;dt_neg];
    if ~need_oriorder
        smart = dt_combine;
    else
        smart = sortrows(dt_combine,'id');
    end
end