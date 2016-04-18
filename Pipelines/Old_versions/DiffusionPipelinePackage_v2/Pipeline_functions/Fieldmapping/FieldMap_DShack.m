function out_img=FieldMap_DShack(img_vol,IP,tM)

% This is an adapted version of the FieldMap 'unwarpepi' section. The
% purpose is to allow image data to be fed in from a 4-D nifti DWI dataset
% which is then read in by spm_sample_vol on line 44. The output image can
% then be recombined into a warp corrected 4D nii.

%
      % Update unwarped EPI
      %
%       IP=varargin{2};
      IP.uepiP = struct('fname',   'Image in memory',...
                        'dim',     IP.epiP.dim,...
                        'dt',[64 spm_platform('bigend')],...
                        'pinfo',   IP.epiP.pinfo(1:2),...
                        'mat',     IP.epiP.mat);

      % Need to sample EPI and voxel shift map in space of EPI...
      [x,y,z] = ndgrid(1:IP.epiP.dim(1),1:IP.epiP.dim(2),1:IP.epiP.dim(3));
      xyz = [x(:) y(:) z(:)];

      % Space of EPI is IP.epiP{1}.mat and space of 
      % voxel shift map is IP.vdmP{1}.mat 
%       tM=inv(IP.epiP.mat\IP.vdmP.mat);

      x2 = tM(1,1)*x + tM(1,2)*y + tM(1,3)*z + tM(1,4);
      y2 = tM(2,1)*x + tM(2,2)*y + tM(2,3)*z + tM(2,4);
      z2 = tM(3,1)*x + tM(3,2)*y + tM(3,3)*z + tM(3,4);
      xyz2 = [x2(:) y2(:) z2(:)];

      %
      % Make mask since it is only meaningful to calculate undistorted
      % image in areas where we have information about distortions.
      %
      msk = reshape(double(xyz2(:,1)>=1 & xyz2(:,1)<=IP.vdmP.dim(1) &...
                   xyz2(:,2)>=1 & xyz2(:,2)<=IP.vdmP.dim(2) &...
                   xyz2(:,3)>=1 & xyz2(:,3)<=IP.vdmP.dim(3)),IP.epiP.dim(1:3));
              
      % Read in voxel displacement map in correct space
      tvdm = reshape(spm_sample_vol(spm_vol(IP.vdmP.fname),xyz2(:,1),...
                      xyz2(:,2),xyz2(:,3),1),IP.epiP.dim(1:3));

      % Voxel shift map must be added to the y-coordinates. 
      uepi = reshape(spm_sample_vol(img_vol,xyz(:,1),...
                      xyz(:,2)+tvdm(:),xyz(:,3),1),IP.epiP.dim(1:3));% TEMP CHANGE
      
      % Sample Jacobian in correct space and apply if required 
      if IP.ajm==1
         if IP.epifm==1 % If EPI, use inverted jacobian

            IP.jim = reshape(spm_sample_vol(IP.vdm.ijac,xyz2(:,1),...
                      xyz2(:,2),xyz2(:,3),1),IP.epiP.dim(1:3));
         else
            IP.jim = reshape(spm_sample_vol(IP.vdm.jac,xyz2(:,1),...
                      xyz2(:,2),xyz2(:,3),1),IP.epiP.dim(1:3));
         end  
         uepi = uepi.*(1+IP.jim);
      end

      IP.uepiP.dat=uepi; %.*msk;
      out_img=IP.uepiP;