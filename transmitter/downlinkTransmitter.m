function [txWaveform,waveformInfo,txPdschGrid,trBlk,harqEntity] = downlinkTransmitter(elementsParam,carrier,pdsch,dlsch,harqEntity,newPrecodingWeight)
%DOWNLINK TRANSMITTER

nTxAnts = elementsParam.bsParam.bsAntTxNum;

%% Transmit in a slot
% Generate PDSCH indices info, which is needed to calculate the transport block size
[pdschIndices,pdschInfo] = nrPDSCHIndices(carrier,pdsch);

% Calculate transport block sizes
Xoh_PDSCH = 0;
trBlkSizes = nrTBS(pdsch.Modulation,pdsch.NumLayers,numel(pdsch.PRBSet),pdschInfo.NREPerPRB,dlsch.codeRate,Xoh_PDSCH);

% Get new transport blocks and flush decoder soft buffer, as required
for cwIdx = 1:pdsch.NumCodewords
    if harqEntity.NewData(cwIdx)
        % Create and store a new transport block for transmission
        trBlk = randi([0 1],trBlkSizes(cwIdx),1);
        trBlk = int8(trBlk);
        setTransportBlock(dlsch.encodeDLSCH,trBlk,cwIdx-1,harqEntity.HARQProcessID);

        % If the previous RV sequence ends without successful
        % decoding, flush the soft buffer
        if harqEntity.SequenceTimeout(cwIdx)
            resetSoftBuffer(dlsch.decodeDLSCH,cwIdx-1,harqEntity.HARQProcessID);
        end
    end
end

% DL-SCH Encoding
codedTrBlock = dlsch.encodeDLSCH(pdsch.Modulation,pdsch.NumLayers,pdschInfo.G,harqEntity.RedundancyVersion,harqEntity.HARQProcessID);

% PDSCH Modulation and MIMO Precoding
pdschSymbols = nrPDSCH(carrier,pdsch,codedTrBlock);
precodingWeights = newPrecodingWeight;
pdschSymbolsPrecoded = pdschSymbols*precodingWeights;

% PDSCH DM-RS Generation
dmrsSymbols = nrPDSCHDMRS(carrier,pdsch);
dmrsIndices = nrPDSCHDMRSIndices(carrier,pdsch);

% Mapping to Resource Grid
pdschGrid = nrResourceGrid(carrier,nTxAnts);
[~,pdschAntIndices] = nrExtractResources(pdschIndices,pdschGrid);
pdschGrid(pdschAntIndices) = pdschSymbolsPrecoded;

% PDSCH DM-RS precoding and mapping
for p = 1:size(dmrsSymbols,2)
    [~,dmrsAntIndices] = nrExtractResources(dmrsIndices(:,p),pdschGrid);
    pdschGrid(dmrsAntIndices) = pdschGrid(dmrsAntIndices) + dmrsSymbols(:,p)*precodingWeights(p,:);
end
txPdschGrid = pdschGrid;

% OFDM modulation
[txWaveform,waveformInfo] = nrOFDMModulate(carrier,pdschGrid);

end

