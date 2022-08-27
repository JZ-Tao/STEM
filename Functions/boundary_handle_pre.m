function Y = boundary_handle_pre(X, padding_size, boundary_handle_type, opts)
if size(padding_size) == 1
    padding_size = [padding_size padding_size];
end

switch boundary_handle_type
    case 1 % option (1), edgetaper to better handle circular boundary conditions, (matlab2015b)
        % k(k==0) = 1e-10; % uncomment this for matlab 2016--2018?
        h1 = opts.PSF_G;
%         Y = padarray(X, padding_size, 'replicate', 'both');
%         for ii = 1:size(X,3)
%         	Y(:,:,ii) = edgetaper(Y(:,:,ii),ones(padding_size(1),padding_size(2))./((padding_size(1))^2));
%         end
%         for i = 1:4
%             Y = edgetaper(Y, h1);
%         end
        n_band = size(X,3);
        t_pad = padarray(X(:,:,1), padding_size, 'replicate', 'both');
        Y = zeros([size(t_pad,1), size(t_pad,2), n_band]);
        for i = 1:n_band
            Y(:,:,i) = padarray(X(:,:,i), padding_size, 'replicate', 'both');
            for  ii = 1:4
                Y(:,:,i) = edgetaper(Y(:,:,i), h1(:,:,i));
            end
        end

    case 2 % option (2)
        H = size(X,1);    W = size(X,2);
        Y = wrap_boundary_liu(X, opt_fft_size([H W]+padding_size));
    case 3 % option (3)
        Y = padarray(X, padding_size, 'circular', 'both');
    otherwise
        Y = X;
end 