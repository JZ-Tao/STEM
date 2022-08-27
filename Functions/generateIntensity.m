function [I, alpha, Lp_MS] = generateIntensity(I_MS, I_MS_LR, I_PAN_LR)

%I_PAN_LR = downsampleWrapper(LPfilterGauss(I_PAN,ratio),ratio, sensorInf.downsampling);
%I_PAN_LP = interpWrapper(I_PAN_LR,ratio, sensorInf.upsampling);

v_Lp_MS = reshape(min(im2mat(I_MS),[],2), [1,1,size(I_MS,3)]);
Lp_MS = repmat(v_Lp_MS, [size(I_MS,1) size(I_MS,2)]);
I_MS_LR0 = zeros(size(I_MS_LR));
for i = 1:size(I_MS_LR,3)
    I_MS_LR0(:,:,i) = I_MS_LR(:,:,i) - mean2(I_MS_LR(:,:,i));
end
h = estimation_alpha(I_MS_LR0, I_PAN_LR - mean2(I_PAN_LR),'global');
alpha(1,1,:) = h;
A = repmat(alpha,[size(I_MS,1) size(I_MS,2) 1]);
I = sum((I_MS - Lp_MS) .* A, 3); 