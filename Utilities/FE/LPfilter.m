function HRPanLP = LPfilter(HRPan,Resize_fact)

h=[1 4 6 4 1 ]/16;
g=[0 0 1 0 0 ]-h;
htilde=[ 1 4 6 4 1]/16;
gtilde=[ 0 0 1 0 0 ]+htilde;
h=sqrt(2)*h;
g=sqrt(2)*g;
htilde=sqrt(2)*htilde;
gtilde=sqrt(2)*gtilde;
WF={h,g,htilde,gtilde};

Levels = ceil(log2(Resize_fact));

WT = ndwt2_working(HRPan,Levels,WF);

for ii = 2 : numel(WT.dec), WT.dec{ii} = zeros(size(WT.dec{ii})); end

HRPanLP = indwt2_working(WT,'c');

end