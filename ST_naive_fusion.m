function I_fused = ST_naive_fusion(I, PAN, FusionOpts)

clevels = FusionOpts.clevels;

[n_row, n_col, n_band]=size(I);
if n_band ~= size(PAN, 3)
    error('The band number of MS and PAN should be equal.');
end

no_echo = 1;

lvl_dcomp_enum = [0 1 2 3 4 5 6 7 8];
lvl_dsize_enum = [4 4 8 16 16 16 16 16];
shear_parameters.dcomp = lvl_dcomp_enum(1:clevels);
shear_parameters.dsize = lvl_dsize_enum(1:clevels);
shear_f = generateShearFilter([n_row, n_col],shear_parameters);

lp_filter = 'maxflat';
if ~no_echo
    disp('NSST Dec...');
end

n_sub_bands = 2.^shear_parameters.dcomp;
dst = cell(1,clevels);
dec_wrapper = @(x) nsst_dec3(x, shear_parameters, lp_filter, shear_f);
rec_wrapper = @(x) nsst_rec1(x,lp_filter);

[dst_I, ~] = dec_wrapper(I);
[dst_PAN, ~] = dec_wrapper(PAN);
dst{1} = dst_I{1};
for j = 1:clevels                         
    for k = 1:n_sub_bands(j)
       dst{j+1}(:,:,k) = dst_PAN{j+1}(:,:,k);
    end
end

if ~no_echo
    disp('NSST REC...');
end

I_fused = rec_wrapper(dst);




