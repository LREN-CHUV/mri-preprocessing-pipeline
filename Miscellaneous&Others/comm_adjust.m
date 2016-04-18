function [M,R] = comm_adjust(option,Ref,Modality,Other,Nits,doshear)

if option,
    switch nargin
        case 1, Nits = 2; doshear = 0; 
            Modality = input('modality of image?: ','s');
            Ref = myselect(Inf,'image','select file to adust',sel,wd,'.*','1');
            Other = myselect(Inf,'image','select other files to adust','',pwd,'.*','1');
            if isempty(Other), filenames = Ref; else
                filenames = unique(strvcat(Ref,Other),'rows');
            end
        case 2,
            Modality = input('modality of image?: ','s');
            Other = myselect(Inf,'image','select other files to adust','',pwd,'.*','1');
             if isempty(Other), filenames = Ref; else
                filenames = unique(strvcat(Ref,Other),'rows');
            end
        case 3, Nits = 2; doshear = 0;
            Other = myselect(Inf,'image','select other files to adust','',pwd,'.*','1');
             if isempty(Other), filenames = Ref; else
                filenames = unique(strvcat(Ref,Other),'rows');
            end
        case 4, Nits = 2; doshear = 0; 
            filenames = unique(strvcat(Ref,Other),'rows');
        case 5, doshear = 0; 
            filenames = unique(strvcat(Ref,Other),'rows');
        case 6, doshear = logical(doshear); 
            filenames = unique(strvcat(Ref,Other),'rows');
        otherwise, error('too or few inputs!')
    end
else
    switch nargin
        case 2, Nits = 2; doshear = 0; filenames = Ref; Modality = 'T1';
        case 3, Nits = 2; doshear = 0; filenames = Ref;
        case 4, Nits = 2; doshear = 0; 
            filenames = unique(strvcat(Ref,Other),'rows');
        case 5, doshear = 0;
            filenames = unique(strvcat(Ref,Other),'rows');
        case 6, doshear = logical(doshear);
            filenames = unique(strvcat(Ref,Other),'rows');
        otherwise, error('too or few inputs!')
    end
end
sep = 8./[1 2 4*ones(1,Nits)];
Tmp = sprintf('%s//templates//%s.nii',spm('Dir'),Modality);
flags = struct('WG'      ,[]    ,...
               'WF'      ,[]    ,...
               'sep'     ,8     ,...
               'regtype' ,'mni' ,...
               'globnorm',0);
           
VRef = spm_smoothto8bit(spm_vol(Ref),8);
VTmp = spm_smoothto8bit(spm_vol(Tmp),0);
VRef.pinfo(1:2,:) = VRef.pinfo(1:2,:)/spm_global(VRef);
VTmp.pinfo(1:2,:) = VTmp.pinfo(1:2,:)/spm_global(VTmp);

[M,scal] = spm_affreg(VTmp,VRef,flags,eye(4));
for i = 2:Nits,
    flags.sep = sep(i);
    [M,scal] = spm_affreg(VTmp,VRef,flags,M,scal); %VTmp.mat\M*VRef.mat
end
if doshear, R = M; else, 
    [A,B,C] = svd(M(1:3,1:3)); R = A*C';
    R(:,4) = R*(M(1:3,1:3)\M(1:3,4)); R(4,4) = 1;
end
warning off
h = waitbar(0,'reorienting to AC-PC line...');
for i = 1:size(filenames,1),
    spm_get_space(deblank(filenames(i,:)),...
        R*spm_get_space(deblank(filenames(i,:))));
    waitbar(i/size(filenames,1),h);
end
close(h);
warning on