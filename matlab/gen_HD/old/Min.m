function [ res ] = Min( a )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
a = a(a ~= -1);
if isempty(a)
    res = -1;
else
    res = min(a);
end
end

