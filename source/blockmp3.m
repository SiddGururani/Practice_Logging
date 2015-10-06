% A function to block a single mp3 file and put all of those blocked
% versions into a new directory. 
function blockmp3(filename,blocksize_in_sec,hopsize_in_sec);

% Get rid of whatever extension there was
[filename_separated, delimiter] = strsplit(filename,'.');
filename_without_extension = filename_separated{1}; 
extension = filename_separated{2};

% Make a directory for all of the blocked versions of that file
dir = [filename_without_extension '_blocked'];
mkdir(dir);

[stereo_data,srt] = audioread(filename);

mono_data = downmix(stereo_data);
numSamples = length(mono_data);

blockSize = ceil(blocksize_in_sec * srt);
hopSize = ceil(hopsize_in_sec * srt);

for i = 1:hopSize:numSamples
    if i+blockSize < numSamples
        data = mono_data(i:i+blockSize);
    else
        data = mono_data(i:end);
    end
    
    % Write it to a new directory
    newFileName = [filename_without_extension '_' num2str(i) '.mp3'];
    mp3write(data,srt,16,[dir '/' newFileName],'--quiet -h -b 96');
end
    
    