function hashMat = saveGlobalHash(dir);

global HashTable HashTableCounts

dirname = ['../PracticeDatabase/' dir '/'];
% find all the MP3 files
dlist = dir(fullfile(dirname, '*.mp3'));
% put their full paths into a cell array
tks = []; 
for i = 1:length(dlist); ...
tks{i} = fullfile(dirname, dlist(i).name); ...
end
% Initialize the hash table database array 
clear_hashtable
% Calculate the landmark hashes for each reference track and store
% it in the array (takes a few seconds per track).
add_tracks(tks);

save(['Hashes/' dir '/HashTable.mat'],'HashTable')
save(['Hashes/' dir '/HastTableCounts.mat'],'HashTableCounts')

x = 1