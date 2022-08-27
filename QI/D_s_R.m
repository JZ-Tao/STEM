function Dl = D_s_R(fused,P)

%h = estimation_alpha(fused(1+off:end-off,1+off:end-off,:), P(1+off:end-off,1+off:end-off),'global');
F = padarray(im2mat(fused)', [0 1], 1, 'post');
[~,~,~,~,stats] = regress(P(:),F);
Dl = 1-stats(1);

end