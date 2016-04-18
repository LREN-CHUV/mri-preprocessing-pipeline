function [block prefixNII] = block_coregister(Session,prefixNII)




%%% Coregister and estimate
% block.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Bias correction: Bias corrected images', substruct('.','val', '{}',{2+length(Session.EPI)+1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','uwrfiles'));
[pp nn ee] = fileparts(Session.EPI{1,1}{1,1});
block.spm.spatial.coreg.estimate.ref(1) = {[pp filesep 'bmeanu' nn ee]};
% cfg_dep(['Realign & Unwarp: Unwarped Images (Sess ' num2str(i) ')'], substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{i}, '.','uwrfiles'));
block.spm.spatial.coreg.estimate.source = Session.Struct;
block.spm.spatial.coreg.estimate.other = {''};
block.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
block.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
block.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
prefixNII = [prefixNII];

end