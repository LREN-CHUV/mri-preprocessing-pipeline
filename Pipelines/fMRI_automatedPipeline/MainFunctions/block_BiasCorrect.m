function [block prefixNII] = block_BiasCorrect(Session,prefixNII)

    %%% Sessions bias correction:
    
    for i = 1:length(Session.EPI)
        block{i}.spm.tools.biasCorrect.data{1}(1) = cfg_dep(['Realign & Unwarp: Unwarped Images (Sess ' num2str(i) ')'], substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{i}, '.','uwrfiles'));
    end
    batchLength = length(block);
    block{batchLength+1}.spm.tools.biasCorrect.data{1}(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
    prefixNII = ['b' prefixNII];

end