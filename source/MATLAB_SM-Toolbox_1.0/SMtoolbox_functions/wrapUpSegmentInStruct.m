function [segStructArray] = wrapUpSegmentInStruct(induced_second,thumb_second)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: wrapUpSegmentInStruct.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   This function find in induced segment family, which segment corresponds to
%   the thumbnail.
%
%   Note that start and end of the induced segment, which corresponding to the 
%   thumbnail, might have one frame shift compared to the thumbnail.
%
%
% Input:
%       induced_second : induced segment family in seconds
%       thumb_second : thumbnail segment in seconds
%
%
% Output:
%       segStructArray: a struct array containing all induced segments with fields:
%                   .start : (in seconds)
%                   .end : (in seconds)
%                   .label : (string)
%                 
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reference:
%   If you use the 'SM toobox' please refer to:
%   [MJG13] Meinard Müller, Nanzhu Jiang, Harald Grohganz
%   SM Toolbox: MATLAB Implementations for Computing and Enhancing Similarity Matrices
%   Proceedings of the 53rd Audio Engineering Society Conference on Semantic Audio, London, 2014.
%
% License:
%     This file is part of 'SM Toolbox'.
%
%     'SM Toolbox' is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 2 of the License, or
%     (at your option) any later version.
%
%     'SM Toolbox' is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with 'SM Toolbox'. If not, see
%     <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





[value,idx] = min(abs(induced_second(:,1) - thumb_second(1)));

numInduced = size(induced_second,1);

segStructArray = [];

for k = 1:numInduced
    
    if(k==idx)
        %curLabel = 'thumb'; 
        curLabel = 'A'; %thumbnail
    else
        %curLabel = 'repeat'; 
        curLabel = 'A'; %repeated segment
    end
    
    %arrange segments by their time positions ascend.
    j = numInduced - k + 1;
    segStructArray(j).start = induced_second(k,1);
    segStructArray(j).end = induced_second(k,2);
    segStructArray(j).label = curLabel;
    
end


end
