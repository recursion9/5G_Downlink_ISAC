clear;clc;
%% Setup Parameters
% Simulation Parameters
simParam.simNSlots = 20;
simParam.SNRdB = 10;
simParam.offset = 0;
simParam.perfectEstimation = false;

% Network elemeant parameters
elementsParam.bsParam = bsParameters;
elementsParam.ueParam = ueParameters;

% Set default random number generator for repeatability
rng("default");  

%% Downlink Transmitter Setup
[carrier,pdsch,dlsch,harqEntity,channel,newPrecodingWeight]=downlinkTransmitterSetup(elementsParam);

%% Slots loop
for nSlot = 0:simParam.simNSlots-1
    % New slot
    carrier.NSlot = nSlot;

    % Downlink Transmitter
    [txWaveform,waveformInfo,txPdschGrid,trBlk,harqEntity] = downlinkTransmitter(elementsParam,carrier,pdsch,dlsch,harqEntity,newPrecodingWeight);

    % Communication Receiver
    [decbits,blkerr,harqEntity,newPrecodingWeight] = downlinkReceiver(txWaveform,waveformInfo,carrier,pdsch,dlsch,elementsParam,simParam,harqEntity,channel,newPrecodingWeight);

    % Todo: 1:Generate network topology, 2:Model antennas using the Phased
    % Array Toolbox, 3:Generate sensing channel, 4:Receive radar echo signal,
    % 5:2D-DFT algorithm, 6:Music algorithm, 7:Constant False Alarm Rate
    % Detector, 8:more algorithms
    
end

