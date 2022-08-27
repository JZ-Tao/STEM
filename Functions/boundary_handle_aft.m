function Y = boundary_handle_aft(X, sz_X, boundary_handle_type)

switch boundary_handle_type
    case 1 % option (1)
        Y = center_crop(X,sz_X(1),sz_X(2));
    case 2 % option (2)
        Y = X(1:sz_X(1),1:sz_X(2),:);
    case 3 % option (3)
        Y = center_crop(X,sz_X(1),sz_X(2));
    otherwise
        Y = X;
end