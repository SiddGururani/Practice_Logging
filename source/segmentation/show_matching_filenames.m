% A function that displays matching filenames

function output = show_matching_filenames(queryfilename, dirname,R)


mp3_files = dir(fullfile(dirname, '*.mp3'));

output = cell(size(R,1)-1,1);
% Display the filenames that match. Skip the first (we know it is 100%
% match)
for i=2:(size(R,1))
    filename = mp3_files(R(i,1)).name;
    timeskew = 0.032*R(i,3);
    output{i-1} = [queryfilename ' matched ' filename ' with ' num2str(R(i,2)) ' matching hashes starting at ~' num2str(timeskew) ' seconds.'];
end