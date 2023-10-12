function [carrier,pdsch,dlsch,harq,channel,newPrecodingWeight] = downlinkTransmitterSetup(elementsParam)
%   Model the elements of a link-level simulation.
carrier = carrierSetup;
pdsch = pdschSetup(carrier);
[dlsch,harq] = dlschSetup(pdsch);
channel = commChannel(carrier,pdsch,elementsParam);
estChannelGrid = getInitialChannelEstimate(channel,carrier);
newPrecodingWeight = getPrecodingMatrix(pdsch.PRBSet,pdsch.NumLayers,estChannelGrid);
end

