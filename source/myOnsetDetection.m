% This function is originally from Ashis Pati and modified for our purposes, 12/05/2015 
% Reason: Algorithmic prototyping. Will be implemented if algorithm works better.
%% onset detection with adaptive thresholding
% [onsetTimeInSec] = myOnsetDetection(nvt, fs, windowSize, hopSize)
% input: 
%   x: N by 1 float vector, input signal
%   fs: float, sampling frequency in Hz
%   windowSize: int, number of samples per block
%   hopSize: int, number of samples per hop
% output: 
%   onsetTimeInSec: n by 1 float vector, onset time in second

function [onsetTimeInSec] = myOnsetDetection(nvt, fs, windowSize, hopSize)

order = 50;
lambda = 0.2;
thres = myMedianThres(nvt, order, lambda);
%figure; plot(nvt,'r'); hold on; plot(thres,'g'); hold off;
delta = nvt - thres;
hwrNvt = delta.*(delta>0); %half-wave rectification
hwrNvt = smooth(hwrNvt); %smoothing
[~,locs] = findpeaks(hwrNvt);
onsetTimeInSec = (hopSize/fs)*locs;


end



