% get smart_model1_*.mat from smart_model1_*.csv
% fid = fopen('smart_model1_1.csv');
function [ smart_model ] = get_smartmodel1( fid )

varnames = textscan(fid, '%q%q%q%q%q%q %q%q%q%q%q%q%q%q%q%q%q%q %q%q%q%q%q%q%q%q%q%q%q%q %q%q%q%q%q%q%q%q%q%q%q%q %q%q%q%q%q%q%q%q%q%q%q%q', 1, 'delimiter', ',', 'CollectOutput', 1);
vars = textscan(fid, '%q%{yyyy-MM-dd}D%q%q%d8%d8 %d32%d64%d32%d64%d32%d64%d32%d64%d32%d64%d32%d64 %d32%d64%d32%d64%d32%d64%d32%d64%d32%d64%d32%d64 %d32%d64%d32%d64%d32%d64%d32%d64%d32%d64%d32%d64 %d32%d64%d32%d64%d32%d64%d32%d64%d32%d64%d32%d64', 'delimiter', ',');
fclose(fid);
names = {};
for i = 2:54
    names{i-1} = varnames{1,1}{i};
end
smart_model = table(vars{1,2}, vars{1,3}, vars{1,4}, vars{1,5}, vars{1,6}, vars{1,7}, vars{1,8}, vars{1,9}, vars{1,10}, ...
vars{1,11}, vars{1,12}, vars{1,13}, vars{1,14}, vars{1,15}, vars{1,16}, vars{1,17}, vars{1,18}, vars{1,19}, vars{1,20}, ...
vars{1,21}, vars{1,22}, vars{1,23}, vars{1,24}, vars{1,25}, vars{1,26}, vars{1,27}, vars{1,28}, vars{1,29}, vars{1,30}, ...
vars{1,31}, vars{1,32}, vars{1,33}, vars{1,34}, vars{1,35}, vars{1,36}, vars{1,37}, vars{1,38}, vars{1,39}, vars{1,40}, ...
vars{1,41}, vars{1,42}, vars{1,43}, vars{1,44}, vars{1,45}, vars{1,46}, vars{1,47}, vars{1,48}, vars{1,49}, vars{1,50}, ...
vars{1,51}, vars{1,52}, vars{1,53}, vars{1,54} ,'VariableNames', names);

end
% smart_model1_1 = get_smartmodel( fid );
% save('smart_model1_1.mat' ,'smart_model1_1');