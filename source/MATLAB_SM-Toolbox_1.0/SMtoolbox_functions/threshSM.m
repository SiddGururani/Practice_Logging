function [scoreMatrix,parameter] = threshSM(SM,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: threshSM.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
% This function implements four different thresholding techniques to a
% similarity matrix.
% 1 - absolute (value)
% 2 - relative (number of cells)
% 3 - relative (amount of total value)
% 4 - relative (number of cells in each row/column)
%
%
% Input:
%       SM : a similarity matrix
%       parameter (optional): parameter struct with fields
%           .threshTechnique : which techqnique to use
%           .threshValue : threshold value, note that depends on 
%                          threshTechnique, this value could be either 
%                          relative threshold or absolute threshold.
%           .applyScale : whether to apply scaling or not    
%           .penalty : give very small value an extra penalty
%           .applyBinarize: whether to apply binarization or not
%
% Output:
%       scoreMatrix : the thresholded SM.
%       parameter (optional) :  if any field in the inpur parameter is not
%                               setted, this output parameter allows users 
%                               to see which settings are used.
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

if nargin<2
    parameter = [];
end

if ~isfield(parameter,'threshTechnique')
    parameter.threshTechnique = 2;
end

if ~isfield(parameter,'threshValue')
    parameter.threshValue = 0.2;
end

if ~isfield(parameter,'applyScale')
    parameter.applyScale = 0;
end

if ~isfield(parameter,'penalty')
    parameter.penalty = 0;
end

if ~isfield(parameter,'applyBinarize')
    parameter.applyBinarize = 0;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thresholding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scoreMatrix = SM;
clear threshAbs;
switch parameter.threshTechnique
    
    case 1 % absolute
        threshAbs = parameter.threshValue;
        scoreMatrix(scoreMatrix < threshAbs) = 0;        
        
    case 2 % fixed number of cells
        numCutCell = numel(SM)*(1-parameter.threshValue);
        valuesSort = sort(scoreMatrix(:));
        threshAbs = valuesSort(round(numCutCell));
        scoreMatrix(scoreMatrix<threshAbs) = 0;        
        
    case 3 % fixed amount of energy
        s = sort(scoreMatrix(:));
        threshAbs = sum(s)*(1-parameter.threshValue);
        [threshRel] = find(cumsum(s)>threshAbs,1,'first');
        scoreMatrix(scoreMatrix<s(threshRel)) = 0;
        
        
    case 4 % row/column relative threshold
        s = sort(SM,1);
        threshAbs = s(round(size(scoreMatrix,1)*(1-parameter.threshValue)+1),:,:);
        scoreMatrix(bsxfun(@lt,SM,threshAbs)) = 0;

        
        s = sort(SM,2);
        threshAbs = s(:,round(size(scoreMatrix,2)*(1-parameter.threshValue)+1),:);
        scoreMatrix(bsxfun(@lt,SM,threshAbs)) = 0;
        
        

end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scaling : extra rearrange values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if parameter.applyScale
    % scale all positive values to range [0,1]
    
    [values] = sort(scoreMatrix(:));
    pos = find(values > 0,1,'first');
    minValue = values(pos);
    
    maxValue = max(max(scoreMatrix));
    
    if(isequal(maxValue,Inf))
        warning('matrix contains Infinity values, scaling result might not be reliable');
    end
    
    scoreMatrix = (scoreMatrix - minValue) /(maxValue - minValue);
    
    
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Penalty/Binariziation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scoreMatrix(scoreMatrix<eps) = parameter.penalty;

if parameter.applyBinarize
    scoreMatrix(scoreMatrix>eps) = 1;
    scoreMatrix(scoreMatrix<=eps) = 0;
end





end

