function I_Interpolated = interpByKernel(I_Interpolated,ratio,kernel,offset, cascade)

if ~exist('offset','var')
    offset = floor(ratio/2);
end

if ~exist('cascade','var')
    cascade = 0;
end

[r,c,b] = size(I_Interpolated);
if size(kernel,3) == 1
    kernel = repmat(kernel, [1,1,b]);
end

if ~cascade
    % ¿¼ÂÇ4±¶Çé¿ö
    % offset:[1,0]---> off: 2
    % offset:[0,0]---> off: 0
    % off = ((1*2-1+offset(1))*2-1)+offset(2) - 1;
    off = 1;
    for z = 1 : log2(ratio)
        off = off*2-1+offset(z);
    end
    off = off - 1;
    I1LRU = zeros(ratio.*r, ratio.*c, b);    
    I1LRU(1+off:ratio:end,1+off:ratio:end,:) = I_Interpolated;

    for ii = 1 : b
        t = I1LRU(:,:,ii); 
        I1LRU(:,:,ii) = imfilter(t,kernel(:,:,ii),'circular'); 
    end

    I_Interpolated = I1LRU;
else
    first = 1;
    for z = 1 : log2(ratio)

        I1LRU = zeros((2^z) * r, (2^z) * c, b);
        if first
            I1LRU(1+offset(1):2:end,1+offset(1):2:end,:) = I_Interpolated;
            first = 0;
        else
            I1LRU(1+offset(2):2:end,1+offset(2):2:end,:) = I_Interpolated;
        end
         for ii = 1 : b
            t = I1LRU(:,:,ii); 
            t = imfilter(t',kernel,'circular'); 
            I1LRU(:,:,ii) = imfilter(t',kernel,'circular'); 
         end
        I_Interpolated = I1LRU;
    end
end

end