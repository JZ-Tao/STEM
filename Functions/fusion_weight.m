function W = fusion_weight(M1, M2, W_method, um, th)
% modified from Oliver Rockingers' code
if ~exist('um', 'var'), um = 3; end
if ~exist('th', 'var'), th = .75; end
switch(W_method)
    case 'HR'
        W = 1;
    case 'max'
 		% choose max(abs)
 		W = (abs(M1)) > (abs(M2));
        %Y  = (W.*M1) + ((~W).*M2);
 	case 'Burt'
        % Burts method. Salience / match measure with threshold 
        % compute salience 
        S1 = conv2(es2(M1.*M1, floor(um/2)), ones(um), 'valid'); 
        S2 = conv2(es2(M2.*M2, floor(um/2)), ones(um), 'valid'); 
        % compute match 
        MA = conv2(es2(M1.*M2, floor(um/2)), ones(um), 'valid');
        MA = 2 * MA ./ (S1 + S2 + eps);
        % selection 
        m1 = MA > th; m2 = S1 > S2; 
        w1 = (0.5 - 0.5*(1-MA) / (1-th)); 
        % Low matching degree, S decides who to use
        % Y  = (~m1) .* ((m2.*M1) + ((~m2).*M2)); 
        % High matching degree, mix the two according to S
        % Y  = Y + (m1 .* ((m2.*M1.*(1-w1))+((m2).*M2.*w1) + ((~m2).*M2.*(1-w1))+((~m2).*M1.*w1)));  
        W = ((~m1).*m2)+(m1.*m2.*(1-w1) + (~m2).*w1);
    case 'Li'
        % Li's method. Choose max with consistency check 
        % first step
        A1 = ordfilt2(abs(es2(M1, floor(um/2))), um*um, ones(um));
        A2 = ordfilt2(abs(es2(M2, floor(um/2))), um*um, ones(um));
        % second step
        W = (conv2(double((A1 > A2)), ones(um), 'valid')) > floor(um*um/2);
        %Y  = (W.*M1) + ((~W).*M2);
    otherwise
        error('unkown option');
end