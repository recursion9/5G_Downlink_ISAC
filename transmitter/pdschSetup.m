function [pdsch] = pdschSetup(carrier)
%PDSCHSETUP 此处显示有关此函数的摘要
%   Create a PDSCH configuration object. Specify the modulation scheme (16-QAM) 
% and the number of layers (2). Allocate all resource blocks (RBs) to the 
% PDSCH (full band allocation). You can also specify other time-allocation 
% parameters and demodulation reference signal (DM-RS) settings in this object.

%% PDSCH Parameters
pdsch = nrPDSCHConfig;
pdsch.Modulation = "16QAM";
pdsch.NumLayers = 2;
pdsch.PRBSet = 0:carrier.NSizeGrid-1;     % Full band allocation

%% DM-RS parameters
pdsch.DMRS.DMRSAdditionalPosition = 1;
pdsch.DMRS.DMRSConfigurationType = 1;
pdsch.DMRS.DMRSLength = 2;
end

