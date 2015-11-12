function [thumbnail_frame] = scapePlotFitness_to_thumbnail(fitness_matrix,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: scapePlotFitness_to_thumbnail.m
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
%       fitness_matrix: first feature sequence
%       parameter (optional): parameter struct with fields
%                .len_min_seg_frame : minimum length of segment in frames
%                .len_max_seg_frame : maximum length of segment in frames
%
% Output:
%       thumbnail_frame : computed thumbnail specified by its begin and end
%                         in frames.
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




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    parameter=[];
end

if isfield(parameter,'len_min_seg_frame')==0
    parameter.len_min_seg_frame = 1;
end

if isfield(parameter,'len_max_seg_frame')==0
    parameter.len_max_seg_frame = size(fitness_matrix,1);
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the maximum fitness point, whose corresponding segment having its
% segment length fulfilled the length constrint specified
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% restricting the searching area of fitness by length hints of thumbnail
max_search_area = fitness_matrix(:,:);
length_min_seg = max(parameter.len_min_seg_frame,1);
length_max_seg = min(parameter.len_max_seg_frame,size(fitness_matrix,1));


if(length_min_seg > length_max_seg)
    error('specified minimum length can not be larger than specified maximum length\n');
else
    max_search_area = fitness_matrix(length_min_seg:length_max_seg,:);
    length_not_searched = length_min_seg - 1;
end


if(size(max_search_area,1)~=1)
    % searching in area
    [column_max_values,column_max_indices] = max(max_search_area);
    [max_value,row_max_index] = max(column_max_values);
    x_pos = row_max_index;
    y_pos = column_max_indices(row_max_index);
    
else
    % searching on single line
    [max_value,x_pos] = max(max_search_area);
    y_pos = 1;
    
end



seg_start = x_pos;
seg_length = y_pos+ length_not_searched;
seg_end = seg_start + seg_length -1;

thumbnail_frame = [seg_start,seg_end];




end









