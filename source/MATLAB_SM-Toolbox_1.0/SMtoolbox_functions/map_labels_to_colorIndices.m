function [labelsColorIdx] = map_labels_to_colorIndices(labels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: map_labels_to_colorIndices.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   This function reads in a list of labels, map them to a list of intergers,
%   which used as color index for colormap in other visualization functions.
%
%
% Input:
%       labels: a list of labels

%
%
% Output:
%       labelsColorIdx : a list of integers used for color map index

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

uniqueLabels = unique(labels);
labelAmount = zeros(length(uniqueLabels),1);


for i = 1:length(labels)
    for j = 1:length(uniqueLabels)
        if(strcmp(labels{i},uniqueLabels(j)))
            labelAmount(j) = labelAmount(j)+1;
            break;
        end
    end
end

[labelAmountSort, SortIndex] = sort(labelAmount,'descend');


LabelsUniqueSort = uniqueLabels(SortIndex);
LabelUniqueColorNum = 1:1:length(LabelsUniqueSort);
labelsColorIdx = zeros(length(labels),1);

for i = 1:length(labels)
    for j = 1:length(LabelsUniqueSort)
        if(strcmp(labels(i),LabelsUniqueSort(j)))
            labelsColorIdx(i) = LabelUniqueColorNum(j);
            break;
        end
    end
end

end