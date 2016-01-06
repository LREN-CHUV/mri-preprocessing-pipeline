function fname = do_prop(PT,PY, tdir)

if nargin<1, PT = spm_select(2,'^c.*\.nii'); end;
if nargin<2, PY = spm_select(1,'y_.*\.nii'); end
if nargin<3, tdir = tempdir; end

if size(PT,1)~=2, error('Wrong number of tissue classes.'); end;
if size(PY,1)~=1, error('Wrong number of deformations.'); end

Nic = nifti(PT);
T{numel(Nic)+1} = 1;
for c=1:numel(Nic),
    T{c} = Nic(c).dat(:,:,:);
    T{numel(Nic)+1} = T{numel(Nic)+1} - T{c};
end

if 1,
    defs.comp{1}.inv.comp{1}.def = {PY};
    defs.comp{1}.inv.space = {PT(1,:)};
    defs.out{1}.savedef.ofname = sprintf('%.6d', round(rand(1)*1000000));
    defs.out{1}.savedef.savedir.saveusr = {tempdir};
    out  = spm_deformations(defs);
    Niy  = nifti(out.def{1});
    Y0   = squeeze(single(Niy.dat(:,:,:,:,:)));
    delete(out.def{1});
else
    Niy  = nifti(PY);
    Y0   = squeeze(single(Niy.dat(:,:,:,:,:)));
end
M    = inv(spm_get_space(fullfile(tdir,'label000_c1.nii')));
Y    = zeros(size(Y0),'single');
for d=1:3,
    Y(:,:,:,d) = Y0(:,:,:,1)*M(d,1) + Y0(:,:,:,2)*M(d,2) + Y0(:,:,:,3)*M(d,3) + M(d,4);
end

L = zeros(size(T{1}),'uint8');
P = zeros(size(T{1}),'single');
maxlabel = 256;
volumes  = zeros(maxlabel,1);
for k=0:maxlabel,
    fn  = fullfile(tdir,sprintf('label%.3d_c%d.nii', k,1));
    if exist(fn,'file'),
        P1   = 0;
        fn   = fullfile(tdir,sprintf('label%.3d_c%d.nii', k,c));
        Nii  = nifti(fn);
        MM   = M*Nii.mat;
        MM   = MM(1:3,4);
        Y1   = Y;
        Y1(:,:,:,1) = Y(:,:,:,1) - MM(1);
        Y1(:,:,:,2) = Y(:,:,:,2) - MM(2);
        Y1(:,:,:,3) = Y(:,:,:,3) - MM(3);
        for c=1:(numel(Nic)+1),
            fn   = fullfile(tdir,sprintf('label%.3d_c%d.nii', k,c));
            Nii  = nifti(fn);
            Pdat = single(Nii.dat(:,:,:));
            Pdat = spm_diffeo('bsplins',Pdat,Y1,[1 1 1 0 0 0]);
            P1   = P1 + Pdat.*T{c};
        end
        clear Y1
        if k==0,
            P1(~isfinite(P1)) = 1;
        else
            P1(~isfinite(P1)) = 0;
        end
        if k>0,
            % Volume in cc
            tiss_vol   = sum(P1(:)).*abs(det(Nic(1).mat(1:3,1:3)))/1000;
            volumes(k) = tiss_vol;
            fprintf('%.3d %g\n', k, tiss_vol);
        end
        [P,tmp] = max([P(:),P1(:)],[],2);
        P   = reshape(P,size(T{1}));
        L(tmp==2) = k;
        %ofn = sprintf('test_label%.3d.nii', k);
        %dat = file_array(ofn,size(T{1}),'float32',0,1,0);
        %Nio = nifti;
        %Nio.dat = dat;
        %Nio.mat = Nic(1).mat;
        %create(Nio);
        %Nio.dat(:,:,:) = P1;
    end
end
[pth,nam,ext] = fileparts(deblank(PT(1,:)));
fname = fullfile(pth,['label_' nam(3:end) '.nii']);
dat = file_array(fname,size(T{1}),'uint8',0,1,0);
Ni1 = nifti;
Ni1.dat = dat;
Ni1.mat = Nic(1).mat;
create(Ni1);
Ni1.dat(:,:,:) = L;

save(fullfile(pth,['volumes_' nam(3:end) '.txt']),'volumes','-ascii');


