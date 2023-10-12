function [channel] = commChannel(carrier,pdsch,elementsParam)
%COMMUCHANNEL 此处显示有关此函数的摘要
%   此处显示详细说明
nTxAnts = elementsParam.bsParam.bsAntTxNum;
nRxAnts = elementsParam.ueParam.ueAntCommRxNum;

% Check that the number of layers is valid for the number of antennas
if pdsch.NumLayers > min(nTxAnts,nRxAnts)
    error("The number of layers ("+string(pdsch.NumLayers)+") must be smaller than min(nTxAnts,nRxAnts) ("+string(min(nTxAnts,nRxAnts))+")")
end
channel = nrTDLChannel;
channel.DelayProfile = "TDL-C";
channel.NumTransmitAntennas = nTxAnts;
channel.NumReceiveAntennas = nRxAnts;

ofdmInfo = nrOFDMInfo(carrier);
channel.SampleRate = ofdmInfo.SampleRate;
end

