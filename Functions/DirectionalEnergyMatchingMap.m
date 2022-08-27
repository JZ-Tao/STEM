%%
% Author: jingzhe tao. 
% 2019.4.8
% Implementation of directinal matching degree calculation.
% Input:
%   D1 : The 1st 2D data.
%   D2 : The 2rd 2D data.
%   Mask(optional): the mask matrix.
% Output:
%   E1 : The engery map of D1.
%   E2 : The engery map of D2.
%   M  : The matching map.
function [E1, E2, E12, M] = DirectionalEnergyMatchingMap(D1, D2, Mask)

if size(D1) ~= size(D2)
    error('Data should be in the same size.');
end;

if ~exist('Mask', 'var')
    Mask = [1,1,1;1,1,1;1,1,1];
end

%Mask = Mask/sum(Mask(:));   % Normalize

Kernel = Mask.^2;
D1D1 = D1.*D1;
D2D2 = D2.*D2;
D1D2 = D1.*D2;

for i = 1:size(D1D2,3)
    E1(:,:,i) = conv2(D1D1(:,:,i), Kernel, 'same');
    E2(:,:,i) = conv2(D2D2(:,:,i), Kernel, 'same');
    E12(:,:,i) = (conv2(D1D2(:,:,i), Kernel, 'same'));
end

M = (2*E12)./(E1+E2+eps);
