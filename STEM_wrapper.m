function I_MS_fused = STEM_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, Opts)

%max_v = 2^double(L)-1;
max_v = 1;
I_MS_LR = double(I_MS_LR)./max_v;
I_PAN = double(I_PAN)./max_v;
PSF_G = sensorInf.PSF_G;
sampling_mode = 1; % conv + downsampling
conv_mode = Opts.global.conv_mode;
GNyqst_in = Opts.global.GNyqst_in;

I_MS = interpWrapper(I_MS_LR, ratio, sensorInf.upsampling);

% Histogram matching of PAN
% using the original I-component for statistical stability
I_PAN_LR = MTF_conv_sample(I_PAN, sensorInf, ratio, sampling_mode, conv_mode, GNyqst_in);
[I_org, alpha, ~] = generateIntensity(I_MS, I_MS_LR, I_PAN_LR);
I_PAN_LP = interpWrapper(I_PAN_LR,ratio, sensorInf.upsampling);
I_PAN_hm = hist_equalization(I_org, I_PAN, I_PAN_LP, Opts.prep.hm_mode);
I_PAN_hm_LR = MTF_conv_sample(I_PAN_hm, sensorInf, ratio, sampling_mode, conv_mode,GNyqst_in);
I_PAN_hm_LP = interpWrapper(I_PAN_hm_LR,ratio, sensorInf.upsampling);

% Generating D (Deblurring) entroy level variables
Deb_Opts.sigma = -1;
Deb_Opts.lambda = Opts.deb.lambda;
I_MS_deb = MSDeblurWrapper(I_MS, PSF_G, 0, Opts.global.deb_method, Deb_Opts);
[I_deb, ~, Lp_MS_deb] = generateIntensity(I_MS_deb, I_MS_LR, I_PAN_hm_LR);
MS_GNyq = getGNyqBySensor(sensorInf.sensor, size(I_MS, 3), 1);
GNyqst_P = sum(alpha(:).*MS_GNyq(:));
PSF_G_PAN = MTF_GNyq2PSF(GNyqst_P, 41, ratio);
% In the next line of code, use PSF_G instead of PSF_G_PAN to exactly match
% the DS experimental results in the paper.
I_PAN_hm_LP_deb = MSDeblurWrapper(I_PAN_hm_LP, PSF_G_PAN, 0, Opts.global.deb_method, Deb_Opts);
Opts.fusion.I_PAN_LP = I_PAN_hm_LP_deb;

Im = STEM_fusion(I_deb, I_PAN_hm, Opts.fusion);
% Calculate the gain factor
I_MS_fused = (I_MS_deb - Lp_MS_deb).*((Im)./(I_deb+eps)) + Lp_MS_deb;
I_MS_fused = I_MS_fused.*max_v;

