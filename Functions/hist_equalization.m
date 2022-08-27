function P = hist_equalization(M, P, PL, mode)
if ~exist('mode', 'var')
    mode = 1;
end
if mode == 0
    return;
end
n_band = size(M, 3);
if size(P,3) ~= n_band
    P = repmat(P, [1,1,n_band]);
    PL = repmat(PL, [1,1,n_band]);
end
% global, mixed Res (MTF-GLP etc. default)
if mode == 1
    for i = 1:n_band
        P(:,:,i) = (P(:,:,i) - mean2(P(:,:,i))).*(std2(M(:,:,i))./std2(PL(:,:,i))) + mean2(M(:,:,i));
    end
    return;
end
% ATWT
if mode == -1
    for i = 1:n_band
        P(:,:,i) = (P(:,:,i) - mean2(P(:,:,i))).*(std2(M(:,:,i))./std2(P(:,:,i))) + mean2(M(:,:,i));
    end
    return;
end

% local HM
if mode == 2
    w = 3;
    for i = 1:n_band
        [U_M, SD_M] = LocalStatics(M(:,:,i), w); 
        [U_P, SD_P] = LocalStatics(P(:,:,i), w); 
        [U_PL, SD_PL] = LocalStatics(PL(:,:,i), w); 
        P(:,:,i) = (P(:,:,i) - U_P).*(SD_M./SD_PL) + U_M;
    end
    return;
end
% Local Regress
if mode == 3
    w = 3;
    for i = 1:n_band
        [G, O] = regionRegress(M(:,:,i), PL(:,:,i), w); 
        P(:,:,i) = G.*P(:,:,i)+O;
    end
    
    return;
end


