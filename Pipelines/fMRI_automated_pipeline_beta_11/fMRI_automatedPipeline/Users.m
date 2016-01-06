%Description: User interface for Flexible automated preprocessing of fMRI data using SPM
% Fanny Michel, July 2014

% Renaud Marquis, EDIT August 2014:
warning('!! This function is not up-to-date anymore!, Not all necessary fields will be used anymore !!')

fprintf('Welcome in the User interface for Flexible automated preprocessing of fMRI data using SPM ! \n')
example= 'C:\DATA\my_study';
fprintf('Enter the path for your study (for example : %s )\n', example);
Q= 'Path: \n';
path = input(Q, 's');
fprintf(' \n')


Q= 'Do you want to enter specific options : "Y" or "N" (if no is selected, it will use the default values)? \n';
options=input(Q,'s');

if options=='N' %Use the default values
        fprintf(' \n')
        fprintf('Processing of the data with the default values... \n')
        [matlabbatch Session Opts]=fMRI_automated_preproc(path) 

elseif options=='Y' %Fill the structure of options
        fprintf('Enter the options to treat your fMRI data (if nothing is entered for a specific option, it will be set by default) \n')
        Opts=[];
        
        Q = '*Mode : type "interactive" (by default) or "run"\n';
        Opts.Mode = input(Q, 's');
             
        fprintf(' \n')

        fprintf('*Minimum Volume Number: minimal number of EPI volumes in an experimental session \n') 
        fprintf('(if below this number, used to ignore aborted experimental runs), 10 by default \n')
        Q = 'MinVolNum ? (scalar)\n';
        Opts.MinVolNum = input(Q);
               
        fprintf(' \n')

        %Pose problem si le champ est crée mais qu'il est vide.
%         Q = '*FieldMapDefaults : .m file with default values for EPI image distortion correction using FieldMap toolbox. Enter the path. \n';
%         Opts.FieldMapDefaults = input(Q, 's');
       

        fprintf(' \n')

        fprintf('*RunDARTEL: numerical, can be 1 (create DARTEL template from sample and estimate flow fields to normalize to MNI space) \n') 
        fprintf('or 0 (uses deformation fields with default SPM template instead (by default)). \n')
        Q = 'RunDARTEL ? (1 or 0)\n';
        Opts.RunDARTEL = input(Q);

        fprintf(' \n')

        %By default: DummyScans=0
%         fprintf('*DummyScans: number of dummy scans at the beginning of each fMRI session (0 by default) \n') 
%         fprintf('If DummyScans is bigger than 0, the corresponding number of scans will be placed in a separate folder called "dummies" inside the EPI session folder \n')
%         Q = 'DummyScans ? (scalar)\n';
%         Opts.DummyScans = input(Q);
% 
%         fprintf(' \n')

        fprintf('*TokenStruct: keyword used to detect the folder containing the anatomical image \n')
        Q = 'TokenStruct (string) ? (By default, it is set to "mprage") \n';
        Opts.TokenStruct = input(Q, 's'); 

        fprintf(' \n')

        fprintf('*TokenEPI: keyword used to detect the folder(s)containing the functional scans \n')
        Q = 'TokenEPI (string) ? (By default, it is set to "al_mepi") \n';
        Opts.TokenEPI = input(Q, 's'); 

        fprintf(' \n')

        fprintf('*RegisterToMean: numerical, can be 1 (during realignement, register to the mean (by default) using a two-pass procedure) \n') 
        fprintf('or 0 (register to first) \n')
        Q = 'RegisterToMean ? (1 or 0)\n';
        Opts.RegisterToMean = input(Q);

        fprintf(' \n')

        fprintf('*FWHM: Full width at half maximum. 1 x 3 numerical, defines the smoothing kernel in x-, y- and z-directions \n') 
        Q = 'FWHM ? (for example type "[8 8 8]" )\n';
        Opts.FWHM = input(Q);

        fprintf(' \n')

        fprintf('*DetectResolution: numerical, can be 1 \n')
        fprintf('(use the token "mm" to detect potential presence of multiple EPI datasets at different resolutions (and process them separately by duplicating folders containing B0  maps and structural scan))\n')
        fprintf('or 0 (assumes all datasets (if several in each subjects folder) have the same resolution). \n')
        %%%% EST CE QU'ON LAISSE COMME CA ??? % If set to 1 and if DummyScans is bigger than 0, then dummies will be discarded only for 3mm resolution EPI sequences.
        Q = 'DetectResolution ? (1 or 0)\n';
        Opts.DetectResolution = input(Q);
       
        fprintf(' \n')
        
        fprintf('*CorrectPhysioNoise: scalar: 1 or 0 \n')
        fprintf('0(by default):include movement parameters estimated during realignment to remove residual artifacts due to head movement during 1st level modeling \n')
        fprintf('1:use physiological data to apply RETROspective Image-based CORrection of physiological noise in fMRI data. Need additional parameters. \n')
        Q = 'CorrectPhysioNoise (0 or 1) ? \n';
        Opts.CorrectPhysioNoise = input(Q); 
            if Opts.CorrectPhysioNoise==1 %ask for the other parameters
             Q='PhysioPathFilename : cell of string of the file name for physiological data ? \n';
             Opts.CorrectPhysioNoise.PhysioPathFilename=input(Q,s);
             Q='sampling_rate : ... of physiological data (cell of scalars) ? \n';
             Opts.CorrectPhysioNoise.sampling_rate=input(Q); %vérifier si on peut mettre un cell of scalars
             Q='TRslice : slice TR (cell of scalars) ? \n';
             Opts.CorrectPhysioNoise.TRslice=input(Q); %pareil, à vérifier
             Q='Nslices : number of slices (per EPI volume) (cell of scalars) ? \n';
             Opts.CorrectPhysioNoise.Nslices=input(Q); %idem
             Q='sliceorder : "descending", "ascending", or "interleaved" ? \n';
             Opts.CorrectPhysioNoise.sliceorder=input(Q,s);
             Q='SliceNum : reference slice (usually half of Nslices) (cell of scalars) ? \n';
             Opts.CorrectPhysioNoise.SliceNum=input(Q); %idem
             Q='MultipleSessInFile : 1 (if multiple sessions in(each) physiological datafile) or 0 ? \n';
             Opts.CorrectPhysioNoise.MultipleSessInFile=input(Q);
            % Ndummies : cell of scalars, number of dummy scans
            %                       for each experimental session (be careful with the
            %                       correspondance regarding the order of the session
            %                       (see remark above))
            %%% utiliser Opts.DummyScans ??? A VOIR
            end
       
       fprintf(' \n')
       
       fprintf('*RunFirstLevel: scalar 1 or 0 (by default) \n')
       fprintf('1: run 1st level analysis and estimate the models. In this case, need to fill other parameters \n')
       Q='RunFirstLevel (0 or 1) ? \n';
       Opts.RunFirstLevel=input(Q);
       if Opts.RunFirstLevel==1
           
          Q='ModelFolderName: string that specifies folder name containing ModelFilename (If not specified,ModelFolderName has to be at the root of each subject folder) ? \n';
          Opts.ModelFolderName=input(Q,'s');
          Q=' ModelFilename : .mat file containing details of the experimental paradigm ? \n';
          Opts.ModelFilename=input(Q,'s');
          % ????? It must include the following cell arrays (each 1 x n): names,
          % onsets and durations (see SPM help for fMRI model specification, section Multiple conditions for additional information).
          fprintf('TR : repetition time(s) of the EPI sequence(s) in seconds. If multiple resolutions, the vector must be sorted from higher to lower resolution \n')
          Q='TR:scalar or 1 x n vector (where n is the number of different resolutions used). Ex:[4.032 2.704 1.98] higher resolution(1pt5mm)has a TR of 4.032, and the lower(3mm) has a TR of 1.98 seconds\n';
          Opts.TR=input(Q);
          Q='Unit : string, unit used for the onsets and durations specifying the GLM of the first level analysis, can be "secs" or "scans" \n'
          Opts.Unit=input(Q,s);
          Q='Contrasts: "F" or "T" ?\n';
          Opts.Contrasts=input(Q);
          Q='Name ? For example "a minus d" \n';
            if Opts.Contrasts=='T'
                Contrasts.T{1}.name=input(Q,s);
            elseif Opts.Contrasts=='F'
                Contrasts.F{1}.name=input(Q,s);
            end
          Q='Weights ? For example "[1 0 0 -1]" \n';
            if Opts.Contrasts=='T'
                Contrasts.T{1}.weights=input(Q);
            elseif Opts.Contrasts=='F'
                Contrasts.F{1}.weights=input(Q);
            end
        
       end

        fprintf(' \n')
        fprintf('Options saved successfully \n')
        
        %%Call the pipeline with the options
        fprintf('Processing of the data... \n')
        [matlabbatch Session Opts]=fMRI_automated_preproc(path,Opts)
        % après on pourrait modifier la fonction pour renvoyer les préfixes pour voir si la fonction a fait tous les niveaux (wb...) [matlabbatch Session prefixNII Opts]=fMRI_automated_preproc(path,Opts)
        
       [matlabbatch Opts]=fMRI_automated_first_level(Session,Opts) %pas tester ça pour l'instant, sert pour correction physio noise
end

