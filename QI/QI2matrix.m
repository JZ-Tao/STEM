function QI_matrix = QI2matrix(QI_, Method_, Time_, is_FS)
k = length(QI_);
col = 1;
% First row
QI_matrix{1,col} = 'Method'; col = col+1;
if is_FS
    QI_matrix{1,col} = 'D_lambda_K';col = col+1;
    QI_matrix{1,col} = 'D_S';col = col+1;
    QI_matrix{1,col} = 'D_S_R';col = col+1;
    QI_matrix{1,col} = 'HQNR';col = col+1;
    QI_matrix{1,col} = 'QNR_Plus';col = col+1;
    QI_matrix{1,col} = 'C_Q2n';col = col+1;
else
    QI_matrix{1,col} = 'SAM';col = col+1;
    QI_matrix{1,col} = 'ERGAS';col = col+1;
    QI_matrix{1,col} = 'RMSE';col = col+1;
    QI_matrix{1,col} = 'MSSIM';col = col+1;
    QI_matrix{1,col} = 'Q2n';col = col+1;
end
QI_matrix{1,col} = 'Time';col = col+1;

if is_FS
    for i = 1:k
        col = 1;
        QI_matrix{i+1,col} = Method_{i}; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.D_lambda_K; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.D_S; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.D_S_R; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.HQNR; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.QNR_Plus; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.Q; col = col+1;
        QI_matrix{i+1,col} = Time_{i}; col = col+1;
    end        
else
    for i = 1:k
        col = 1;
        QI_matrix{i+1,col} = Method_{i}; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.SAM; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.ERGAS; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.RMSE; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.SSIM; col = col+1;
        QI_matrix{i+1,col} = QI_{i}.Q; col = col+1;
        QI_matrix{i+1,col} = Time_{i}; col = col+1;
    end    
end