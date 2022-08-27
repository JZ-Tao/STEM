function QI = indices_eval_wrapper(I_F,I_GT,I_MS,I_MS_LR, I_PAN, ratio,L,sensorInf,is_FS,Qblocks_size,flag_cut_bounds,dim_cut,th_values)

if th_values
    I_F(I_F > 2^L-1) = 2^L-1;
    I_F(I_F < 0) = 0;
end
if is_FS
    if flag_cut_bounds
        I_PAN = I_PAN(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
        I_F = I_F(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
        I_MS = I_MS(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
        I_MS_LR = I_MS_LR(1+floor(dim_cut/ratio):end-floor(dim_cut/ratio),1+floor(dim_cut/ratio):end-floor(dim_cut/ratio),:);
    end
    [QI.HQNR,QI.D_lambda_K,QI.D_S]= HQNR(I_F,I_MS_LR,I_MS,I_PAN,Qblocks_size,sensorInf,ratio);
    [QI.QNR_Plus,~,QI.D_S_R]= QNR_Plus(I_F,I_MS_LR,I_MS,I_PAN,Qblocks_size,sensorInf,ratio);
	I_F_D = MTF_conv_sample(I_F,sensorInf,ratio,1);
    QI.Q = q2n(I_MS_LR,I_F_D,Qblocks_size,Qblocks_size);
else
    if flag_cut_bounds
        I_GT = I_GT(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
        I_F = I_F(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
    end

    QI.Q = q2n(I_GT,I_F,Qblocks_size,Qblocks_size);
    QI.SAM = SAM(I_GT,I_F);
    QI.ERGAS = ERGAS(I_GT,I_F,ratio);
    QI.RMSE = RMSE(I_GT, I_F);
    nb = size(I_GT, 3);
    tmp = 0;
    for i=1:nb
         tmp = tmp + ssim(I_F(:,:,i), I_GT(:,:,i),'DynamicRange',2^double(L)-1);
    end
    QI.SSIM = tmp/nb;
end
