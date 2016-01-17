[id, filename] = textread('../../allfiles.csv','%d,%s');
tic
tp = 0; tn = 0; fp = 0; fn = 0;
for i = 1:numel(id)
    % Use parameters discovered from Grid_search_eval
    c_id(i) = mvt_detect_new(char(filename(i)), 0.25, 4);
    fprintf('file: %s actual: %d detected: %d\n',char(filename(i)),id(i),c_id(i));
    if id(i) == 1 || id(i) == 2 || id(i) == 3
        if id(i) == c_id(i)
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