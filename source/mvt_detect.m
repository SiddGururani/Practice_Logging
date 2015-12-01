function c_id = mvt_detect(filename)

%% Compute distance matrices of the song compared with the three template songs.
distmat1 = compute_distmat(filename,'recording/Berman_Prokofiev_Op29_Mvt1.mp3');
distmat2 = compute_distmat(filename,'recording/Berman_Prokofiev_Op29_Mvt2.mp3');
distmat3 = compute_distmat(filename,'recording/Berman_Prokofiev_Op29_Mvt3.mp3');
% normalization = max(max(distmat1(:)),max(distmat1(:)),max(distmat1(:)));
% distmat1 = distmat1/normalization;
% distmat2 = distmat2/normalization;
% distmat3 = distmat3/normalization;

%% Compute Lag Matrix from distance matrix
lag1 = computeLagDistMatrix(distmat1');
lag2 = computeLagDistMatrix(distmat2');
lag3 = computeLagDistMatrix(distmat3');

%% Binarize Distance Matrix with threshold
bin1 = computeBinSdm(lag1,0.20);
bin2 = computeBinSdm(lag2,0.20);
bin3 = computeBinSdm(lag3,0.20);

%% Erode and Dilate
er1 = erodeDilate(bin1,20);
er2 = erodeDilate(bin2,20);
er3 = erodeDilate(bin3,20);

%% Find the boundaries of the lines in eroded and dilated binary matrix.
b1 = bwboundaries(er1);
b2 = bwboundaries(er2);
b3 = bwboundaries(er3);
% Remove the first boundary for the upper triangle empty matrix.
b1 = b1(2:end); b2 = b2(2:end); b3 = b3(2:end);

%% Compute average length of lines detected in erode dilate
m1 = 0;
for i = 1:numel(b1)
    m1 = m1+size(cell2mat(b1(i)),1);
end
m1 = m1/numel(b1);

m2 = 0;
for i = 1:numel(b2)
    m2 = m2+size(cell2mat(b2(i)),1);
end
m2 = m2/numel(b2);

m3 = 0;
for i = 1:numel(b3)
    m3 = m3+size(cell2mat(b3(i)),1);
end
m3 = m3/numel(b3);

%% Find maximum average length and output it as belonging to that song.
[~, c_id] = max([m1, m2, m3]);

end