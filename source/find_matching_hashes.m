% A function that finds matching hashes for a given audio track

function R = find_matching_hashes(dirname, filename)

clear_hashtable
% Calculate the landmark hashes for each reference track and store
% it in the array (takes a few seconds per track).
%add_tracks(tks);
load([dirname '/HashTable.mat'])
load([dirname '/HastTableCounts.mat'])
% Load a query waveform (recorded from playback on a laptop)
[dt,srt] = audioread([dirname '/' filename]);
% Run the query
R = match_query(dt,srt);