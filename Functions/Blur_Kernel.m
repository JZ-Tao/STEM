function [PSF_G, GNyq] = Blur_Kernel(n_band, sensor, ratio, is_XS)

if ~exist('is_XS','var')
    is_XS = true;
end

% if strcmp(sensor, 'bicbuic')
%     %PSF_G = getInterpKernel(4, 2, 2, 7); PSF_G = repmat(PSF_G, [1,1,n_band]);
%     GNyq = 0.5;
%     return;
% else
    GNyq = getGNyqBySensor(sensor, n_band, is_XS);
% end
%GNyq = GNyq + GNyq_offset;
N = 41;

%N = 9;
%N = 9;%%%
fcut = 1/ratio;
PSF_G = zeros(N,N,n_band);
%GNyq = 0.29.*ones(1,n_band);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1 : n_band
    alpha = sqrt((N*(fcut/2))^2/(-2*log(GNyq(ii))));
    %alpha = (1/(2*(2.7725887)/ratio^2))^0.5;%%%
    H = fspecial('gaussian', N, alpha);
    Hd = H./max(H(:));
    h = fwind1(Hd,kaiser(N));
    PSF_G(:,:,ii) = real(h);
    %h = fspecial('gaussian',[9 9],1);
    %PSF_G(:,:,ii) = h;
end
