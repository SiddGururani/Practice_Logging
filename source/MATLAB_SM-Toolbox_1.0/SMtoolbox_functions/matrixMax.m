function [maxTwoMatrix,IdxAorB] = matrixMax(A,B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: matrixMax.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   This function compute element-wise max of two matrix

%
% Input:
%       A: matrix A
%       B: matrix B
%
%
% Output:
%       maxTwoMatrix: element-wise max value of the two input matrix
%       IdxAorB : element-wise index, showing where the max value comes
%                 from.
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


maxTwoMatrix = max(A,B);

res =  A - maxTwoMatrix;

IdxAorB = (res < 0); % 0 means coming from A, 1 means coming from B


end

