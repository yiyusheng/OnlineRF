
if isempty(gcp('nocreate'))
    CoreNum=3;
    parpool('local', CoreNum)
end

disknum = size(disk_model1,1);
tic;
parfor i = 1:disknum
    disk = disk_model1(i, :);
    smarts = disk.smarts{1};
    
    smarts(:, {
        'smart_1_raw',...           % Read Error Rate????
        'smart_3_raw',...           % Spin-Up Time???0
        'smart_4_normalized',...    % Start/Stop Count?????100????99
        'smart_4_raw',...           % Start/Stop Count?????????
        'smart_7_raw',...           % Seek Error Rate????
        'smart_9_normalized',...    % Power-On Hours???
        'smart_10_normalized',...   % Spin Retry Count???100
        'smart_10_raw',...          % Spin Retry Count???0
        'smart_12_normalized',...   % Power Cycle Count?????100??????100
        'smart_190_normalized',...  % Temperature???
        'smart_191_normalized',...  % G-sense Error Rate???100
        'smart_191_raw',...         % G-sense Error Rate???0
        'smart_192_normalized',...  % Unsafe Shutdown Count???100
        'smart_193_raw',...         % Load Cycle Count????????
        'smart_194_normalized',...  % Temperature???
        'smart_194_raw',...         % Temperature???
        'smart_198_normalized',...  %(Offline) Uncorrectable Sector Count??????
        'smart_199_normalized',...  % UltraDMA CRC Error Count?????100????99
        'smart_240_raw',...         % Head Flying Hours?????
        'smart_241_normalized',...  % Total LBAs Written???100
        'smart_241_raw',...         % Total LBAs Written????
        'smart_242_normalized',...  % Total LBAs Read???100
        'smart_242_raw',...         % Total LBAs Read????
        }) = [];
    
    disk.smarts{1} = smarts;
    disk_model1(i, :) = disk;
    fprintf('%d\n',i);
end;toc;
