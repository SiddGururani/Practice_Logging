% This function is originally from Ashis Pati as HPCWeighing.m and used for our purposes, 12/05/2015 
% Reason: Algorithmic prototyping. Will be implemented if algorithm works better.
%% High Frequency Content (HFC) Weighing Energy Function 
% nvt = HPCWeighing(frames)
% objective: Return HFC weighed energy for each window 
%
% INPUTS
% x: N x 1 vector containing the audio signal
% wSize: window Size in samples
% hop: hop Size in samples
%
% OUTPUTS
% nvt: n x 1 matrix HPC weighted energy, n being the number of windows

function nvt = HFCWeighing(x, wSize, hop)

% initializations
[frames] = Windows(x, wSize, hop);
[wSize, n] = size(frames);

% HFC weighing of fft
spectra = abs(fft(frames));
spectra = spectra(1:wSize/2,:);
spectra = spectra.*spectra;
weighingVector = (ones(n,1)*(0:wSize/2-1))';
specEnergy= sum(spectra.*weighingVector);
specEnergy_shifted = circshift(specEnergy,1,2);
deltaEnergy = zeros(1,n);
deltaEnergy(1) = specEnergy(1);
deltaEnergy(2:end) = specEnergy(2:end) - specEnergy_shifted(2:end);
%deltaEnergy(isinf(deltaEnergy)) = 0;
nvt = (deltaEnergy/max(deltaEnergy))';
end