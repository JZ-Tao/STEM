function I = BandCombination(I_MS, I_PAN, I_MS_LR, I_PAN_LR, ratio, type)
using_LR = 1;
n_band = size(I_MS, 3);
if strcmp(type, 'avg')
    I = sum(I_MS,3)/n_band;
    return;
end
if strcmp(type, 'H')
    v_Lp_MS = reshape(min(im2mat(I_MS),[],2), [1,1,size(I_MS,3)]);
    Lp_MS = repmat(v_Lp_MS, [size(I_MS,1) size(I_MS,2)]);
    h = estimation_alpha(I_MS_LR,I_PAN_LR,'global');
    alpha(1,1,:) = h;
    I = sum((I_MS - Lp_MS) .* repmat(alpha,[size(I_MS,1) size(I_MS,2) 1]),3); 
end
if strcmp(type, 'pca')
    
end
% Global Linear Regress
if strcmp(type, 'GLR')
    if using_LR
        imP = I_PAN_LR;
        imMS_LR = I_MS_LR;
    else
        imP = I_PAN;
        imMS_LR = I_MS;
    end
    vecP = reshape(imP,[numel(imP) 1]);
    vecMS_LR = reshape(imMS_LR,[size(imMS_LR, 1)*size(imMS_LR, 2) n_band]);
    vecMS = reshape(I_MS,[size(I_MS, 1)*size(I_MS, 2) n_band]);
    [b,~,~,~,~] = regress(vecP, [vecMS_LR ones(numel(imP), 1)]);
    I = reshape(sum([vecMS ones(size(I_MS, 1)*size(I_MS, 2), 1)]*b, 2), [size(I_MS, 1), size(I_MS, 2)]);
end