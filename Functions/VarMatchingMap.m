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
function [V1, V2, V12] = VarMatchingMap(D1, D2, Mask)

if size(D1) ~= size(D2)
    error('Data should be in the same size.');
end;

if ~exist('Mask', 'var')
    Mask = [1,1,1;1,1,1;1,1,1];
end

%Mask = Mask/sum(Mask(:));   % Normalize
%np = size(D1(:,:,1), 1)*size(D1(:,:,1), 2);
UMask = [1,1,1;1,1,1;1,1,1];
np = length(UMask(:));
U1 = imfilter(D1, UMask, 'replicate', 'same')./np;
U2 = imfilter(D2, UMask, 'replicate', 'same')./np;
DU1 = D1-U1;
DU2 = D2-U2;
V1 = imfilter(DU1.^2, UMask, 'replicate', 'same')./np;
V2 = imfilter(DU2.^2, UMask, 'replicate', 'same')./np;
V12 = imfilter(DU1.*DU2, UMask, 'replicate', 'same')./np;

