function [induced_seg_family_frame,pathFamily] = thumbnailSSM_to_pathFamily(thumbnail_frame, S,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: thumbnailSSM_to_pathFamily.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   This functions finds the maximum fitness point in the fitness matrix
%   and derive the corresponding segment. The search region of fitness
%   matrix can be limited by parameter.
%
%
% Input:
%       thumbnail_frame: thumbnail segment specified by its begin and end
%                     S: similarity matrix
%       parameter (optional): parameter struct with fields
%                .len_min_seg_frame : minimum length of segment in frames
%                .len_max_seg_frame : maximum length of segment in frames
%
% Output:
%       induced_seg_family_frame : induced segment family specified by begin and end
%                                  of each segment.
%                      pathFamily: pathFamily for the thumbnail
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





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3
    parameter=[];
end

if(length(thumbnail_frame)~=2)
    error('Segment should have start and end specified in frames.\n');
end

%--------------------pathFamily parameter------------------------%
if ~isfield(parameter,'dn')
    parameter.dn = int32([1 2 1]);
end

if ~isfield(parameter,'dm')
    parameter.dm = int32([1 1 2]);
end

if ~isfield(parameter,'dw')
    parameter.dw = ([1 1 1]);
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check boundary of frame index
seg_start_frame = thumbnail_frame(1);
seg_end_frame = thumbnail_frame (2);
duration_frame = size(S,1);

if(seg_start_frame < 1)
    warning('seg_start_frame cannot be less than 1, increase it to 1.');
end

if(seg_end_frame > duration_frame)
    warning('seg_end_frame cannot be larger than duration_frame, decrease it to duration_frame.');
end




thumbnail_frame = int32(thumbnail_frame);
% tic
[pathFamily,score] = computePathFamily_C(thumbnail_frame,S,parameter); %C version, fast
% [pathFamily,score] = computePathFamily(thumbnail_frame,S,parameter);% matlab version, the same idea as C version, but slow
% toc



induced_seg_family_frame = [];

for i = 1:size(pathFamily,1)
    % pathFamily content: first row: vertical seg,   second row: horizontal seg
    path_start = pathFamily{i}(1,1);
    path_end = pathFamily{i}(1,end);
    curPath = [path_start, path_end];
    
    induced_seg_family_frame(i,:)  = curPath;

end



end














