function [similarityMatrix,indicesMatrix,parameter] = features_to_SM(f1,f2,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: features_to_SM.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   This functions calculates a Similarity Matrix (SM) from the two input 
%   feature sequences. 
%   
%   Key steps:
%   1. Calculates the forward smoothing similarity matrix and backward 
%   smoothing similarity matrix of two input feature sequences using. 
%   Here, the enhancement of transposition-invariance and tempo-invariance 
%   can be included.
%   2. Derive the final similarity matrix based on forward and/or backward
%   smoothing similarity matrix.
%
%
% Input:
%       f1: first feature sequence
%       f2: second feature sequence
%       parameter (optional): parameter struct with fields
%          .smoothLenSM : length of smoothing count in frames
%          .tempoRelMin : minimum differed tempo relative to original tempo
%          .tempoRelMax : maximum differed tempo relative to original tempo 
%          .tempoNum : number of tempi for [tempoRelMin, tempoRelMax]
%          .circShift : range of circle shift
%          .forwardBackward : whether to use both forward and backward
%                             smoothing or not
%
% Output:
%       similarityMatrix : computed similarity matrix
%       indicesMatrix : corresponding transposition index matrix of  
%                       the similarityMatrix                                   
%       parameter: if any field in the inpur parameter is not setted, 
%                  this output parameter allows users to see which settings 
%                   are used.
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







%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%QUESTION. SHOULD I KEEP THE SETTINGS OF TEMPO AND SMOOTHING HERE?
if nargin<3
    parameter=[];
end

if isfield(parameter,'smoothLenSM')==0
    parameter.smoothLenSM = 1;
end

if isfield(parameter,'tempoNum')==0
    parameter.tempoNum = 1;
end

if isfield(parameter,'tempoRelMin')==0
    parameter.tempoRelMin = 1;
end

if isfield(parameter,'tempoRelMax')==0
    parameter.tempoRelMax = 1;
end

if isfield(parameter,'circShift')==0
    parameter.circShift = 0;
end

if isfield(parameter,'forwardBackward')==0
    parameter.forwardBackward = 0 ;
end





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   1. Calculates the forward smoothing similarity matrix and backward smoothing similarity 
%   matrix of two input feature sequences using. Here, the enhancement of
%   transposition-invariance and tempo-invariance can be included.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





if(parameter.circShift==0)
    %circshift turned off
    [S_Forward,S_Backward] = compute_forwardBackwardMatrix_tempoChange(f1,f2,parameter);
    
else
    %circshift turned on
    
    numCircShift = length(parameter.circShift);
    circShiftArray = parameter.circShift;
    
    for k = 1:numCircShift
        
        circValue = circShiftArray(k);
        
        
        feature_hori = f1;
        feature_verti = circshift(f2,[circValue,0]);
        
        
        [SF_new,SB_new] = compute_forwardBackwardMatrix_tempoChange(feature_hori,feature_verti,parameter);
        
        
        if(k==1)
            % initialize the similarity matrix with first round computed values
            S_Forward = SF_new;
            S_Backward = SB_new;
            
            S_Forward_MaxIndices = ones(size(S_Forward)) * circValue;
            S_Backward_MaxIndices = ones(size(S_Forward)) * circValue;
            
        else            
            % compare the newly computed matrix with previous ones, and
            % take the element-wise larger similarity
            [S_Forward, isFromCurrentSF] = matrixMax(S_Forward,SF_new);
            S_Forward_MaxIndices (isFromCurrentSF) = circValue;            
            
            [S_Backward, isFromCurrentSB] = matrixMax(S_Backward,SB_new);
            S_Backward_MaxIndices (isFromCurrentSB) =  circValue;
        end
        
                
    end
end








%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   2. Derive the final similarity matrix based on forward and/or backward
%   smoothing similarity matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





if(parameter.circShift==0)
    % circshift turned off  
    
    if(parameter.forwardBackward==0)
        % use only forward
        similarityMatrix = S_Forward;
    else
        % use both forward and backward
        [similarityMatrix, isFromSB] =  matrixMax(S_Forward,S_Backward);
    end
    
    indicesMatrix = zeros(size(similarityMatrix));
    
else    
    %circshift turned on    
    
    if(parameter.forwardBackward==0)
        % use only forward
        similarityMatrix = S_Forward;
        indicesMatrix = S_Forward_MaxIndices;
    else
        % use both forward and backward
        [similarityMatrix, isFromSB] =  matrixMax(S_Forward,S_Backward);
        indicesMatrix = S_Forward_MaxIndices;
        indicesMatrix(isFromSB) = S_Backward_MaxIndices(isFromSB);
    end
    
end







end




