function [S_forward_final,S_backward_final] = compute_forwardBackwardMatrix_tempoChange(f1,f2,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: features_to_resampledMatrix.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   This function caculates a forward smoothing similarity matrix and a  
%   backward smoothing similrity matrix with tempo enhancement. 
%
%   Here, the tempo-invariance is included by computing different similarity 
%   matrices with diffrent tempo changes. We assume the first feature sequence 
%   having different tempo compared to the second feature sequence. This is 
%   implemented by resampling the first feature sequence into different time 
%   positions. A similarity matrix is then computed by the resampled first 
%   feature sequence and the original second sequence. In the end, we take 
%   the element-wise maximum among all similarity matriices since simulate 
%   different time positions might have different tempo changes.
%
% Input:
%       f1: first feature sequence
%       f2: second feature sequence
%       parameter (optional): parameter struct with fields
%          .smoothLenSM : length of smoothing count in frames
%          .tempoRelMin : minimum differed tempo relative to original tempo
%          .tempoRelMax : maximum differed tempo relative to original tempo 
%          .tempoNum : number of tempi for [tempoRelMin, tempoRelMax]
%
%
% Output:
%       similarityMatrix : computed similarity matrix
%       indicesMatrix : corresponding transposition index matrix of 
%                       the similarityMatrix                                   
%       parameter: if any field in the inpur parameter is not setted, 
%                  this output parameter allows users to see which settings 
%                  are used.
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





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caculates a forward smoothing similarity matrix and a backward smoothing
% similrity matrix with tempo enhancement.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


N1 = size(f1,2);
N2 = size(f2,2);

L = parameter.smoothLenSM;
numTempi = parameter.tempoNum;
spaceTempi = logspace(log10(parameter.tempoRelMin),log10(parameter.tempoRelMax),numTempi);


S_forward_final = zeros(N2,N1);
S_backward_final = zeros (N2,N1);

for s=1:numTempi
    
    M1 = ceil(N1/spaceTempi(s));
    
    % resample the feature sequence to simulate supposed different tempo   
    
    index_resample = max(round(([1:M1]/M1)*N1),1); % map sample indices from N1 to M1
        
    X = f1(:,index_resample); % reasmpling X as having different tempo
    Y = f2;  % keep Y as original tempo
    
    %here, f1, f2 must be previously normalized.
   
    U = Y' * X; % original

    
    sizeR = N2 + L;
    sizeC = M1 + L;
    
    S_forward = zeros(N2,M1);
    S_backward = zeros(N2,M1);
    
    % create an extended matrix with padding
    S_extend_forward = zeros(sizeR,sizeC);   
    S_extend_forward((1:N2),(1:M1)) = U;  % zero padding at the end
    
    S_extend_backward = zeros(sizeR,sizeC);
    S_extend_backward (L+(1:N2),L+(1:M1)) = U; %zero padding at the beginning 
    

    % compute accumulated similarity values  
    for pos= 0:(L-1)
        S_forward = S_forward + S_extend_forward((1:N2)+pos,(1:M1)+pos);
        S_backward = S_backward + S_extend_backward((1:N2)+L-pos,(1:M1)+L-pos);
    end
    
    % take the average as similarity 
    S_forward = S_forward/L;
    S_backward = S_backward/L;
    

    % map the supposed time axis back to original time axis
    index_resample = max(round(([1:N1]/N1)*M1),1);   % map back sample indices from M1 to N1
    
    S_forward_currTempi = S_forward(:,index_resample);
    S_forward_final = max (S_forward_final, S_forward_currTempi);

    
    S_backward_currTempi = S_backward(:,index_resample);    
    S_backward_final = max (S_backward_final, S_backward_currTempi);
end




end