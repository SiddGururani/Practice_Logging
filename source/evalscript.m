[id, filename] = textread('../../37files.csv','%d,%s');

tp = 0; tn = 0; fp = 0; fn = 0;
for i = 1:numel(id)
    c_id = mvt_detect_new(char(filename(i)), 0.23, 6);
    fprintf('file: %s actual: %d detected: %d\n',char(filename(i)),id(i),c_id);
    if id(i) == c_id
        tp = tp+1;
    else
        fp = fp+1;
        fn = fn+1;
    end
end
detect_Precision = tp/(tp+fp)
