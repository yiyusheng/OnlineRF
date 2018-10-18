if isempty(gcp('nocreate'))
    CoreNum=3;
    parpool('local', CoreNum)
end

disk_model1.S3nStaysame = disk_model1.samplenum;
disk_model1.S3nWorst = disk_model1.samplenum;

disk_model1.S5nStaysame = disk_model1.samplenum;
disk_model1.S5nWorst = disk_model1.samplenum;

disk_model1.S5rStaysame = disk_model1.samplenum;
disk_model1.S5rWorst = disk_model1.samplenum;

disk_model1.S7nStaysame = disk_model1.samplenum;
disk_model1.S7nWorst = disk_model1.samplenum;

disk_model1.S183nStaysame = disk_model1.samplenum;
disk_model1.S183nWorst = disk_model1.samplenum;

disk_model1.S183rStaysame = disk_model1.samplenum;
disk_model1.S183rWorst = disk_model1.samplenum;

disk_model1.S184nStaysame = disk_model1.samplenum;
disk_model1.S184nWorst = disk_model1.samplenum;

disk_model1.S184rStaysame = disk_model1.samplenum;
disk_model1.S184rWorst = disk_model1.samplenum;

disk_model1.S187nStaysame = disk_model1.samplenum;
disk_model1.S187nWorst = disk_model1.samplenum;

disk_model1.S187rStaysame = disk_model1.samplenum;
disk_model1.S187rWorst = disk_model1.samplenum;

disk_model1.S188nStaysame = disk_model1.samplenum;
disk_model1.S188nWorst = disk_model1.samplenum;

disk_model1.S188rStaysame = disk_model1.samplenum;
disk_model1.S188rWorst = disk_model1.samplenum;

disk_model1.S189nStaysame = disk_model1.samplenum;
disk_model1.S189nWorst = disk_model1.samplenum;

disk_model1.S189rStaysame = disk_model1.samplenum;
disk_model1.S189rWorst = disk_model1.samplenum;

disk_model1.S192rStaysame = disk_model1.samplenum;
disk_model1.S192rWorst = disk_model1.samplenum;

disk_model1.S197nStaysame = disk_model1.samplenum;
disk_model1.S197nWorst = disk_model1.samplenum;

disk_model1.S197rStaysame = disk_model1.samplenum;
disk_model1.S197rWorst = disk_model1.samplenum;

disk_model1.S198rStaysame = disk_model1.samplenum;
disk_model1.S198rWorst = disk_model1.samplenum;

disk_model1.S199rStaysame = disk_model1.samplenum;
disk_model1.S199rWorst = disk_model1.samplenum;

disk_model1.S240nStaysame = disk_model1.samplenum;
disk_model1.S240nWorst = disk_model1.samplenum;

disknum = size(disk_model1,1);
tic;
parfor i = 1:disknum
    disk = disk_model1(i, :);
    smarts = disk.smarts{1};
    
    smarts(smarts.smart_3_normalized == -1, :) = [];
    
    disk.smarts{1} = smarts;
    disk.samplenum = size(smarts, 1);
    
    if size(smarts, 1) ~= 0
        disk.S3nStaysame = StaySame(smarts.smart_3_normalized);
        disk.S3nWorst = Min(smarts.smart_3_normalized);

        disk.S5nStaysame = StaySame(smarts.smart_5_normalized);
        disk.S5nWorst = Min(smarts.smart_5_normalized);

        disk.S5rStaysame = StaySame(smarts.smart_5_raw);
        disk.S5rWorst = max(smarts.smart_5_raw);

        disk.S7nStaysame = StaySame(smarts.smart_7_normalized);
        disk.S7nWorst = Min(smarts.smart_7_normalized);

        disk.S183nStaysame = StaySame(smarts.smart_183_normalized);
        disk.S183nWorst = Min(smarts.smart_183_normalized);

        disk.S183rStaysame = StaySame(smarts.smart_183_raw);
        disk.S183rWorst = max(smarts.smart_183_raw);

        disk.S184nStaysame = StaySame(smarts.smart_184_normalized);
        disk.S184nWorst = Min(smarts.smart_184_normalized);

        disk.S184rStaysame = StaySame(smarts.smart_184_raw);
        disk.S184rWorst = max(smarts.smart_184_raw);

        disk.S187nStaysame = StaySame(smarts.smart_187_normalized);
        disk.S187nWorst = Min(smarts.smart_187_normalized);

        disk.S187rStaysame = StaySame(smarts.smart_187_raw);
        disk.S187rWorst = max(smarts.smart_187_raw);

        disk.S188nStaysame = StaySame(smarts.smart_188_normalized);
        disk.S188nWorst = Min(smarts.smart_188_normalized);

        disk.S188rStaysame = StaySame(smarts.smart_188_raw);
        disk.S188rWorst = max(smarts.smart_188_raw);

        disk.S189nStaysame = StaySame(smarts.smart_189_normalized);
        disk.S189nWorst = Min(smarts.smart_189_normalized);

        disk.S189rStaysame = StaySame(smarts.smart_189_raw);
        disk.S189rWorst = max(smarts.smart_189_raw);

        disk.S192rStaysame = StaySame(smarts.smart_192_raw);
        disk.S192rWorst = max(smarts.smart_192_raw);

        disk.S197nStaysame = StaySame(smarts.smart_197_normalized);
        disk.S197nWorst = Min(smarts.smart_197_normalized);

        disk.S197rStaysame = StaySame(smarts.smart_197_raw);
        disk.S197rWorst = max(smarts.smart_197_raw);

        disk.S198rStaysame = StaySame(smarts.smart_198_raw);
        disk.S198rWorst = max(smarts.smart_198_raw);

        disk.S199rStaysame = StaySame(smarts.smart_199_raw);
        disk.S199rWorst = max(smarts.smart_199_raw);

        disk.S240nStaysame = StaySame(smarts.smart_240_normalized);
        disk.S240nWorst = Min(smarts.smart_240_normalized);
    end
    
    disk_model1(i, :) = disk;
    fprintf('%d\n',i);
end;toc;

disk_model1(disk_model1.samplenum == 0, :) = [];
save('disk_model1_1107.mat', 'disk_model1', '-v7.3');
disk_model1_1108 = disk_model1(:, [1:7, 9:48]);
save('disk_model1_1108.mat', 'disk_model1_1108');