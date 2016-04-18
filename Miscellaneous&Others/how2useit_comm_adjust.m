b0 = b0FileName; %  b0FileName : Full path name for image EPI 
T1 = T1FileName; % T1FileName; Full path name for T1 image
Niter = 8;
comm_adjust(1,b0,'EPI',b0,Niter,0);
comm_adjust(1,T1,'T1',T1,Niter,0);