function I_fused = STEM_fusion(I, PAN, FusionOpts)

if ~exist('FusionOpts', 'var'), FusionOpts = struct; end
if ~isfield(FusionOpts, 'p'), FusionOpts.p = -1; end % Adaptation using graythresh
% 'S': Substitutive mode
% 'A': Additive mode
if ~isfield(FusionOpts, 'HF_rule'), FusionOpts.HF_rule = 'S'; end
if ~isfield(FusionOpts, 'LF_rule'), FusionOpts.LF_rule = 'MS'; end

adaptive_rho = FusionOpts.adaptive_rho;
LF_rule = FusionOpts.LF_rule;
HF_rule = FusionOpts.HF_rule;
I_PAN_LP = FusionOpts.I_PAN_LP;
clevels = FusionOpts.clevels;
W_method = FusionOpts.W_method;

[n_row, n_col, n_band]=size(I);
if n_band ~= size(PAN, 3)
    error('The band number of MS and PAN should be equal.');
end

no_echo = 1;
% Parameter setting of NSST
lvl_dcomp_enum = [0 1 2 3 4 5 6 7 8];
lvl_dsize_enum = [4 4 8 16 16 16 16 16];
if clevels > length(lvl_dcomp_enum)
    error('Exceeded maximum number of decomposition levels.');
end
shear_parameters.dcomp = lvl_dcomp_enum(1:clevels);
shear_parameters.dsize = lvl_dsize_enum(1:clevels);
shear_f = generateShearFilter([n_row, n_col],shear_parameters);
lp_filter = 'maxflat';
n_sub_bands = 2.^shear_parameters.dcomp;

LF_I = zeros(size(PAN));
LF_PAN = zeros(size(PAN));
LF_PAN_LP = zeros(size(PAN));

sz_HF = [1, clevels];
HF_I = cell(sz_HF);
HF_PAN = cell(sz_HF);
HF_PAN_LP = cell(sz_HF);

dec_wrapper = @(x) nsst_dec3(x, shear_parameters, lp_filter, shear_f);
rec_wrapper = @(x) nsst_rec1(x,lp_filter);

if ~no_echo
    disp('NSST Dec...');
end
for i = 1:n_band
    [dst_I, ~] = dec_wrapper(I(:,:,i));
    [dst_PAN, ~] = dec_wrapper(PAN(:,:,i));
    [dst_PAN_LP, ~] = dec_wrapper(I_PAN_LP(:,:,i));

    LF_I(:,:,i) = dst_I{1};
    LF_PAN(:,:,i) = dst_PAN{1};
    LF_PAN_LP(:,:,i) = dst_PAN_LP{1};

    for j = 1:clevels                        
        for k = 1:n_sub_bands(j)
           HF_I{j}{k}(:,:,i)= dst_I{j+1}(:,:,k);   
           HF_PAN{j}{k}(:,:,i)= dst_PAN{j+1}(:,:,k); 
           HF_PAN_LP{j}{k}(:,:,i)= dst_PAN_LP{j+1}(:,:,k);
        end
    end
end

%% 1. Calculate the low frequency fusion coefficients
switch LF_rule
    case 'MS'
        LF_fused = LF_I;
    case 'PAN'
        LF_fused = LF_PAN;
    case 'AVG'
        LF_fused = (LF_I + LF_PAN)./2;
    case 'Var_S'
        [V1, V2, V12] = VarMatchingMap(LF_I, LF_PAN_LP);
        V1V2 = V1+V2+eps;
        M_LF = (2.*abs(V12))./V1V2;
        p_LF = graythresh(M_LF);
        W_LF = M_LF./(p_LF+eps);
        W_LF(M_LF > p_LF) = 1;
        LF_fused = (1-W_LF).*LF_I + W_LF.*LF_PAN;
    case 'Var_A'
        [V_I, V_PAN_LP, V_I_PAN_LP] = VarMatchingMap(LF_I, LF_PAN_LP);
        M_LF = 2.*abs(V_I_PAN_LP)./(V_I+V_PAN_LP+eps);
        p_LF = graythresh(M_LF);
        W_LF = M_LF./(p_LF+eps);
        W_LF(M_LF > p_LF) = 1;
        LF_fused = LF_I+W_LF.*(LF_PAN-LF_PAN_LP);
    case 'Var_A2'
        [V_I, V_PAN_LP, V_I_PAN_LP] = VarMatchingMap(LF_I, LF_PAN_LP);
        M_LF = 2.*abs(V_I_PAN_LP)./(V_I+V_PAN_LP+eps);
        %M_LF = 1;
        LF_fused = LF_I+M_LF.*(LF_PAN-LF_PAN_LP);
end

%% 2. Calculate the high frequency fusion coefficients
% 2.1 Define superimposable direction templates
mask{1} ={[1,1,1;1,1,1;1,1,1]};
mask{2} = {[0,1,0;0,1,0;0,1,0], [0,0,0;1,1,1;0,0,0]};
mask{3} = {[0,1,0;0,1,0;0,1,0], [1,0,0;0,1,0;0,0,1],...
           [0,0,0;1,1,1;0,0,0], [0,0,1;0,1,0;1,0,0]};

for j = 4:clevels
    n_dir = length(mask{j-1});
    for i = 1:n_dir
        mask{j}{i*2-1} = mask{j-1}{i} + mask{j-1}{mod(i-2,n_dir)+1};
        mask{j}{i*2} = mask{j-1}{i};
    end
end    
%soften
%mask{1}{1};%fspecial('gaussian', [3 3]);
% msk_soften = mask{1}{1};
% for j = 2:clevels
%     
%     for i = 1:length(mask{j})
%         mask{j}{i} = mask{j}{i} + msk_soften;
%     end
% end
for j = 1:clevels
    for i = 1:length(mask{j})
        mask{j}{i} = imresize(mask{j}{i},2^(clevels-j)); 
        %mask{j}{i} = imresize(mask{j}{i},1/(2^(clevels-j)),'nearest'); 
    end
end
for j = 1:clevels
    n_dir = length(mask{j});
    for i = 1:n_dir
      mask{j}{i} = mask{j}{i}./sum(sum(mask{j}{i}));
    end
end

is_show_mask = 0;
if is_show_mask
    max_dir = length(mask{clevels});
    for j = 1:clevels
        kk_map{j} = (j-1)*max_dir+1:(j)*max_dir;
        if j ~= 1
            kk_map{j} = downsample(kk_map{j}, 2^(j-1), 2*(j-2)+1);
        end
    end
    figure,
    for j = clevels:-1:3
        n_dir = length(mask{j});
        for i = 1:n_dir
          subplot(clevels, 2^lvl_dcomp_enum(clevels), kk_map{clevels-j+1}(i)); 
          imshow(mask{j}{i},[]);
        end
    end
end

%%
% 2.2 Calculate directional neighborhood matching degree
Er_I = cell(sz_HF);
Er_PAN_LP = cell(sz_HF);
Er_I_PAN_LP = cell(sz_HF);

if ~no_echo
    disp('Calculate directional energy...');
end

for j = 1:clevels 
    for k = 1:n_sub_bands(j) 
        I_i = HF_I{j}{k};
        P_LP_i = HF_PAN_LP{j}{k};
        mask_i = mask{j}{k};
        [Er_I{j}{k}, Er_PAN_LP{j}{k}, Er_I_PAN_LP{j}{k}, ~]=DirectionalEnergyMatchingMap(I_i, P_LP_i, mask_i);
    end
end

%%
% 2.3 Calculate the tree structure matching degree
if ~no_echo
    disp('Calculate the tree structure matching degree');
end
Et_I=cell(sz_HF);
Et_PAN_LP=cell(sz_HF);
Et_I_PAN_LP=cell(sz_HF);
Mt_LP=cell(sz_HF);

% Directional structure tree
for j=1:clevels
    for k = 1:n_sub_bands(j) % {j}{k}: the root node of the current subtree
        Et_I{j}{k} = Er_I{j}{k};
        Et_PAN_LP{j}{k} = Er_PAN_LP{j}{k};
        Et_I_PAN_LP{j}{k} = Er_I_PAN_LP{j}{k};
        subtree_depth = clevels-j;
        for jj = 1:subtree_depth
            % The number of nodes in the current level
            n_nodes = n_sub_bands(jj+1);
            for kk = 1:n_nodes
                node_j = j+jj;
                node_k = n_nodes*k-kk+1;
                Et_I{j}{k} = Et_I{j}{k} + Er_I{node_j}{node_k};
                Et_PAN_LP{j}{k} = Et_PAN_LP{j}{k} + Er_PAN_LP{node_j}{node_k};
                Et_I_PAN_LP{j}{k} = Et_I_PAN_LP{j}{k} + Er_I_PAN_LP{node_j}{node_k};
            end
        end
    end
 end 
clear Er_I Er_PAN Er_I_PAN Er_PAN_LP Er_I_PAN_LP Er_PAN_PAN_LP
%%  
for j = 1:clevels
     for k = 1:n_sub_bands(j) 
         Mt_LP{j}{k} = 2.*abs(Et_I_PAN_LP{j}{k})./(Et_I{j}{k}+Et_PAN_LP{j}{k}+eps);
     end
end
clear Et_PAN Et_I_PAN Et_I_PAN_LP Et_PAN_PAN_LP

%% 2.4 High frequency coefficient fusion
if ~no_echo
    disp('fusing');
end

HF_fused=cell(sz_HF);
for j = 1:clevels
    for k = 1:n_sub_bands(j) 
        Mt_LP_i = (Mt_LP{j}{k});
        if adaptive_rho
            rho = ((graythresh(Mt_LP_i)));
        else
            rho = 1; %p
        end
        %rho = ((graythresh(Mt_LP_i))); % testing
        if strcmp(W_method, 'DST')
            % Fusion weight map calculation
            tau = 1;  
            W = (Mt_LP_i./rho).^tau;
            W(Mt_LP_i > rho) = 1;
        else % Other typical fusion rules, such as Burt's method
            W = fusion_weight(HF_PAN{j}{k}, HF_I{j}{k}, W_method, 3, rho);
        end
        if strcmp(HF_rule, 'S')
            % Substitutive mode
            HF_fused{j}{k}=(1-W).*HF_I{j}{k} + W.*HF_PAN{j}{k};
        elseif strcmp(HF_rule, 'A') 
            % Additive mode
            HF_fused{j}{k}= (HF_I{j}{k}) + W.*(HF_PAN{j}{k} - HF_PAN_LP{j}{k});
        end
    end
end

dst = cell(1,clevels);
dst{1} = LF_fused;
for j = 1:clevels               
    for k = 1:n_sub_bands(j)
        dst{j+1}(:,:,k) = HF_fused{j}{k};
    end
end

if ~no_echo
    disp('NSST REC...');
end

I_fused = rec_wrapper(dst);

