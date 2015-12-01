%% compute binary SDM matrix
% input:
%   SDM: numSamples by numSamples float matrix, self-distance matrix
%   threshold: float, constant value for thresholding the SDM
% output:
%   SDM_binary: numSamples by numSamples int matrix, binary SDM

function [SDM_binary] = computeBinSdm(SDM, threshold)

SDM(SDM>threshold) = 1;
SDM(SDM<=threshold) = 0;

SDM_binary = SDM;

% imagesc(SDM_binary)
% ylabel('Lag (s)')
% xlabel('Time (s)')
% title(['Binary Lag Distance Matrix: Threshold =  ' num2str(threshold)])
% axis xy
