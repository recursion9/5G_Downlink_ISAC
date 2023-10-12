function [dlsch,harqEntity] = dlschSetup(pdsch)
% DL-SCH SETUP:
% Specify the code rate, the number of HARQ processes, and the redundancy 
% version (RV) sequence values. This sequence controls the RV retransmissions 
% in case of error. To disable HARQ retransmissions, you can set rvSeq to a 
% fixed value (for example, 0). For more information on how to model transport 
% channels with HARQ, see Model 5G NR Transport Channels with HARQ.

%% DL-SCH Configuration
% Coding rate
if pdsch.NumCodewords == 1
    codeRate = 490/1024;
else
    codeRate = [490 490]./1024;
end
dlsch.codeRate = codeRate;
% Create DL-SCH encoder object
dlsch.encodeDLSCH = nrDLSCH;
dlsch.encodeDLSCH.MultipleHARQProcesses = true;
dlsch.encodeDLSCH.TargetCodeRate = codeRate;

% Create DLSCH decoder object
dlsch.decodeDLSCH = nrDLSCHDecoder;
dlsch.decodeDLSCH.MultipleHARQProcesses = true;
dlsch.decodeDLSCH.TargetCodeRate = codeRate;
dlsch.decodeDLSCH.LDPCDecodingAlgorithm = "Normalized min-sum";
dlsch.decodeDLSCH.MaximumLDPCIterationCount = 6;

%% HARQ Management
NHARQProcesses = 16;     % Number of parallel HARQ processes
rvSeq = [0 2 3 1];
harqEntity = HARQEntity(0:NHARQProcesses-1,rvSeq,pdsch.NumCodewords);

end

