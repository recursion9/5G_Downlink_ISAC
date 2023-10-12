function [decbits,blkerr,harqEntity,newPrecodingWeight] = downlinkReceiver(txWaveform,waveformInfo,carrier,pdsch,dlsch,elementsParam,simParam,harqEntity,channel,newPrecodingWeight)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

%% Communication Channel
nRxAnts = elementsParam.ueParam.ueAntCommRxNum;
chInfo = info(channel);
maxChDelay = ceil(max(chInfo.PathDelays*channel.SampleRate)) + chInfo.ChannelFilterDelay;
txWaveform = [txWaveform; zeros(maxChDelay,size(txWaveform,2))];
[rxWaveform,pathGains,sampleTimes] = channel(txWaveform);
noise = generateAWGN(simParam.SNRdB,nRxAnts,waveformInfo.Nfft,size(rxWaveform));
rxWaveform = rxWaveform + noise;      % 15371x8 complex double

%% Timing Synchronization
dmrsSymbols = nrPDSCHDMRS(carrier,pdsch);
dmrsIndices = nrPDSCHDMRSIndices(carrier,pdsch);
offset = simParam.offset;
perfectEstimation = simParam.perfectEstimation;
if perfectEstimation
    % Get path filters for perfect timing estimation
    pathFilters = getPathFilters(channel); 
    [offset,mag] = nrPerfectTimingEstimate(pathGains,pathFilters);
else
    % practical timing estimation
    [t,mag] = nrTimingEstimate(carrier,rxWaveform,dmrsIndices,dmrsSymbols);
    offset = hSkipWeakTimingOffset(offset,t,mag);
end
% Compensating for timing offset
rxWaveform = rxWaveform(1+offset:end,:);

%% OFDM Demodulation
% Channel estimation provides a representation of the channel effects per resource element (RE). 
rxGrid = nrOFDMDemodulate(carrier,rxWaveform); % 624x14x8 complex double
% Get precoding matrix for current slot
precodingWeights = newPrecodingWeight;
% Perform perfect or practical channel estimation.
if perfectEstimation
    % Perform perfect channel estimation between transmit and receive
    % antennas.
    estChGridAnts = nrPerfectChannelEstimate(carrier,pathGains,pathFilters,offset,sampleTimes);
    % Get perfect noise estimate (from noise realization)
    noiseGrid = nrOFDMDemodulate(carrier,noise(1+offset:end ,:));
    noiseEst = var(noiseGrid(:));
    % Get precoding matrix for next slot
    newPrecodingWeight = getPrecodingMatrix(pdsch.PRBSet,pdsch.NumLayers,estChGridAnts);
    % Apply precoding to estChGridAnts. The resulting estimate is for
    % the channel estimate between layers and receive antennas.
    estChGridLayers = precodeChannelEstimate(estChGridAnts,precodingWeights.');
else
    % Perform practical channel estimation between layers and receive
    % antennas.
    [estChGridLayers,noiseEst] = nrChannelEstimate(carrier,rxGrid,dmrsIndices,dmrsSymbols,'CDMLengths',pdsch.DMRS.CDMLengths);
    % Remove precoding from estChannelGrid before precoding
    % matrix calculation
    estChGridAnts = precodeChannelEstimate(estChGridLayers,conj(precodingWeights));
    % Get precoding matrix for next slot
    newPrecodingWeight = getPrecodingMatrix(pdsch.PRBSet,pdsch.NumLayers,estChGridAnts);
end
% Plot the channel estimate between the first layer and the first receive antenna.
mesh(abs(estChGridLayers(:,:,1,1)));
title('Channel Estimate');
xlabel('OFDM Symbol');
ylabel("Subcarrier");
zlabel("Magnitude");

%% Equalization
% The equalizer uses the channel estimate to compensate for the distortion introduced by the channel.
[pdschIndices,pdschInfo] = nrPDSCHIndices(carrier,pdsch); % 6240x2 uint32
[pdschRx,pdschHest] = nrExtractResources(pdschIndices,rxGrid,estChGridLayers); % 6240x2 uint32
[pdschEq,csi] = nrEqualizeMMSE(pdschRx,pdschHest,noiseEst);
% Plot the constellation of the equalized symbols. The plot includes the constellation diagrams for all layers.
constPlot = constellationDiagram(pdsch);
constPlot(fliplr(pdschEq));

%% PDSCH Decoding
[dlschLLRs,rxSymbols] = nrPDSCHDecode(carrier,pdsch,pdschEq,noiseEst);
% Scale LLRs by CSI
csi = nrLayerDemap(csi);                                    % CSI layer demapping
for cwIdx = 1:pdsch.NumCodewords
    Qm = length(dlschLLRs{cwIdx})/length(rxSymbols{cwIdx}); % Bits per symbol
    csi{cwIdx} = repmat(csi{cwIdx}.',Qm,1);                 % Expand by each bit per symbol
    dlschLLRs{cwIdx} = dlschLLRs{cwIdx} .* csi{cwIdx}(:);   % Scale
end

%% DL-SCH Decoding
Xoh_PDSCH = 0;
trBlkSizes = nrTBS(pdsch.Modulation,pdsch.NumLayers,numel(pdsch.PRBSet),pdschInfo.NREPerPRB,dlsch.codeRate,Xoh_PDSCH);
decodeDLSCH = dlsch.decodeDLSCH;
decodeDLSCH.TransportBlockLength = trBlkSizes;

% Get the decoded bits(decbits) and block error(blkerr)
[decbits,blkerr] = decodeDLSCH(dlschLLRs,pdsch.Modulation,pdsch.NumLayers, ...
    harqEntity.RedundancyVersion,harqEntity.HARQProcessID);

%% HARQ Process Update
statusReport = updateAndAdvance(harqEntity,blkerr,trBlkSizes,pdschInfo.G);    
disp("Slot "+(carrier.NSlot)+". "+statusReport);

end

