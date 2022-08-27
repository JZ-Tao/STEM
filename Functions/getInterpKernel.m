function Ker = getInterpKernel(ratio, type, dim, tap)
if ~exist('dim','var')
    dim = 1;
end
if ~exist('tap','var')
    tap = -1;
end
if type == 1 % type general. 
    L = tap-1;
    BaseCoeff = ratio.*fir1(L,1./ratio);
else % 拉格朗日？
    if (2^round(log2(ratio)) ~= ratio)
        error('Error: Only resize factors power of 2');
    end 
    % linear
    CDF_ODD{1} = 2.*[0.5 0.25];
    % cubic
    CDF_ODD{2} = 2.*[0.5 0.28125 0 -0.03125];
    
    CDF_ODD{3} = 2.*[0.5 0.29296875 0 -0.048828125 0 0.005859375];
    CDF_ODD{4} = 2.*[0.5 0.299072265625 0 -0.059814453125 0 0.011962890625 0 -0.001220703125];
    CDF_ODD{5} = 2.*[0.5 0.302810668945 0 -0.067291259765 0 0.017303466797 0 -0.003089904785 0 0.000267028808];
    CDF_ODD{6} = 2.*[0.5 0.305334091185 0 -0.072698593239 0 0.021809577942 0 -0.005192756653 0 0.000807762146 0 -0.000060081482]; 

    % NN
    CDF_EVEN{1} = {1};
    % linear
    CDF_EVEN{2} = [3/4 1/4];
    % quadratic
    CDF_EVEN{3} = [14/16 3/16 -1/16];
    % cubic
    CDF_EVEN{4} = [111/128 29/128 -9/128 -3/128];
    
    switch(tap)
        case 2
            CDF = CDF_EVEN{1}; 
        case 3
            CDF = CDF_ODD{1};
        case 4
            CDF = CDF_EVEN{2};
        case 6
            CDF = CDF_EVEN{3};            
        case 7 % bicubic(cat-mull rom). 跟matlab的区别是这个根据文献分析，考虑了offset问题。而matlab的如是下采样，还默认有anti-aliasing过程调整kernel系数
            CDF = CDF_ODD{2};
        case 8
            CDF = CDF_EVEN{4};
        case 11
            CDF = CDF_ODD{3};
        case 15
            CDF = CDF_ODD{4};
        case 19
            CDF = CDF_ODD{5};
        case 23
            CDF = CDF_ODD{6};
        otherwise
            CDF = CDF_ODD{6};
    end

    if mod(tap,2) == 0
        CDF = [fliplr(CDF) CDF];
    else
        CDF = [fliplr(CDF(mod(tap,2)+1:end)) CDF];
    end
    for z = 1:log2(ratio)-1
        CDF2 = upsample(CDF,2,0);
        CDF = conv(CDF2, CDF);
    end
    
    BaseCoeff = CDF;
%     CDF = [fliplr(CDF(2:end)) CDF];
%     BaseCoeff = CDF;
%     % 对图像的放大就是对卷积核的缩小
%     BaseCoeff = CDF;
%     offset = [2,1];
% 
%     BaseCoeff2 = BaseCoeff(offset(1):2:end);
% 
%     I1LRU(offset(2):2:end,offset(2):2:end,:) = I_Interpolated;
%     end    
end

if dim == 2
    BaseCoeff = conv2(BaseCoeff',BaseCoeff);
%     if type ~= 1    
%         offset = [2,1];
%         BaseCoeff2 = BaseCoeff(offset(2):2:end,offset(2):2:end,:);
%         BaseCoeff3 = conv2(BaseCoeff2',BaseCoeff);
%     end
end

Ker = BaseCoeff;