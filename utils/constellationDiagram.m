function [constPlot] = constellationDiagram(pdsch)
% 此处显示有关此函数的摘要
%   此处显示详细说明
constPlot = comm.ConstellationDiagram;                                          % Constellation diagram object
constPlot.ReferenceConstellation = getConstellationRefPoints(pdsch.Modulation); % Reference constellation values
constPlot.EnableMeasurements = 1;   
constPlot.ChannelNames = "Layer "+(pdsch.NumLayers:-1:1);
constPlot.ShowLegend = true;
end

