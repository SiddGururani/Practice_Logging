function distmat = compute_distmat(file1, file2)
if nargin == 1
    file2 = file1;

[data1, fs] = audioread(file1);
data2 = audioread(file2);

window = 2^15;
overlap = 3/4*window;

data1 = mean(data1,2);
data2 = mean(data2,2);

spec1 = spectrogram(data1, window, overlap);
spec2 = spectrogram(data2, window, overlap);

vpc1 = pitchChroma(spec1, fs, window);
vpc2 = pitchChroma(spec2, fs, window);

distmat = pdist2(vpc1', vpc2');

end