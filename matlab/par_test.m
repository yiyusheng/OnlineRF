a = 1:1:1000;
delete(gcp('nocreate'));
parpool('local',5);

parfor i=1:size(a)
    1+1;
end

%% 
idx = 1:10:75;
parfor (i=1:numel(idx),8)
    val = idx(i);
    test3t(i) = val*3;
end