function Y = interpWrapper(X, ratio, Opts)
if exist('Opts', 'var')
    if ~isstruct(Opts)
        error('Incorrect use of parameter');
    end
else
    warning('empty opts');
    Opts = struct;
end

if ~isfield(Opts, 'tap')
    Opts.tap = -1; 
end
type = Opts.interp_type;
interplator = Opts.interplator;
offset = Opts.offset;
tap = Opts.tap;


switch(interplator)
    case 'general'
        Y = interp23tapGeneral(X,ratio,tap, offset);
    case 'bicubic'
        Y = imresize(X, ratio);
    otherwise
        Y = interpDefault(X,ratio, tap, offset);
end