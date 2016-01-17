function [ pitch_hist ] = compute_pitch_hist( x, fs, window, hop )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    x =mean(x,2);
    X = spectrogram(x,window, window-hop);
    vpc = pitchChroma(abs(X),fs);
    pitch_hist = mean(vpc,2);
end

