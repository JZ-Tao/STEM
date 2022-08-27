
function I_Filtered = MTF_conv_sample(X, sensorInf, ratio, sampling_mode, conv_mode, GNyqst_in)
% sampling_mode, 0: no sampling. 1: downsampling only. 2: down-up sampling
% In the original implement of pan-sharpening toolbox 2015, sampling_mode = 0.
% In GLPs, sampling_mode = 2;

if ~exist('sampling_mode','var')
    sampling_mode = 2;
end
if ~exist('conv_mode','var')
    conv_mode = 2;
end
if ~exist('GNyqst_in','var')
    GNyqst_in = 0.3;
end

X_LP = zeros(size(X));
n_band = size(X,3);

% PAN or I
if n_band == 1 
    PSF_MS = sensorInf.PSF_G;
    switch conv_mode 
        case 1 % Averaging all MS PSF
            PSF_G = sum(PSF_MS, 3)./size(PSF_MS, 3);
        case 2 % MTF of MS 1st band
            PSF_G = PSF_MS(:,:,1);
        case 3 % MTF Nyqust == 0.3
            PSF_G = MTF_GNyq2PSF(0.3, 41, ratio);
        case 4 % PAN MTF. Not reasonable.
            PSF_G = Blur_Kernel(1, sensorInf.sensor, ratio, 0);
        case 5 % imresize bicubic (tap 7). Not reasonable.
            I_Filtered = imresize(X,1/ratio); return;
        case 6 % Calc. PSF by the mean of all MS MTF Nyqust
            avg_GNyq = mean(getGNyqBySensor(sensorInf.sensor, size(PSF_MS, 3), 1));
            PSF_G = MTF_GNyq2PSF(avg_GNyq, 41, ratio);
        case 7 % Starck Murtagh filter
            I_Filtered = LPfilterPlusDec(X,ratio); return;
        case 8 % Calc. PSF by the median of all MS MTF Nyqust
            avg_GNyq = median(getGNyqBySensor(sensorInf.sensor, size(PSF_MS, 3), 1));
            PSF_G = MTF_GNyq2PSF(avg_GNyq, 41, ratio); 
        case 9 % Calc. PSF by GNyqst_in
            PSF_G = MTF_GNyq2PSF(GNyqst_in, 41, ratio);
    end
else
    PSF_G = sensorInf.PSF_G;
    if size(PSF_G, 3) == 1
        PSF_G = repmat(PSF_G, [1,1,n_band]);
    end
end

for ii = 1 : n_band
    X_LP(:,:,ii) = imfilter(X(:,:,ii),(PSF_G(:,:,ii)),'replicate');
end
if sampling_mode >= 1
    X_LP = downsampleWrapper(X_LP, ratio, sensorInf.downsampling);
end
if sampling_mode == 2
    X_LP = interpWrapper(X_LP,ratio, sensorInf.upsampling);
end
if sampling_mode == 3
    tmp = X_LP;
    X_LP = zeros(size(X));
    offset = sensorInf.downsampling.offset;
    X_LP(1+offset:ratio:end,1+offset:ratio:end,:) = tmp;
    for ii = 1:size(X_LP,3)
        X_LP(:,:,ii) = imfilter(X_LP(:,:,ii),(ratio^2)*real(PSF_G(:,:,ii)),'replicate');
    end
end
I_Filtered = double(X_LP);


end