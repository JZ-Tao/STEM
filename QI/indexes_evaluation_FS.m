%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Full resolution quality indexes. 
% 
% Interface:
%           [D_lambda,D_S,QNR_index,SAM_index,sCC] = indexes_evaluation_FS(I_F,I_MS_LR,I_PAN,L,th_values,I_MS,sensor,tag,ratio)
%
% Inputs:
%           I_F:                Fused Image;
%           I_MS_LR:            MS image;
%           I_PAN:              Panchromatic image;
%           L:                  Image radiometric resolution; 
%           th_values:          Flag. If th_values == 1, apply an hard threshold to the dynamic range;
%           I_MS:               MS image upsampled to the PAN size;
%           sensor:             String for type of sensor (e.g. 'WV2','IKONOS');
%           tag:                Image tag. Often equal to the field sensor. It makes sense when sensor is 'none'. It indicates the band number;
%           ratio:              Scale ratio between MS and PAN. Pre-condition: Integer value.
%
% Outputs:
%           D_lambda:           D_lambda index;
%           D_S:                D_S index;
%           QNR_index:          QNR index;
%           SAM_index:          Spectral Angle Mapper (SAM) index between fused and MS image;
%           sCC:                spatial Correlation Coefficient between fused and PAN images.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D_lambda_index,D_lambda_K_index, D_lambda_C_index,D_S_index,D_S_C_index,D_S_R_index,QNR_index,HQNR_index, SSC_QNR_index, QNR_Plus_index, SAM_index,sCC] = indexes_evaluation_FS(I_F,I_MS_LR,I_PAN,L,th_values,I_MS,sensorInf,ratio,flag_cut_bounds,dim_cut)

if flag_cut_bounds
    I_PAN = I_PAN(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
    I_F = I_F(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
    I_MS = I_MS(1+dim_cut:end-dim_cut,1+dim_cut:end-dim_cut,:);
    I_MS_LR = I_MS_LR(1+floor(dim_cut/ratio):end-floor(dim_cut/ratio),1+floor(dim_cut/ratio):end-floor(dim_cut/ratio),:);
end
if th_values
    I_F(I_F > 2^L-1) = 2^L-1;
    I_F(I_F < 0) = 0;
end

cd Quality_Indices
[QNR_index, HQNR_index,D_lambda_index,D_lambda_K_index, D_S_index] = QNR_HQNR(I_F,I_MS,I_MS_LR,I_PAN,sensorInf,ratio);
% [QNR_index,D_lambda,D_S]= QNR(I_F,I_MS,I_PAN,sensorInf.sensor,ratio);
% S = 32;
% [QNR_index,D_lambda,D_S]= HQNR(I_F,I_MS_LR,I_MS,I_PAN,S,sensorInf,ratio);
S = 32;
[QNR_Plus_index,~,D_S_R_index]= QNR_Plus(I_F,I_MS_LR,I_MS,I_PAN,S,sensorInf,ratio);
[SSC_QNR_index,D_lambda_C_index,D_S_C_index]= SSC_QNR(I_F,I_MS_LR,I_MS,I_PAN,S,sensorInf,ratio);
I_PAN = repmat(I_PAN,[1 1 size(I_MS,3)]);

Im_Lap_PAN = zeros(size(I_PAN));
for idim=1:size(I_PAN,3),
    Im_Lap_PAN(:,:,idim)= imfilter(I_PAN(:,:,idim),fspecial('sobel'));
end

is_downsampling = 1;
I_F_D = MTF_conv_sample(I_F,sensorInf,ratio,is_downsampling);

SAM_index = SAM(I_MS_LR,I_F_D);

Im_Lap_F = zeros(size(I_F));
for idim=1:size(I_MS_LR,3),
    Im_Lap_F(:,:,idim)= imfilter(I_F(:,:,idim),fspecial('sobel'));
end

sCC=sum(sum(sum(Im_Lap_PAN.*Im_Lap_F)));
sCC=sCC/sqrt(sum(sum(sum((Im_Lap_PAN.^2)))));
sCC=sCC/sqrt(sum(sum(sum((Im_Lap_F.^2)))));

cd ..

end