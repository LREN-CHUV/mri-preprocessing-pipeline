function dwDir = freesurf_setup(dwDir)


dwDir.fsurfdir=[dwDir.subjectDir filesep 'qMRI'];
if ~exist(dwDir.fsurfdir,'dir');
    mkdir(dwDir.fsurfdir);
end


DTIdir = [dwDir.subjectDir filesep 'dti'];
NODDIdir = [dwDir.subjectDir filesep 'NODDI'];
MPMdir = [dwDir.subjectDir filesep 'MPMs'];

% Move DTI files to freesurfer directory
if exist(DTIdir,'dir')
    dti_files = {[DTIdir filesep '*FAmap.nii.gz'],[DTIdir filesep '*MDmap.nii.gz'],[DTIdir filesep '*RDmap.nii.gz'],[DTIdir filesep '*ADmap.nii.gz']};
    gunzip(dti_files,dwDir.fsurfdir)
    
end

% Move NODDI files to freesurfer directory
if exist(NODDIdir,'dir')
    NODDI_files = cellstr(pickfiles(NODDIdir,{'ficvf.nii.gz'}));
    if ~isempty(NODDI_files{1})
        NODDI_files = {[NODDIdir filesep '*ficvf.nii.gz'],[NODDIdir filesep '*fiso.nii.gz'],[NODDIdir filesep '*odi.nii.gz']};
        gunzip(NODDI_files,dwDir.fsurfdir)
    else
        NODDI_files = cellstr(pickfiles(NODDIdir,{'ficvf.nii'}));
        if ~isempty(NODDI_files{1})
            NODDI_files = {'ficvf.nii','fiso.nii','odi.nii'};
            for i=1:3
                file = cellstr(pickfiles(NODDIdir,{NODDI_files{i}}));
                [~, filename, ext] = fileparts(file{i});
                copyfile(file{i},[dwDir.fsurfdir filesep filename ext])
            end
        end
    end
end

% Move MPM files to freesurfer directory
if exist(MPMdir,'dir')
    MPM_files = {'_A.nii','_MT.nii','_R1.nii','_R2s.nii'};
    for i=1:4
        file = cellstr(pickfiles(MPMdir,MPM_files(i)));
        if exist(file{1},'file')
            [~, filename, ext] = fileparts(file{i});
            copyfile(file{i},[dwDir.fsurfdir filesep filename ext])
        end
    end
end

