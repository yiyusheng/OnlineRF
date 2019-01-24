function arr = func_simplify_smart_attributes(arr)
    arr = strrep(arr,'smart_','s');
    arr = strrep(arr,'_raw','r');
    arr = strrep(arr,'_normalized','n');
end