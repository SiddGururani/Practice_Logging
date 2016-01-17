[id, filename] = textread('../../25files.csv','%d,%s');
tic
file1 = 'Berman_Prokofiev_Op29_Mvt1.mp3';
file2 = 'Berman_Prokofiev_Op29_Mvt2.mp3';
file3 = 'Berman_Prokofiev_Op29_Mvt3.mp3';
d_1 = audioread(file1);
d_2 = audioread(file2);
d_3 = audioread(file3);
d_1 = mean(d_1,2);
d_2 = mean(d_2,2);
d_3 = mean(d_3,2);

tp = 0; tn = 0; fp = 0; fn = 0;
for i = 1:numel(id)
    c_id = mysegmenter(['../../Test100/', char(filename(i)), '.mp3'], d_1,d_2,d_3);
    fprintf('file: %s actual: %d detected: %d\n',char(filename(i)),id(i),c_id);
    if id(i) == 1 || id(i) == 2 || id(i) == 3
        if id(i) == c_id
            tp = tp+1;
        else
            fp = fp+1;
            fn = fn+1;
        end
    else
        continue;
    end
end
detect_Precision = tp/(tp+fp)
toc 
