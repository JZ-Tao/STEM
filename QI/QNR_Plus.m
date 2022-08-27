function [SSC_QNR_value,Dl,Ds] = QNR_Plus(ps_ms,ms,msexp,pan,S,sensorInf,ratio)
ps_ms = double(ps_ms);
pan = double(pan);
Dl = D_lambda_K(ps_ms,msexp,ratio,sensorInf,S);
Ds = D_s_R(ps_ms,pan);
%Ds = D_s_C2(ps_ms,pan,ms,sensorInf,ratio);
SSC_QNR_value = (1-Dl)*(1-Ds);

end
