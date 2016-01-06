function EPI_readout_time = EPI_readout_lookup(filename)

% Cell list of all sequence names
Seqs = {'ep2d_diff_NODDI_2mm_64ch','ep2ddiffNODDI64ch2mm101dirs', 'ep2ddiffNODDI2mm64chs','ep2ddiffwip', ...
    'ep2d_diff_NODDI_64ch_2mm_101dirs_bmax2300', 'ep2d_diff_NODDI_MB2_2pt2mm'};
readout_times = {550e-3*106/2, 550e-3*106/2, 550e-3*106/2, 0.69*128*1.1*6/8/3 ...
    550e-3*106/2, 510e-3*94};

K = '';
EPI_readout_time = '';


for i=1:length(Seqs)
    if isempty(K)
        K = strfind(filename, Seqs{i});
        
        if ~isempty(K)
            EPI_readout_time = readout_times{i};
        end
    end
end
