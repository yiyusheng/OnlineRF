function [ res ] = StaySame( a )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
a = a(a ~= -1);
if size(unique(a)) == 1
    res = a(1);
else
    res = -1;
end

end

