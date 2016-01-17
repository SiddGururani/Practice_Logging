% This function is originally from Ashis Pati and used for our purposes, 12/05/2015 
% Reason: Algorithmic prototyping. Will be implemented if algorithm works better.
%% Windowing Function
% [frames, timeInSec] = Windows(x, wSize, hop, fs)
% objective: Return overlapping windows given a array, window size and hop size  
%
% INPUTS
% x: N x 1 float array, audio signal 
% wSize: window size
% hop: hop size
% fs = sampling frequency
%
% OUTPUTS
% frames: wSize x n matrix of frames, n being the number of windows

function [frames] = Windows(audio, wSize, hop)

% initializations

% zeropadding in the beginning
zeropadaudio = [zeros(wSize/2,1);audio;zeros(wSize/2,1)];
N = length(zeropadaudio); %length of audio file

% creating frames based on wSize and hop
idx = 1; % sample index 
i = 1;
numWindows = ceil((N-wSize)/hop);
frames = zeros(wSize,numWindows);

for i = 1:numWindows
    frames(1:min(idx+wSize,N)-idx,i) = zeropadaudio(idx:min(idx+wSize,N)-1);
    idx = idx + hop;
end

end