% for i = 1:numel(id)
% a = audioread(['../../Test100/', char(filename(i)), '.mp3']);
% lengths(i) = size(a,1);
% end
figure; hold on;
binned = histc(lengths,[1:44100*30:max(lengths)]);
bar([1:44100*30:max(lengths)]./44100+15,binned, 1, 'FaceColor',[0.2 0.2 0.5]);
xlabel('Length of Practice Recording (s)');
ylabel('Number of Files');
title(['Distribution of Recordings by Length of File']);
axis([0 1000 0 25]);
box on;

a = [lengths',id, c_id'];

[Y,I]=sort(a(:,1));
B=a(I,:); 
for i = 1:numel(id)
    if B(i,2) == B(i,3)
        y(i) = 1;
    else
        y(i) = -1;
    end
end

pos = find(y==1);
pos_len = B(pos,1);
binned = histc(pos_len,[1:44100*30:max(pos_len)]);
bar([1:44100*30:max(lengths)]./44100+15,binned,0.5,'FaceColor',[0 0.7 0.7]);
% xlabel('Length of Practice Recording');
% ylabel('Number of Files');
% title(['Distribution of Recordings Correctly Detected by Length of File']);
% axis([0 1000 0 25]);