function convert_tck2trk(tckfile,anatfile)

%======================================
%  Starting MRTrix to TrackVis convert
%======================================

[savepath, savename] = fileparts(tckfile);

% Load MRTrix track data
MRTrix_tck = read_mrtrix_tracks(tckfile);
anat_nii =  niftiRead(anatfile);

id_string=['TRACK'];
dim(1)=anat_nii.dim(1);
dim(2)=anat_nii.dim(2);
dim(3)=anat_nii.dim(3);
voxel_size(1)=anat_nii.pixdim(1);
voxel_size(2)=anat_nii.pixdim(2);
voxel_size(3)=anat_nii.pixdim(3);
origin=[0 0 0];
n_scalars=0;


for i=1:10
    scalar_name(i,1:20)=0;
end

n_properties=0;


for i=1:10
    property_name(i,1:20)=0;
end

reserved(1:508)=0;
voxel_order=['RAS'];
pad2=['RAS'];
image_orientation=[-1 0 0 0 -1 0];
pad1=0;


invert_x=uint8(0);
invert_y=uint8(0);
invert_z=uint8(0);
swap_xy=uint8(0);
swap_yz=uint8(0);
swap_zx=uint8(0);


n_count=length(MRTrix_tck.data);
version=1;
hdr_size=1000;



%============================================
%  Shift by anatomical image offset
%============================================

disp('reordering data...')

% *** NOTE: Currently only works on resliced data. No rotations!!! ***
tic
for t=1:n_count
    MRTrix_tck.data{t}(:,1) = MRTrix_tck.data{t}(:,1)-anat_nii.qoffset_x;
    MRTrix_tck.data{t}(:,2) = MRTrix_tck.data{t}(:,2)-anat_nii.qoffset_y;
    MRTrix_tck.data{t}(:,3) = MRTrix_tck.data{t}(:,3)-anat_nii.qoffset_z;
end
toc




%======================================
%  Writing TRK
%======================================
trkfile=[fullfile(savepath,savename),'_Tracts.trk'];

fid=fopen(trkfile,'wb','l');

fwrite(fid,id_string,'char');
fwrite(fid,0,'uint8'); %PAD
fwrite(fid,dim,'int16');
fwrite(fid,voxel_size,'float32');
fwrite(fid,origin,'float32');

fwrite(fid,n_scalars,'int16');
fwrite(fid,scalar_name,'uint8');
fwrite(fid,n_properties,'int16');
fwrite(fid,property_name,'uint8');

fwrite(fid,reserved,'uint8');
fwrite(fid,voxel_order,'char');
fwrite(fid,0,'uint8'); %PAD
fwrite(fid,pad2,'char');
fwrite(fid,0,'uint8'); %PAD
fwrite(fid,image_orientation,'float32');
fwrite(fid,pad1,'int16'); %double pad uint8

fwrite(fid,invert_x,'uchar');
fwrite(fid,invert_y,'uchar');
fwrite(fid,invert_z,'uchar');
fwrite(fid,swap_xy,'uchar');
fwrite(fid,swap_yz,'uchar');
fwrite(fid,swap_zx,'uchar');


fwrite(fid,n_count,'int32');
fwrite(fid,version,'int32');
fwrite(fid,hdr_size,'int32');

disp('saving....')



tic
for t=1:n_count
    fwrite(fid,length(MRTrix_tck.data{t}),'int32');
    fwrite(fid,MRTrix_tck.data{t}','float32');
    
end
toc
fclose(fid);






