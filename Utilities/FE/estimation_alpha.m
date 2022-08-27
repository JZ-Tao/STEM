function alpha = estimation_alpha(imageLR,imageHR,type_estimation)

if strcmp(type_estimation,'global')
    %%%%%%%% Global estimation
    IHc = reshape(imageHR,[numel(imageHR) 1]);
    ILRc = reshape(imageLR,[size(imageLR,1)*size(imageLR,2) size(imageLR,3)]);
    alpha = ILRc\IHc;
else
    %%%%%%%% Local estimation
    block_win = 32;
    alphas = zeros(size(imageLR,3),1);
    cont_bl = 0;
    for ii = 1 : block_win : size(imageLR,1)
        for jj = 1 : block_win : size(imageLR,2)
                imHRbl = imageHR(ii : min(size(imageLR,1),ii + block_win - 1), jj : min(size(imageLR,2),jj + block_win - 1));
                imageLRbl = imageLR(ii : min(size(imageLR,1),ii + block_win - 1), jj : min(size(imageLR,2),jj + block_win - 1),:);
                imageHRc = reshape(imHRbl,[numel(imHRbl) 1]);
                ILRc = reshape(imageLRbl,[size(imageLRbl,1).*size(imageLRbl,2) size(imageLRbl,3)]);
                alphah = ILRc\imageHRc;
                alphas = alphas + alphah;
                cont_bl = cont_bl + 1;
        end
    end
    alpha = alphas/cont_bl;
end

end