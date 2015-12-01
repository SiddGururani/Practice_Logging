%% Enhance repetition lines using erode + dialte
% Input: 
%   SDM: float N by N binary self-distance matrix (or lag-distance matrix)
%   L: int: the minimum length of the lines to detect
% Output:
%   SDM_ed: float N by N enhanced self-distance matrix 

function [SDM_ed] = erodeDilate(SDM, L)

% SDM = SDM - 1; 
% SDM(SDM == -1) = 1; %inverse the SDM matrix (becomes self-similarity matrix)
se = strel('line', L, 0); %length = L, degree = 0
tmp = imerode(SDM, se);
SDM_ed = imdilate(tmp,se);

% imagesc(SDM_ed)
% ylabel('Lag (s)')
% xlabel('Time (s)')
% title('Eroded and Dilated Matrix')
% axis xy