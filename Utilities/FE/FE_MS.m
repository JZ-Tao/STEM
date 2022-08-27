function PSF_G = FE_MS(I_MS,I_PAN,tap,lambda,mu,th,filtername)

if rem(tap,2) == 0
    sum_tap = 0;
else
    sum_tap = 1;
end
tap = floor(tap/2);


[R_SIZE,C_SIZE, n_band] = size(I_MS);

switch filtername
    case 'Naive2'
        gv = zeros(2,1);
        gv(1,1) = -1;
        gv(2,1) = 1;
        
        gh = zeros(1,2);
        gh(1,1) = -1;
        gh(1,2) = 1;
    case 'Naive3'
        gv = zeros(3,1);
        gv(1,1) = -1;
        gv(3,1) = 1;
        
        gh = zeros(1,3);
        gh(1,1) = -1;
        gh(1,3) = 1;
    case 'Basic'
        gv = zeros(2,2);
        gv(1,:) = -1;
        gv(2,:) = 1;
        
        gh = zeros(2,2);
        gh(:,1) = -1;
        gh(:,2) = 1;
    case 'Prewitt'
        gv = zeros(3,3);
        gv(1,:) = -1;
        gv(3,:) = 1;
        
        gh = zeros(3,3);
        gh(:,1) = -1;
        gh(:,3) = 1;
    case 'Sobel'
        gv = zeros(3,3);
        gv(1,1) = -1;gv(1,2) = -2;gv(1,3) = -1;
        gv(3,1) = +1;gv(3,2) = +2;gv(3,3) = +1;
        
        gh = zeros(3,3);
        gh(1,1) = -1;gh(2,1) = -2;gh(3,1) = -1;
        gh(1,3) = +1;gh(2,3) = +2;gh(3,3) = +1;
    otherwise
        gv = zeros(2,2);
        gv(1,:) = -1;
        gv(2,:) = 1;
        
        gh = zeros(2,2);
        gh(:,1) = -1;
        gh(:,2) = 1;
end

gvf = fft2(gv,R_SIZE,C_SIZE);
ghf = fft2(gh,R_SIZE,C_SIZE);

gvfc = conj(gvf);
ghfc = conj(ghf);

gvf2 = gvfc .* gvf;
ghf2 = ghfc .* ghf;

gf2sum = gvf2 + ghf2;

%PSF_G = zeros(tap*2+1, tap*2+1);
for ii = 1:n_band
    %for jj = 1 : num_iter
		H_E = I_PAN(:,:,ii);
        It_E = I_MS(:,:,ii);
		

		%%% Edge taper
		H_E = edgetaper(H_E,ones(tap,tap)./((tap)^2));
		It_E = edgetaper(It_E,ones(tap,tap)./((tap)^2));

		%%% Filter Estimation
		PSF = real(fftshift(ifft2(conj(fft2(H_E)).* fft2(It_E)./(abs(fft2(H_E)).^2 + lambda + mu * gf2sum ))));
		
		%%% Thresholding
		PSF(PSF < th) = 0;
		
		%%% Cut using the support dimension and center
		[~, maxIndex] = max(PSF(:));
		[rm, cm] = ind2sub(size(PSF), maxIndex);
		PSF_l = PSF(rm - tap : rm + tap - 1 + sum_tap, cm - tap : cm + tap - 1 + sum_tap);
		PSF_l = PSF_l ./ sum(PSF_l(:));
        PSF_G(:,:,ii) = PSF_l;
    %end
end

end
