function [ Res ] = RMSE( V1,V2 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

N = length(V1);
X = (V1-V2).^2;

Res = sqrt(1/N*sum(X));

end

