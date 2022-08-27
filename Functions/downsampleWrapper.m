function Y = downsampleWrapper(X, ratio, Opts)
if exist('Opts', 'var')
    if ~isstruct(Opts)
        error('Incorrect use of parameter');
    end
else
    warning('empty opts');
    Opts = struct; 
end


offset = Opts.offset;

if Opts.using_imresize
    Y = imresize(X, 1/ratio, 'nearest'); % equal to Y(:,:,ii) = downsample(downsample(X(:,:,ii),ratio,2)',ratio,2)';
else    
    [row, col, band] = size(X);
   
    Y = zeros(floor(row/ratio), floor(col/ratio), band);
%     
    for ii = 1:size(X,3)
        Y(:,:,ii) = downsample(downsample(X(:,:,ii),ratio,offset)',ratio,offset)';

    end

end