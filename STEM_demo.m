clc;
clear;
close all;

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
test_STEM = 1;
test_ST_naive = 0;
n_run_times = 10;
update_output_qi = 1;
data_name = 'D_WV';%'D_IK' 'F_GE' 'D_WV' 'F_WV'
load(['Datasets/' data_name '.mat']);
n_methods = 0;
deb_method = 'Hyper-Laplacian';%'Hyper-Laplacian';%'Wiener'; %;

% The parameters that affect the performance of STEMs mainly include: 
% -- The number of multi-scale decomposition levels (clevel) 
% -- The parameter of Hyper-Laplacian (deb_lambda)
% -- Whether to apply the adaptive fusion weight (+AW)
if test_STEM
    %case_name = {'deb+H+S+A','deb+H+S+MS','deb+H+S+A+AW','deb+H+S+MS+AW','deb+H+2A','deb+H+A+MS','deb+H+2A+AW','deb+H+A+MS+AW'};
    clevels = 3;%ceil(log2(ratio))+2;
    if is_FS
        case_name = {'deb+H+S+A'};
        case_name = {'deb+H+2A'};
        switch(data_name)
            case 'F_WV'
                deb_lambdas = 1500; %[500];
                GNyqst_ins = 0.355;
            case 'F_GE'
                deb_lambdas = 4000; %[3500];
                GNyqst_ins = 0.23;
            otherwise
                deb_lambdas = 2000;
        end
        %deb_lambdas = 2000;
    else
        
        case_name = {'deb+H+2A+AW'};
        case_name = {'deb+H+2A','deb+H+2A+AW'};
        case_name = {'deb+H+2A','deb+H+S+A'};
        switch(data_name)
            case 'D_WV'
                deb_lambdas = 150; %[150 160 175 180 190 200 210];
                GNyqst_ins = 0.3;
            case 'D_IK'
                deb_lambdas = [20000];
                GNyqst_ins = [0.275];
            otherwise
                deb_lambdas = 7000;
        end
        %deb_lambdas = 7000;
        %deb_lambdas = [150 200 250];%[5e2 1e3 7e3 8e3 1e4];%1e3;  500 1000 2e3 7e3 1e4 1e5
    end
    n_test_case = length(case_name);
    
    conv_modes = [9];
    %GNyqst_ins = [0.20:0.005:0.39];
    for t = 1:n_test_case
        for g = 1:length(GNyqst_ins)
            for c = 1:length(conv_modes)
                for ii = 1:length(clevels) %
                    for jj = 1:length(deb_lambdas)
                        n_methods = n_methods+1;
                        STEM_opts = init_STEM_options_by_test_case(case_name{t});
                        STEM_opts.deb.lambda = deb_lambdas(jj);%(ii);
                        STEM_opts.global.deb_method = deb_method;
                        STEM_opts.fusion.clevels = clevels(ii); %ceil(log2(ratio))+2;
                        STEM_opts.global.conv_mode = conv_modes(c);
                        STEM_opts.global.GNyqst_in = GNyqst_ins(g);
                        Method_{n_methods} = ['STEM_' case_name{t} '_lambda_' ...
                            num2str(STEM_opts.deb.lambda) '_L_' ...
                            num2str(STEM_opts.fusion.clevels) '_' ...
                            num2str(STEM_opts.global.conv_mode) '_' ...
                            num2str(STEM_opts.global.GNyqst_in)];
                        t2=tic;
                        for i = 1:n_run_times
                            I_{n_methods} = STEM_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, STEM_opts);
                        end
                        Time_{n_methods}=toc(t2)/n_run_times;
                        fprintf('Elaboration time %s: %.4f [sec]\n',Method_{n_methods},Time_{n_methods});
                    end
                end
            end
        end
    end
end

if test_ST_naive
    ST_naive_opts.prep.hm_mode = 1;
    ST_naive_opts.prep.I_type = 'H';
    ST_naive_opts.prep.G_type = 'ratio-H';
    
    clevels = [3];

    for ii = 1:length(clevels) %
        ST_naive_opts.fusion.clevels = clevels(ii);
        n_methods = n_methods+1;
        t2=tic;
        for i = 1:n_run_times
            Method_{n_methods} = ['ST_naive_' num2str(ST_naive_opts.fusion.clevels)];
            I_{n_methods} = ST_naive_wrapper(I_MS_LR, I_PAN, ratio, sensorInf, L, ST_naive_opts);
        end
        Time_{n_methods}=toc(t2)/n_run_times;
        fprintf('Elaboration time %s: %.4f [sec]\n',Method_{n_methods},Time_{n_methods});
    end
end
if is_FS
    I_GT = [];
end
for i = 1:n_methods
    QI_{i} = indices_eval_wrapper(I_{i},I_GT,I_MS,I_MS_LR, I_PAN, ratio,L,sensorInf,is_FS,Qblocks_size,flag_cut_bounds,dim_cut,thvalues);    
end
QI_matrix = QI2matrix(QI_,Method_,Time_,is_FS);
if update_output_qi
    disp( ['Writting xls of Dataset: ' data_name]);
    xlswrite(['Results/qi/' datestr(now,30) '_' data_name '_tweak STEM D-IK all(no AW)'], QI_matrix, ['Dataset ' data_name]);
end


