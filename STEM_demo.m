
% A demo for STEM-MA, STEM-MS and ST-naive.
% Pan-sharpening Framework Based on Multi-scale Entropy Level Matching and
% Its Application.
% 2022.

clc;
clear;
close all;
file_path = matlab.desktop.editor.getActive;
cd(fileparts(file_path.Filename));

test_STEM = 1;
test_ST_naive = 1;
n_run_times = 1;
update_output_qi = 1;
data_name = 'D_WV';%'D_IK' 'F_GE' 'D_WV' 'F_WV'
deb_method = 'Hyper-Laplacian';%'Hyper-Laplacian';%'Wiener';

load(['Datasets/' data_name '.mat']);
n_methods = 0;

% The parameters that affect the performance of STEMs mainly include: 
% -- The parameter of Hyper-Laplacian (deb_lambda)
% -- The Nyquist frequency corresponding to PAN degradation (GNyqst_in)
% -- Whether to apply the adaptive fusion weight (+AW)
% -- The number of multi-scale decomposition levels (clevel)
% Valid case names: 
% -- STEM-MS: 'deb+H+S+A','deb+H+S+A+AW','deb+H+S+MS','deb+H+S+MS+AW'.
% -- STEM-MA: 'deb+H+2A','deb+H+2A+AW','deb+H+A+MS','deb+H+A+MS+AW'.
% 'deb+H+S+A' means 'deblur + dehaze + substitutive mode (HF) + additive
% mode (LF)'
if is_FS
    I_GT = [];
end
dat_time = datestr(now,30);
if test_STEM
    clevels = 3;
    conv_mode = 9;
    if is_FS
        case_name = {'deb+H+2A','deb+H+S+A'};
        switch(data_name)
            case 'F_WV'
                deb_lambdas = 1500; %1000:500:4500;
                GNyqst_in = 0.355; %0.15:0.03:0.38;
            case 'F_GE'
                deb_lambdas = 4000; %1000:500:4500;
                GNyqst_in = 0.23; %0.15:0.03:0.38; 
            otherwise
                deb_lambdas = 2000;
                GNyqst_in = 0.3;
                conv_mode = 2;
        end
    else
        case_name = {'deb+H+2A','deb+H+S+A'};
        switch(data_name)
            case 'D_WV'
                case_name = {'deb+H+2A+AW','deb+H+S+A+AW'};
                deb_lambdas = 150;
                GNyqst_in = 0.3;
            case 'D_IK'
                deb_lambdas = 20000;
                GNyqst_in = 0.275;
            otherwise
                deb_lambdas = 7000;
                GNyqst_in = 0.3;
                conv_mode = 2;
        end
    end
    n_test_case = length(case_name);
    for t = 1:n_test_case
        for g = 1:length(GNyqst_in)
            for ii = 1:length(clevels)
                for jj = 1:length(deb_lambdas)
                    n_methods = n_methods+1;
                    STEM_opts = init_STEM_options_by_test_case(case_name{t});
                    STEM_opts.deb.lambda = deb_lambdas(jj);
                    STEM_opts.global.deb_method = deb_method;
                    STEM_opts.fusion.clevels = clevels(ii);
                    STEM_opts.global.conv_mode = conv_mode;
                    STEM_opts.global.GNyqst_in = GNyqst_in(g);
                    Method_{n_methods} = ['STEM_' case_name{t} '_lambda_' ...
                        num2str(STEM_opts.deb.lambda) '_L_' ...
                        num2str(STEM_opts.fusion.clevels) '_' ...
                        num2str(STEM_opts.global.conv_mode) '_' ...
                        num2str(STEM_opts.global.GNyqst_in)];
                    t2=tic;
                    for i = 1:n_run_times
                        I_{n_methods} = STEM_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, STEM_opts);
                    end
                    Time_{n_methods} = toc(t2)/n_run_times;
                    fprintf('Elaboration time of %s: %.4fs\n',Method_{n_methods},Time_{n_methods});
                end
            end
        end
    end
end


if test_ST_naive
    ST_naive_opts.prep.hm_mode = 1;
    ST_naive_opts.prep.I_type = 'H';
    ST_naive_opts.prep.G_type = 'ratio-H';
    clevels = 3;
    for ii = 1:length(clevels)
        ST_naive_opts.fusion.clevels = clevels(ii);
        n_methods = n_methods+1;
        t2=tic;
        for i = 1:n_run_times
            Method_{n_methods} = ['ST_naive_' num2str(ST_naive_opts.fusion.clevels)];
            I_{n_methods} = ST_naive_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, ST_naive_opts);
        end
        Time_{n_methods} = toc(t2)/n_run_times;
        fprintf('Elaboration time of %s: %.4fs\n',Method_{n_methods},Time_{n_methods});
    end
end
if is_FS
    I_GT = [];
end
QI_ = cell(1, n_methods);
for i = 1:n_methods
    QI_{i} = indices_eval_wrapper(I_{i}, I_GT, I_MS, I_MS_LR, I_PAN, ratio,...
        L, sensorInf, is_FS, Qblocks_size, flag_cut_bounds, dim_cut,thvalues);    
end
QI_matrix = QI2matrix(QI_,Method_,Time_,is_FS);
if update_output_qi
    disp( ['Writting xls of Dataset: ' data_name]);
    xlswrite(['Results/qi/' datestr(now,30) '_' data_name], QI_matrix, ['Dataset ' data_name]);
    
end


