function [RMSE_index, ssim_index] = outputQualityIndices(Fused, Ref, ratio, L)
if L == 8
    Fused = uint8(Fused);
    Ref = uint8(Ref);
end

%% SAM
%[SAM_index,SAM_map] = SAM(Ref, Fused);
%SAM_index2 = SAM_fusebox(hs_ref, Rec);
%disp(['SAM:', num2str(SAM_index)]);
%% RMSE
RMSE_index = RMSE(Ref, Fused);
%disp(['RMSE:', num2str(RMSE_index)]);
%%
%ERGAS_index2 = ERGAS_fusebox(Ref, Fused, 2);
%ERGAS_index = ERGAS(Ref, Fused, ratio);
%disp(['ERGAS:', num2str(ERGAS_index2)]);
%%
%AVEGRAD_index =AVEGRAD(Fused);
%disp(['AVEGRAD:', num2str(AVEGRAD_index)]);

%%
nb = size(Ref, 3);
tmp = 0;
%tmp2 = 0;
K = [0.01 0.03];
window = fspecial('gaussian', 11, 1.5);

for i=1:nb
     %tmp = tmp + ssim(Fused(:,:,i), Ref(:,:,i));
     tmp = tmp + ssim2(Fused(:,:,i), Ref(:,:,i), K, window, 2^double(L)-1);
end
% Out.ssim = tmp/nb;
%ssim_index = tmp/nb;
ssim_index = tmp/nb;
%disp(['SSIM:', num2str(ssim_index)]);
