function [ smart ] = scale( smart )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

smart.smart_1_normalized = double(smart.smart_1_normalized - 100) / 20;

tmp = double(smart.smart_4_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 1500) = 2 + tmp(tmp > 1000 & tmp <= 1500) / 1500;
tmp(tmp > 1500) = 3;
smart.smart_4_raw = tmp;

smart.smart_5_normalized = double(smart.smart_5_normalized - 50) / 50;
tmp = double(smart.smart_5_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_5_raw = tmp;

smart.smart_7_normalized = double(smart.smart_7_normalized - 0) / 100;
smart.smart_9_raw = double(smart.smart_9_raw) / 43800; 

tmp = double(smart.smart_12_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_12_raw = tmp;

smart.smart_183_normalized = double(smart.smart_183_normalized - 0) / 100;
tmp = double(smart.smart_183_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_183_raw = tmp;

smart.smart_184_normalized = double(smart.smart_184_normalized - 0) / 100;
smart.smart_184_raw = double(smart.smart_184_raw - 0) / 100;

smart.smart_187_normalized = double(smart.smart_187_normalized - 0) / 100;
tmp = double(smart.smart_187_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_187_raw = tmp;

tmp = double(smart.smart_188_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 2100) = 1 + tmp(tmp > 100 & tmp <= 2100) / 2100;
tmp(tmp > 2100 & tmp <= 6.6e+4) = 2 + tmp(tmp > 2100 & tmp <= 6.6e+4) / 6.6e+4;
tmp(tmp > 6.6e+4 & tmp <= 4e+5) = 3 + tmp(tmp > 6.6e+4 & tmp <= 4e+5) / 4e+5;
tmp(tmp > 4e+5 & tmp <= 9e+9) = 4 + tmp(tmp > 4e+5 & tmp <= 9e+9) / 9e+9;
tmp(tmp > 9e+9 & tmp <= 1.4e+11) = 5 + tmp(tmp > 9e+9 & tmp <= 1.4e+11) / 1.4e+11;
tmp(tmp > 1.4e+11 & tmp <= 1e+14) = 6 + tmp(tmp > 1.4e+11 & tmp <= 1e+14) / 1e+14;
tmp(tmp > 1e+14) = 7;
smart.smart_188_raw = tmp;

smart.smart_189_normalized = double(smart.smart_189_normalized - 0) / 100;
tmp = double(smart.smart_189_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_189_raw = tmp;

smart.smart_190_raw = double(smart.smart_190_raw - 12) / 32;

tmp = double(smart.smart_192_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 1500) = 2 + tmp(tmp > 1000 & tmp <= 1500) / 1500;
tmp(tmp > 1500) = 3;
smart.smart_192_raw = tmp;

smart.smart_193_normalized = double(smart.smart_193_normalized - 0) / 100;

smart.smart_197_normalized = double(smart.smart_197_normalized - 0) / 100;
tmp = double(smart.smart_197_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_197_raw = tmp;

smart.smart_198_normalized = double(smart.smart_198_normalized - 0) / 100;
tmp = double(smart.smart_198_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.smart_198_raw = tmp;

tmp = double(smart.smart_199_raw);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 12000) = 2 + tmp(tmp > 1000 & tmp <= 12000) / 12000;
tmp(tmp > 12000) = 3;
smart.smart_199_raw = tmp;

smart.S5nChange = double(smart.S5nChange - 0) / 10;
tmp = double(smart.S5rChange);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.S5rChange = tmp;

smart.S7nChange = double(smart.S7nChange - 0) / 50;
smart.S183nChange = double(smart.S183nChange - 0) / 100;
tmp = double(smart.S183rChange);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.S183rChange = tmp;

smart.S184nChange = double(smart.S184nChange - 0) / 20;
smart.S187nChange = double(smart.S187nChange - 0) / 100;
tmp = double(smart.S187rChange);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.S187rChange = tmp;

smart.S189nChange = double(smart.S189nChange - 0) / 100;
tmp = double(smart.S189rChange);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.S189rChange = tmp;

smart.S197nChange = double(smart.S197nChange - 0) / 20;
tmp = double(smart.S197rChange);
tmp(tmp <= 100) = tmp(tmp <= 100) / 100;
tmp(tmp > 100 & tmp <= 1000) = 1 + tmp(tmp > 100 & tmp <= 1000) / 1000;
tmp(tmp > 1000 & tmp <= 10000) = 2 + tmp(tmp > 1000 & tmp <= 10000) / 10000;
tmp(tmp > 10000 & tmp <= 65536) = 3 + tmp(tmp > 10000 & tmp <= 65536) / 65536;
tmp(tmp > 65536) = 4;
smart.S197rChange = tmp; 

end

