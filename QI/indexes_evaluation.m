%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: 
%           Reduced resolution quality indexes. 
% 
% Interface:
%           [Q_index, SAM_index, ERGAS_index, sCC, Q2n_index] = indexes_evaluation(I_F,I_GT,ratio,L,Q_blocks_size,flag_cut_bounds,dim_cut,th_values)
%
% Inputs:
%           I_F:                Fused Image;
%           I_GT:               Ground-Truth image;
%           ratio:              Scale ratio between MS and PAN. Pre-condition: Integer value;
%           L:                  Image radiometric resolution; 
%           Q_blocks_size:      Block size of the Q-index locally applied;
%           flag_cut_bounds:    Cut the boundaries of the viewed Panchromatic image;
%           dim_cut:            Define the dimension of the boundary cut;
%           th_values:          Flag. If th_values == 1, apply an hard threshold to the dynamic range.
%
% Outputs:
%           Q_index:            Q index;
%           SAM_index:          Spectral Angle Mapper (SAM) index;
%           ERGAS_index:        Erreur Relative Globale Adimensionnelle de Synth�se (ERGAS) index;
%           sCC:                spatial Correlation Coefficient between fused and ground-truth images;
%           Q2n_index:          Q2n index.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Q_index, SAM_index, ERGAS_index, sCC, Q2n_index] = indexes_evaluation(I_F,I_GT,ratio,L,Q_blocks_size,flag_cut_bounds,dim_cut,th_values)
if ~exist('flag_cut_bounds','var')
    flag_cut_bounds = 1;
end
if ~exist('dim_cut','var')
    dim_cut = 11;
end
if ~exist('Q_blocks_size','var')
    Q_blocks_size = 32;
end
if ~exist('th_values','var')
    th_values = 0;
end

if flag_cut_bounds
    I_GT = I_GT(1+dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
    I_F = I_F(1+dim_cut:end-dim_cut,dim_cut:end-dim_cut,:);
end

if th_values
    I_F(I_F > 2^L-1) = 2^L-1;
    I_F(I_F < 0) = 0;
end


Q2n_index = q2n(I_GT,I_F,Q_blocks_size,Q_blocks_size);

Q_index = Q(I_GT,I_F,2^L);
SAM_index = SAM(I_GT,I_F);
ERGAS_index = ERGAS(I_GT,I_F,ratio);

%%% sCC
Im_Lap_F = zeros(size(I_F));
for idim=1:size(I_F,3),
    Im_Lap_F(:,:,idim)= imfilter(I_F(:,:,idim),fspecial('sobel'));
end
Im_Lap_GT = zeros(size(I_GT));
for idim=1:size(I_GT,3),
    Im_Lap_GT(:,:,idim)= imfilter(I_GT(:,:,idim),fspecial('sobel'));
end


sCC = sum(sum(sum(Im_Lap_GT.*Im_Lap_F)));
sCC = sCC/sqrt(sum(sum(sum((Im_Lap_GT.^2)))));
sCC = sCC/sqrt(sum(sum(sum((Im_Lap_F.^2)))));


end