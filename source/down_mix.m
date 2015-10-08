% A function that converts a stereo track to a mono track.

function mono = downmix(stereo)

% For the sake of simplicity, at this point, we are assuming an Nx2 column
% vector as input
mono = stereo(:,1) + stereo(:,2);




% % Make sure we are dealing with the right type: column matrix
% if size(stereo,1) == 2
%     stereo = stereo';
% elseif size(stereo,2) == 2
%     break
% elseif size(stereo,1) || size(stereo,2)==1
%     mono = stereo
% end
% 
% if 