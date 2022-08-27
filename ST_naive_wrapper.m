function I_MS_fused = ST_naive_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, Opts)

if ~exist('Opts', 'var'), Opts = struct; end; 
if ~isfield(Opts.prep, 'I_type'), Opts.prep.I_type = 'avg'; end;
if ~isfield(Opts.prep, 'G_type'), Opts.prep.G_type = 'ratio'; end;
% Histogram matching modes. 1: Global(default), local, 0: do not execute.
if ~isfield(Opts.prep, 'hm_mode'), Opts.prep.hm_mode = 1; end;
max_v = 1;
% max_v = double(max(2^double(L)-1, 1)); % Should be uncommented if incoming data is not normalized

I_MS_LR = I_MS_LR./max_v;
I_PAN = I_PAN./max_v;

I_MS_LR = double(I_MS_LR);
I_PAN = double(I_PAN);

I_MS = interpWrapper(I_MS_LR, ratio, sensorInf.upsampling);

I_PAN_LR = MTF_conv_sample(I_PAN, sensorInf, ratio, 1);
I_PAN_LP = interpWrapper(I_PAN_LR,ratio, sensorInf.upsampling);
I_org = BandCombination(I_MS, I_PAN, I_MS_LR, I_PAN_LR, ratio, Opts.prep.I_type);

I_PAN = hist_equalization(I_org, I_PAN, I_PAN_LP, Opts.prep.hm_mode);

Im = ST_naive_fusion(I_org, I_PAN, Opts.fusion);

% Calculate the gain factor
v_Lp_MS = reshape(min(im2mat(I_MS),[],2), [1,1,size(I_MS,3)]);
Lp_MS = repmat(v_Lp_MS, [size(I_MS,1) size(I_MS,2)]);

I_MS_fused = (I_MS - Lp_MS).*((Im)./(I_org+eps)) + Lp_MS;
I_MS_fused = I_MS_fused.*max_v;

