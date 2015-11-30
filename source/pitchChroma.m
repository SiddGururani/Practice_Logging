function [vpc] = pitchChroma(X,fs,fftlen)

%C4 starting pitch - 60
%fftlen = 4096;
X1 = abs(X);
nbins = 1:size(X,1);
freq = nbins*fs/fftlen;

%compute the midi note number of each bin
midifreq = round(69 + 12*log2(freq/440));

pitch_chroma = zeros(12,size(X,2));
for i = 60:108
    locations = find(midifreq == i);
    power = X1(locations,:);
    total = sum(power,1);
    pitch_chroma(mod((i-60),12)+1,:) = pitch_chroma(mod((i-60),12)+1,:) + total;
end

vpc = pitch_chroma;
for i = 1:size(vpc,2)
    vpc(:,i) = vpc(:,i)/norm(vpc(:,i),1);
end
% imagesc(vpc);
end