function shear_f = generateShearFilter(sz, shear_parameters)
level=length(shear_parameters.dcomp);
L = sz(1);
shear_f=cell(1,level); % declare cell array containing shearing filters
for i=1:level
    w_s=shearing_filters_Myer(shear_parameters.dsize(i),shear_parameters.dcomp(i));
    for k=1:2^shear_parameters.dcomp(i)
       shear_f{i}(:,:,k) =(fft2(w_s(:,:,k),L,L)./L); 
    end
end

for i=1:level 
    d=sum(shear_f{i},3);
    for k=1:2^shear_parameters.dcomp(i)
        shear_f{i}(:,:,k)=shear_f{i}(:,:,k)./d;
    end
end