function I_MS_fused = STEM_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, Opts)

%max_v = 2^double(L)-1;
max_v = 1;

I_MS_LR = double(I_MS_LR)./max_v;
I_PAN = double(I_PAN)./max_v;

% using_FE = 1;
% FE_method = 'bruse';
% if using_FE
%     [PSF_e, GNyq_e] = FE_Wrapper(I_MS_LR,I_PAN,ratio, sensorInf,FE_method);
%     sensorInf.PSF_G = PSF_e;
% end
PSF_G = sensorInf.PSF_G;
sampling_mode = 1; % conv + downsampling
conv_mode = Opts.global.conv_mode;
GNyqst_in = Opts.global.GNyqst_in;
I_MS = interpWrapper(I_MS_LR, ratio, sensorInf.upsampling);
I_PAN_LR = MTF_conv_sample(I_PAN, sensorInf, ratio, sampling_mode, conv_mode, GNyqst_in);

[I_org, alpha, ~] = generateIntensity(I_MS, I_MS_LR, I_PAN_LR);

% v_Lp_MS = reshape(min(im2mat(I_MS),[],2), [1,1,size(I_MS,3)]);
% Lp_MS = repmat(v_Lp_MS, [size(I_MS,1) size(I_MS,2)]);
% I_MS_LR0 = zeros(size(I_MS_LR));
% for i = 1:size(I_MS_LR,3)
%     I_MS_LR0(:,:,i) = I_MS_LR(:,:,i) - mean2(I_MS_LR(:,:,i));
% end
% h = estimation_alpha(I_MS_LR0, I_PAN_LR - mean2(I_PAN_LR),'global');
% alpha(1,1,:) = h;
% A = repmat(alpha,[size(I_MS,1) size(I_MS,2) 1]);
% I_org = sum((I_MS - Lp_MS) .* A, 3); 

Deb_Opts.sigma = -1;
Deb_Opts.lambda = Opts.deb.lambda;
I_MS_deb = MSDeblurWrapper(I_MS, PSF_G, 0, Opts.global.deb_method, Deb_Opts);
v_Lp_MS_deb = reshape(min(im2mat(I_MS_deb),[],2), [1,1,size(I_MS,3)]);
Lp_MS_deb = repmat(v_Lp_MS_deb, [size(I_MS_deb,1) size(I_MS_deb,2)]);
I_PAN_LP = interpWrapper(I_PAN_LR,ratio, sensorInf.upsampling);

I_PAN_hm = hist_equalization(I_org, I_PAN, I_PAN_LP, Opts.prep.hm_mode);
I_PAN_hm_LR = MTF_conv_sample(I_PAN_hm, sensorInf, ratio, sampling_mode, conv_mode,GNyqst_in);

I_PAN_hm_LP = interpWrapper(I_PAN_hm_LR,ratio, sensorInf.upsampling);
% Deblurring (D) entroy level variables
I_deb = sum((I_MS_deb - Lp_MS_deb) .* repmat(alpha,[size(I_MS,1) size(I_MS,2) 1]), 3);
%[I_deb, alpha2, Lp_MS_deb] = generateIntensity(I_MS_deb, I_MS_LR, I_PAN_hm_LR);
% PSF_G_PAN2 = MTF_GNyq2PSF(GNyqst_in, 41, ratio);
MS_GNyq = getGNyqBySensor(sensorInf.sensor, size(I_MS, 3), 1);
GNyqst_P = sum(alpha(:).*MS_GNyq(:));

PSF_G_PAN = MTF_GNyq2PSF(GNyqst_P, 41, ratio);
I_PAN_hm_LP_deb = MSDeblurWrapper(I_PAN_hm_LP, PSF_G_PAN, 0, Opts.global.deb_method, Deb_Opts);
Opts.fusion.I_PAN_LP = I_PAN_hm_LP_deb;

Im = STEM_fusion(I_deb, I_PAN_hm, Opts.fusion);
% Calculate the gain factor
I_MS_fused = (I_MS_deb - Lp_MS_deb).*((Im)./(I_deb+eps)) + Lp_MS_deb;
I_MS_fused = I_MS_fused.*max_v;

