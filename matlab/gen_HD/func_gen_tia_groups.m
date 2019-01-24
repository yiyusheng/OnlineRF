% generate TIA groups
function arr_group = func_gen_tia_groups(arr,itv,upper)
    if nargin < 3
        dur = min(arr):itv:max(arr);
    else
        dur = [min(arr):itv:upper,max(arr)];
    end
    
    arr_group = discretize(arr,dur,dur(1:end-1));
end