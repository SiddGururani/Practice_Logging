% Script to pick best parameters given a dataset. Larger dataset gives
% better parameters for overall decent performance.

[id, filename] = textread('../../50files.csv','%d,%s');
c1 = 0; c2 = 0;
for t = 0.13:0.005:0.3
	c1 = c1+1;
	c2 = 0;
	for l = 2:2:20
		c2 = c2+1;
		tp = 0; tn = 0; fp = 0; fn = 0;
		for i = 1:numel(id)
			c_id = mvt_detect_new(filename(i), t, l);
% 			fprintf('file: %s actual: %d detected: %d\n',char(filename(i)),id(i),c_id);
			if id(i) == c_id
				tp = tp+1;
			else
				fp = fp+1;
				fn = fn+1;
			end
		end
		p = tp/(tp+fp);
		detect_Precision(c1,c2) = p;
	end
end     