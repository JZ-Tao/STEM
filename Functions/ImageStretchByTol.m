function [stretchedImage, t] = ImageStretchByTol(image, tol, tol_type)
if ~exist('tol','var')
    tol = [0.01, 0.99];
end
if ~exist('tol_type','var')
    tol_type = 1;
end
nDims=size(image,3);
stretchedImage=image;
[N,M,~] = size(image);
if tol_type == 0
    stretchedImage = ImageStretch(image);
    t(1) = 0; t(2) = 1;
elseif tol_type == 1
    for i=1:nDims
        b = image(:,:,i);
        t(1) =  quantile(b(:),tol(1));
        t(2)  = quantile(b(:),tol(2));

        b(b<t(1))=t(1);
        b(b>t(2))=t(2);
        b = (b-t(1))/(t(2)-t(1));
        stretchedImage(:,:,i) = reshape(b,N,M);
    end
elseif tol_type == 2
    stretchedImage = ImageStretchByfixedTol(image, tol);
elseif tol_type == 3
    for i=1:nDims
        b = image(:,:,i);
        assert(abs(mean2(b))<1);
        
        t(1) =  quantile(b(:),tol(1));
        t(2)  = quantile(b(:),tol(2));

        if abs(t(1)) > abs(t(1))
            tt = abs(t(1));
        else
            tt = abs(t(2));
        end
        b(b<-tt)=-tt;
        b(b>tt)=tt;
        b = (b+tt)/(tt*2);
        stretchedImage(:,:,i) = reshape(b,N,M);
    end
    stretchedImage = ImageStretchByfixedTol(image, tol);
else
    stretchedImage = image;
end



