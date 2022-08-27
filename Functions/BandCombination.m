function I = BandCombination(I_MS, I_PAN, I_MS_LR, I_PAN_LR, ratio, type)
using_LR = 1;
n_band = size(I_MS, 3);
if strcmp(type, 'avg')
    I = sum(I_MS,3)/n_band;
%     P = sum(imageHR,3)/n_band;
    return;
end
if strcmp(type, 'H')
%     vCorr = zeros(1, size(I_MS,3));
%     for ii = 1 : size(I_MS,3)
%         b = I_MS(:,:,ii);
%         vCorr(ii) = min(b(:));
%     end
% 
%     v3Corr = zeros(1,1,size(I_MS,3));
%     v3Corr(1,1,:) = vCorr;
    
    v_Lp_MS = reshape(min(im2mat(I_MS),[],2), [1,1,size(I_MS,3)]);
    Lp_MS = repmat(v_Lp_MS, [size(I_MS,1) size(I_MS,2)]);

    %imageHR = double(I_PAN);
    %I_MS = double(I_MS);

    %%% Intensity
    %imageHR_LP = LPfilterGauss(imageHR,ratio);

    h = estimation_alpha(I_MS_LR,I_PAN_LR,'global');
    %h = estimation_alpha(I_MS,imageHR_LP,'global');
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
    [b,bint,r,rint,stats] = regress(vecP, [vecMS_LR ones(numel(imP), 1)]);
    disp('R2:');stats(1)
    I = reshape(sum([vecMS ones(size(I_MS, 1)*size(I_MS, 2), 1)]*b, 2), [size(I_MS, 1), size(I_MS, 2)]);
end

%     W = ones(1, n_band)/n_band;
%     I = zeros(size(PAN));