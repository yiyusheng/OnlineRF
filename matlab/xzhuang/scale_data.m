
function [result] = scale_data(smart, type)
%UNTITLED9 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
smart_std = [9489.74170296581,473.754575930894,3736.00889750191,5.32539552267130,16.9772867941568,7.42844942859652,4.10739887369018,...
    16.8434129832306,1051.90850728439,1.35737693611740,2226.57012792072,33.3237187466014,3736.00889750191,993.573185872739,...
    0.482322965564852,7.14462855965499,1157710897747.76,3596.67150685507,20.4304930689808,1.35737693611740,27.9307013108362,...
    0.137327775006962,39481322788.0449,18.5811656238119,9.57887025100348,104307.065452103,3.71552227767870,6.09247971066722,...
    6.09247971066722,71041006.3684383,0,0,0,0,0,3.71552227767870,3.71552227767870,0,0,0,3.71552227767870,0,0,81682372799815.1,...
    0,17323673054643.3,0,86921441652628.7];
smart_mean = [2465.20392345154,45.4581246999108,252.690856711709,114.514438576034,35.6789903285548,82.3745112833528,80.4675903697099,...
    35.4223197750189,81.1720968516359,0.0582344468070512,124.337265930448,50.8910762055011,252.690856711709,141.452705946910,...
    92.0316894162837,98.2171616708965,101168050188.785,17551.4749982852,94.6020989093902,99.9417655531930,86.0372453529049,...
    99.9977364702655,48937861870.2473,93.7762535153303,10.6614308251595,117648.645448933,25.3992729268125,99.4881679127512,...
    99.4881679127512,121439174.908704,0,100,100,0,100,74.6007270731875,25.3992729268125,100,0,100,25.3992729268125,200,100,...
    138891162976093,100,4161896080011.48,100,131049545924865];
VariableNames = smart.Properties.VariableNames;

% new from york
% result = smart;
% for i = 1:size(smart, 2)
%     if type == 1 & ~ismember(VariableNames(i),{'sn','sn_id','model','date','fname'})
%         result{:, i} = double(smart{:, i});
%     end
%     if type == 2 & ~ismember(VariableNames(i),{'sn','sn_id','model','date','fname'})
%         result{:, i} = (double(smart{:, i}) - smart_mean(i)) / smart_std(i);
%     end
% end
% result.Properties.VariableNames = VariableNames;



% old from xzhuang
result(:, 1) = smart(:,1);
for i = 2:size(smart, 2)
    if type == 1 
        result{:, i} = double(smart{:, i});
    end
    if type == 2 
        result{:, i} = (double(smart{:, i}) - smart_mean(i)) / smart_std(i);
    end
end
result.Properties.VariableNames = VariableNames;
end

