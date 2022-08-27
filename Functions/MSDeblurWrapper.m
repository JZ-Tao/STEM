function I_MS_deb = MSDeblurWrapper(I_MS, PSF_G, L, method, Opts)

if ~exist('L', 'var'), L = 0; end;
if ~exist('method', 'var'), method = 'Wiener'; end;
if ~exist('Opts', 'var'), Opts = struct; end 
if ~isfield(Opts, 'lambda'), Opts.lambda = 7e3; end


I_MS_deb = zeros(size(I_MS));

[nl, nc, n_band] = size(I_MS);
if size(PSF_G, 3) == 1
    PSF_G = repmat(PSF_G,[1 1 n_band]);
end
for i = 1:n_band
    PSF_G(:,:,i) = PSF_G(:,:,i)./(sum(sum(PSF_G(:,:,i))));
end

if strcmp(method, 'Hyper-Laplacian')
    bd_type = 1;
    padding_size = ceil((size(PSF_G, 1)-1)/2);
    bd_opts.PSF_G = PSF_G;
    I_MS_pad = boundary_handle_pre(I_MS, [padding_size padding_size], bd_type, bd_opts);
    lambda = Opts.lambda;
    alpha = 1/2;
    for i = 1:n_band
        tmp(:,:,i) = fast_deconv(I_MS_pad(:,:,i), PSF_G(:,:,i),lambda, alpha);
    end
   I_MS_deb = boundary_handle_aft(tmp, [size(I_MS,1) size(I_MS,2)], bd_type);

elseif strcmp(method, 'Wiener')

    h_sz = ceil((size(PSF_G, 1)-1)/2);
    I_MS_deb = I_MS;
    I_MS_padded = padarray(I_MS,[h_sz,h_sz],'symmetric','both');
    [nl_padded, nc_padded, ~] = size(I_MS_padded);
    mid_l = round((nl_padded+1)/2);
    mid_c = round((nc_padded+1)/2);
    snr = 0.01;

    for ii = 1 : n_band
        B_k = zeros(nl_padded, nc_padded);
        B_k(mid_l-h_sz:mid_l+h_sz,mid_c-h_sz:mid_c+h_sz) = PSF_G(:,:,ii);
        B_k = ifftshift(B_k)./sum(B_k(:));
        I_MS_padded(:,:,ii) = edgetaper(I_MS_padded(:,:,ii),ones(h_sz,h_sz)./((h_sz)^2));
        t = real(ifft2(conj(fft2(B_k)).*fft2(I_MS_padded(:,:,ii))./(fft2(B_k).^2+(snr))));
        I_MS_deb(:,:,ii) = t(1+h_sz:nl_padded-h_sz, 1+h_sz:nc_padded-h_sz);
    end 
else
	% Matlab's built-in deblurring methods
	if strcmp(method, 'Sps')
		for i = 1:n_band
			I_MS_deb(:,:,i)=deconvSps(I_MS(:,:,i),PSF_G(:,:,i),0.001,100);
		end
	end
	if strcmp(method, 'deconvwnr')
		noise_var = 0.001;
		for i = 1:n_band
			nsr = noise_var / var(I_MS(:));
			I_MS_deb(:,:,i) = deconvwnr(I_MS(:,:,i),PSF_G(:,:,i),nsr);
		end
	end
	if strcmp(method, 'deconvlucy')
		for i = 1:n_band
			I_MS_deb(:,:,i) = deconvlucy(I_MS(:,:,i),PSF_G(:,:,i));
		end
	end
	if strcmp(method, 'deconvreg')
		for i = 1:n_band
			I_MS_deb(:,:,i) = deconvreg(I_MS(:,:,i),PSF_G(:,:,i));
		end
	end
end
