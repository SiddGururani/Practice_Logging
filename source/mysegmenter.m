function id = mysegmenter(filename,d_1,d_2,d_3)
file1 = 'Berman_Prokofiev_Op29_Mvt1.mp3';
file2 = 'Berman_Prokofiev_Op29_Mvt2.mp3';
file3 = 'Berman_Prokofiev_Op29_Mvt3.mp3';

[test,sr] = audioread(filename);

% d_1 = audioread(file1);
% d_2 = audioread(file2);
% d_3 = audioread(file3);

test = mean(test,2);

% Remove last 4 seconds of silence
test = test(1:end-4*sr);
% d_1 = mean(d_1,2);
% d_2 = mean(d_2,2);
% d_3 = mean(d_3,2);

k = 10;
%% Onset detection - This seems to be where the accuracy of this algorithm
% is dependent upon.

nvt = HPCWeighing(test, 1024, 256);
onsets_test = myOnsetDetection(nvt, sr, 1024, 256);

nvt = HPCWeighing(d_1, 1024, 256);
onsets_1 = myOnsetDetection(nvt, sr, 1024, 256);

nvt = HPCWeighing(d_2, 1024, 256);
onsets_2 = myOnsetDetection(nvt, sr, 1024, 256);

nvt = HPCWeighing(d_3, 1024, 256);
onsets_3 = myOnsetDetection(nvt, sr, 1024, 256);

% Compute segments of 'k' onsets.
segment_test = onsets_test(1:k:end);
segment_1 = onsets_1(1:k:end);
segment_2 = onsets_2(1:k:end);
segment_3 = onsets_3(1:k:end);
c = 0;

%% Find best match for every 5th segment in test song with every segment in
%reference tracks.
if numel(segment_test) < 2
    movement_id = 0;
end
for i = 1:5:numel(segment_test)-1
    c = c+1;
    test_hist = compute_pitch_hist(test(floor(sr*segment_test(i)):floor(sr*segment_test(i+1))), sr, 1024, 256);
    for j = 1:numel(segment_1)-1
        seg_hist = compute_pitch_hist(d_1(floor(sr*segment_1(j)):floor(sr*segment_1(j+1))), sr, 1024, 256);
        dist_1(j) = pdist2(seg_hist', test_hist');
    end
    [min_dist_1,loc(1)] = min(dist_1);
    for j = 1:numel(segment_2)-1
        seg_hist = compute_pitch_hist(d_2(floor(sr*segment_2(j)):floor(sr*segment_2(j+1))), sr, 1024, 256);
        dist_2(j) = pdist2(seg_hist', test_hist');
    end
    [min_dist_2,loc(2)] = min(dist_2);
    for j = 1:numel(segment_3)-1
        seg_hist = compute_pitch_hist(d_3(floor(sr*segment_3(j)):floor(sr*segment_3(j+1))), sr, 1024, 256);
        dist_3(j) = pdist2(seg_hist', test_hist');
    end
    [min_dist_3,loc(3)] = min(dist_3);
    [~,id] = min([min_dist_1,min_dist_2,min_dist_3]);
    movement_id(c) = id;
    switch(id)
        case 1
            location(c) = segment_1(loc(id));
        case 2
            location(c) = segment_2(loc(id));
        case 3
            location(c) = segment_3(loc(id));
    end
end
id = mode(movement_id);
