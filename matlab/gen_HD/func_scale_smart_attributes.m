function dt = func_scale_smart_attributes(dt,predictorNames)
    for i = 1:length(predictorNames)
        max_s = max(dt.(predictorNames{i}));
        min_s = min(dt.(predictorNames{i}));
        means_s = mean(dt.(predictorNames{i}));
        std_s = std(double(dt.(predictorNames{i})));
%         dt.(predictorNames{i}) = double(dt.(predictorNames{i})-min_s)/double(max_s-min_s);
        dt.(predictorNames{i}) = double(dt.(predictorNames{i})-means_s)/std_s;
    end
end