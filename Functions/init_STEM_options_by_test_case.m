function EXP_options = init_STEM_options_by_test_case(case_name)
% Parameter combination in the paper:
% Substitutive mode: 'deb+H+S+A', 'deb+H+S+A+AW'
% Additive mode: 'deb+H+2A', 'deb+H+2A+AW'
% Note: Due to code cleanup, other parameter combinations are not guaranteed availability

% Some default value for common parameters
EXP_options.prep.ds_mode = 1;
EXP_options.prep.hm_mode = 1; % histogram match mode, 1 (default)
EXP_options.prep.need_PAN_LP = 0;
EXP_options.prep.G_type = 'ones';
EXP_options.fusion.W_method = 'DST'; % Directional structure tree
EXP_options.fusion.adaptive_rho = 0; % 0 (default), or 1 when using adaptive mode;
% HF fusion rule. 'S': substitutive. 'A': additive
EXP_options.fusion.HF_rule = 'S';
% LF fusion rule. MS(default)
EXP_options.fusion.LF_rule = 'MS';
    
if strcmp(case_name, 'deb+H+MS')
    EXP_options.prep.MS_deb = 0;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 0;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'Reg-FS';%'ratio-H';
    EXP_options.fusion.LF_rule = 'simple_A';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
% deblur (deb) + dehaze (H) + HF: Substitutive, LF: Additive
if strcmp(case_name, 'deb+H+S+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_A';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
% deblur (deb) + dehaze (H) + HF: Additive, LF: Additive
if strcmp(case_name, 'deb+H+2A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_A';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
% deblur (deb) + dehaze (H) + HF: Substitutive, LF: Additive 2
if strcmp(case_name, 'deb+H+S+A2')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_A2';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
% deblur (deb) + dehaze (H) + HF: Additive, LF: Additive 2
if strcmp(case_name, 'deb+H+2A2')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_A2';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
% deblur (deb) + dehaze (H) + HF: Substitutive, LF: Additive
if strcmp(case_name, 'deb+H+S+MS')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'MS';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
% deblur (deb) + dehaze (H) + HF: Additive, LF: MS
if strcmp(case_name, 'deb+H+A+MS')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'MS';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
% deblur (deb) + dehaze (H) + HF: Substitutive, LF: Additive + Adaptive Weight
if strcmp(case_name, 'deb+H+S+A+AW')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_A';
    EXP_options.fusion.HF_rule = 'S';
    EXP_options.fusion.adaptive_rho = 1;
    return;
end
% deblur (deb) + dehaze (H) + HF: Additive, LF: Additive + Adaptive Weight
if strcmp(case_name, 'deb+H+2A+AW')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_A';
    EXP_options.fusion.HF_rule = 'A';
    EXP_options.fusion.adaptive_rho = 1;
    return;
end
% deblur (deb) + dehaze (H) + HF: Substitutive, LF: MS + Adaptive Weight
if strcmp(case_name, 'deb+H+S+MS+AW')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'MS';
    EXP_options.fusion.HF_rule = 'S';
    EXP_options.fusion.adaptive_rho = 1;
    return;
end
% deblur (deb) + dehaze (H) + HF: Additive, LF: MS + Adaptive Weight
if strcmp(case_name, 'deb+H+A+MS+AW')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'MS';
    EXP_options.fusion.HF_rule = 'A';
    EXP_options.fusion.adaptive_rho = 1;
    return;
end



% deblur + dehaze + subsitituion + Li's weight
if strcmp(case_name, 'deb+H+S+Li')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.HF_rule = 'S';
    EXP_options.fusion.W_method = 'Li';
    return;
end     
% deblur + dehaze + subsitituion + Burt's weight
if strcmp(case_name, 'deb+H+S+Burt')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.HF_rule = 'S';
    EXP_options.fusion.W_method = 'Burt';
    return;
end      
% deblur + dehaze + subsitituion + choose-max weight
if strcmp(case_name, 'deb+H+S+max')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.HF_rule = 'S';
    EXP_options.fusion.W_method = 'max';
    return;
end    
if strcmp(case_name, 'deb+GSA+S')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GSA';
    EXP_options.prep.G_type = 'GSA-like';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
if strcmp(case_name, 'deb+seg+S')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GSA';
    EXP_options.prep.G_type = 'seg';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
if strcmp(case_name, 'deb+reg+S')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GSA';
    EXP_options.prep.G_type = 'Reg-FS';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
if strcmp(case_name, 'deb+GSA+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GSA';
    EXP_options.prep.G_type = 'GSA-like';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
if strcmp(case_name, 'deb+seg+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GSA';
    EXP_options.prep.G_type = 'seg';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
if strcmp(case_name, 'deb+reg+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GSA';
    EXP_options.prep.G_type = 'Reg-FS';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
% deblur + dehaze + subsitituion
if strcmp(case_name, 'deb+H+S')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
% deblur + dehaze + additive
if strcmp(case_name, 'deb+H+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.HF_rule = 'A';
    return;
end


% deblur + regress + additive
if strcmp(case_name, 'deb+R+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GLR';
    EXP_options.prep.G_type = 'R';
    EXP_options.fusion.HF_rule = 'A';
    return;
end
if strcmp(case_name, 'deb+R+S')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GLR';
    EXP_options.prep.G_type = 'R';
    EXP_options.fusion.HF_rule = 'S';
    return;
end
if strcmp(case_name, 'deb+H+2S')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'H';
    EXP_options.prep.G_type = 'ratio-H';
    EXP_options.fusion.LF_rule = 'Var_S';
    EXP_options.fusion.HF_rule = 'S';
    return;
end

if strcmp(case_name, 'deb+GLR+A')
    EXP_options.prep.MS_deb = 1;
    EXP_options.prep.PAN_HP = 0;
    EXP_options.prep.band_combination = 1;
    EXP_options.prep.I_type = 'GLR';
    EXP_options.prep.G_type = 'GSA-like';
    EXP_options.fusion.HF_rule = 'A';
    return;
end

error('Invalid STEM test case.');
  