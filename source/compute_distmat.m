function distmat = compute_distmat(file1, file2)
if nargin == 1
    file2 = file1;
end

[data1, fs] = audioread(file1);
data2 = audioread(file2);

window = fs*2;
overlap = 3/4*window;

data1 = mean(data1,2);
data2 = mean(data2,2);

spec1 = spectrogram(data1, window, overlap);
spec2 = spectrogram(data2, window, overlap);

vmfcc1 = FeatureSpectralMfccs(abs(spec1), fs);
% Normalize the features
for i = 1:size(vmfcc1,1)
    vmfcc1(i,:) = vmfcc1(i,:)/norm(vmfcc1(i,:),1);
end
vmfcc2 = FeatureSpectralMfccs(abs(spec2), fs);
% Normalize the features
for i = 1:size(vmfcc2,1)
    vmfcc2(i,:) = vmfcc2(i,:)/norm(vmfcc2(i,:),1);
end
vpc1 = pitchChroma(abs(spec1), fs);
vpc2 = pitchChroma(abs(spec2), fs);

mat1 = [vpc1;vmfcc1(1:12,:)];
mat2 = [vpc2;vmfcc2(1:12,:)];
% distmat = pdist2(vmfcc1', vmfcc2');
distmat = pdist2(mat1',mat2');
end