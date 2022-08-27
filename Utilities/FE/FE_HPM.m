function [I_Fus,D,PSF_l] = FE_HPM(I_PAN,I_MS,Resize_fact,tap,lambda,mu,th,num_iter,filtername)

imageHR = double(I_PAN);
I_MS = double(I_MS);
nBands = size(I_MS,3);

%%% Equalization
imageHR = repmat(imageHR,[1 1 size(I_MS,3)]);
for ii = 1 : size(I_MS,3)    
  imageHR(:,:,ii) = (imageHR(:,:,ii) - mean2(imageHR(:,:,ii))).*(std2(I_MS(:,:,ii))./std2(imageHR(:,:,ii))) + mean2(I_MS(:,:,ii));  
end

PSF_l = FE(I_MS,I_PAN,Resize_fact,tap,lambda,mu,th,num_iter,filtername);

PAN_LP = zeros(size(imageHR));
for ii = 1 : nBands
    PAN_LP(:,:,ii) = imfilter(imageHR(:,:,ii),PSF_l,'replicate');
    t = imresize(PAN_LP(:,:,ii),1/Resize_fact,'nearest');
    PAN_LP(:,:,ii) = interp23tap(t,Resize_fact);
end

PAN_LP = double(PAN_LP);

D = (imageHR ./ (PAN_LP + eps));

I_Fus = I_MS .* D;

end