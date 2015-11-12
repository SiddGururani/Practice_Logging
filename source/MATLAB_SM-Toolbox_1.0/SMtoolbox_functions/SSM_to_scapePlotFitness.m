function [fitness_info,parameter] = SSM_to_scapePlotFitness(S,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: SSM_to_scapePlotFitness.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   Parallel computing fitness matrix from similarity matrix S.
%   Note that this function supports for parallel computation.
%
%
% Input:
%       S: similarity matrix
%       parameter (optional): parameter struct with fields
%           .dn : dynamic time warping horizonal step size
%           .dm : dynamic time warping vertical step size
%           .dw : dynamic time warping step size weight
%           .saveFitness : whether to save fitness or not
%
% Output:
%       fitness_info : a struct consists of fields
%           .fitness: fitness matrix for all segments
%           .resultsCoverage: coverage matrix for all segments
%           .scoreAverageNorm: score matrix for all segments
%
%       parameter: if any field in the inpur parameter is not setted,
%                  this output parameter allows users to see which settings
%                  are used.
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

if (nargin < 2)
    parameter = [];
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

%--------------------fitness parameter------------------------%
N = size(S,1);


if ~isfield(parameter,'fit_length_max')
    parameter.fit_length_max = ceil(1.1 * size(S,1) /2);
else if(parameter.fit_length_max > N)
        warning(['parameter.fit_length_max cannot exceed size of similarity matrix ' ...
            'Reset it to size of similarity matrix']);
        parameter.fit_length_max = N;
    end
end



if ~isfield(parameter,'fit_length_min')
    parameter.fit_length_min = 1;
else if(parameter.fit_length_min <1)
        warning('parameter.fit_length_min cannot be less than 1. Reset it to 1.');
        parameter.fit_length_min = 1;
    end
end

if(parameter.fit_length_max < parameter.fit_length_min)
    error('parameter.fit_length_max cannot be less than parameter.fit_length_min. Please reset them.');
end



if ~isfield(parameter,'saveFitness')
    parameter.saveFitness = 0;
end


if(parameter.saveFitness)
    if ~isfield(parameter,'dirFitness')
        parameter.dirFitness = './';
    end
    
    if ~isfield(parameter,'fitFileName')
        parameter.fitFileName = 'fit_test';
    end
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitness matrix computation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scoreAverageNorm = zeros(size(S));
coverage = zeros(size(S));



length_max = parameter.fit_length_max;
length_min = parameter.fit_length_min;


fprintf('computing fitness scape plot...\n');

%for fast computing, please use matlab parallel computing.
%to enable that, use command 'matlabpool open'.
parfor s = 1:size(S,1)
    myTemp1 = zeros(1,N);
    myTemp2 = zeros(1,N);
    for t = (s+length_min:min(N,s+length_max))-1;
        segment = int32([s;t]);
        
        %-----------!!IMPORTANT!!--------------------------------------------------%
        % If the C version of computePathFamily_C does not work on your computer,
        % please compile it before you enter this parfor loop
        % using C/C++ compiler by 'mex -v computePathFamily_C.cpp'.
        
        % As an alternative, matlab version of computePathFamily is
        % provided, but it is much slower than the C version
        %--------------------------------------------------------------------------%
        
        [pathFamily,score] = computePathFamily_C(segment,S,parameter); % C version, fast
        %[pathFamily,score] = computePathFamily(segment,S,parameter); % matlab version, slow
        
        segment = double(segment);
        pieceLength = size(S,1);
        numPath = size(pathFamily,1);
        segmentLength = (segment(2)-segment(1)+1);
        sumPathLength = sum(cellfun('size',pathFamily,2));
        scoreAveNorm = (score-segmentLength)./sumPathLength;
        support = [];
        for i = 1:numPath
            support = [support pathFamily{i}(1,1):pathFamily{i}(1,end)];
        end
        support = unique(support);
        cover = (length(support)-segmentLength)/pieceLength;
        
        myTemp1(segmentLength) = scoreAveNorm;
        myTemp2(segmentLength) = cover;
        
    end
    scoreAverageNorm(s,:) = myTemp1;
    coverage(s,:) = myTemp2;
end

coverage = coverage';
scoreAverageNorm = scoreAverageNorm';
fitness = 2* coverage.*scoreAverageNorm./(coverage + scoreAverageNorm + eps);


fitness_info = struct();
fitness_info.fitness = fitness;
fitness_info.resultsCoverage = coverage;
fitness_info.resultsScoreAverageNorm = scoreAverageNorm;

fprintf('fitness computation finished.\n');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Fitness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if parameter.saveFitness

    
    fitnessSaveFileName = [parameter.dirFitness,parameter.fitFileName,'.mat'];
    
    saveFitness(fitnessSaveFileName , fitness_info , S, parameter);
    
    
    
end






end

