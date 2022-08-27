%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           interp23tap interpolates the image I_Interpolated using a polynomial with 23 coefficients interpolator. 
% 
% Interface:
%           I_Interpolated = interp23tap(I_Interpolated,ratio)
%
% Inputs:
%           I_Interpolated: Image to interpolate;
%           ratio:          Scale ratio between MS and PAN. Pre-condition: Resize factors power of 2;
%
% Outputs:
%           I_Interpolated: Interpolated image.
% 
% References:
%           [Aiazzi02]      B. Aiazzi, L. Alparone, S. Baronti, and A. Garzelli, Context-driven fusion of high spatial and spectral resolution images based on
%                           oversampled multiresolution analysis,?IEEE Transactions on Geoscience and Remote Sensing, vol. 40, no. 10, pp. 2300?312, October
%                           2002.
%           [Aiazzi13]      B. Aiazzi, S. Baronti, M. Selva, and L. Alparone, Bi-cubic interpolation for shift-free pan-sharpening,?ISPRS Journal of Photogrammetry
%                           and Remote Sensing, vol. 86, no. 6, pp. 65?6, December 2013.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I_Interpolated = interpDefault(I_Interpolated,ratio,tap, offset)
if ~exist('tap','var')
    tap = -1;
end
if ~exist('offset','var')
    offset = [1,0];
end
if (2^round(log2(double(ratio))) ~= ratio)
    disp('Error: Only resize factors power of 2');
    return;
end 

[r,c,b] = size(I_Interpolated);
BaseCoeff = getInterpKernel(2, 2, 1, tap);
% CDF3_23{1} = 2.*[0.5 0.25];
% CDF3_23{2} = 2.*[0.5 0.28125 0 -0.03125];
% CDF3_23{3} = 2.*[0.5 0.29296875 0 -0.048828125 0 0.005859375];
% CDF3_23{4} = 2.*[0.5 0.299072265625 0 -0.059814453125 0 0.011962890625 0 -0.001220703125];
% CDF3_23{5} = 2.*[0.5 0.302810668945 0 -0.067291259765 0 0.017303466797 0 -0.003089904785 0 0.000267028808];
% CDF3_23{6} = 2.*[0.5 0.305334091185 0 -0.072698593239 0 0.021809577942 0 -0.005192756653 0 0.000807762146 0 -0.000060081482]; 
% 
% switch(tap)
%     case 3
%         CDF = CDF3_23{1};
%     case 7 % bicubic(cat-mull rom). 跟matlab的区别是这个根据文献分析，考虑了offset问题。而matlab的如是下采样，还默认有anti-aliasing过程调整kernel系数
%         CDF = CDF3_23{2};
%     case 11
%         CDF = CDF3_23{3};
%     case 15
%         CDF = CDF3_23{4};
%     case 19
%         CDF = CDF3_23{5};
%     case 23
%         CDF = CDF3_23{6};
%     otherwise
%         CDF = CDF3_23{6};
% end        
% 
% CDF = [fliplr(CDF(2:end)) CDF];
% BaseCoeff = CDF;
first = 1;
%BaseCoeff2 = conv2(BaseCoeff',BaseCoeff);
% ksz = floor(size(BaseCoeff,2)/2);
for z = 1 : log2(ratio)

    I1LRU = zeros((2^z) * r, (2^z) * c, b);
    
    if first
        I1LRU(1+offset(1):2:end,1+offset(1):2:end,:) = I_Interpolated;
        %I1LRU(2:2:end,2:2:end,:) = I_Interpolated;
        first = 0;
    else
        I1LRU(1+offset(2):2:end,1+offset(2):2:end,:) = I_Interpolated;
    end

     for ii = 1 : b
        t = I1LRU(:,:,ii); 
        %I1LRU2(:,:,ii) = imfilter(t,BaseCoeff2,'circular'); 
        t = imfilter(t',BaseCoeff,'circular'); 
        I1LRU(:,:,ii) = imfilter(t',BaseCoeff,'circular'); 
%         t = imfilter(t',BaseCoeff); 
%         I1LRU(:,:,ii) = imfilter(t',BaseCoeff); 
    end

    I_Interpolated = I1LRU;
    
end

end