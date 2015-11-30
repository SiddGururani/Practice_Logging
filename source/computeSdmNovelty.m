%% compute novelty function from Self-distance matrix
% input:
%   SDM: float N by N matrix, self-distance matrix
%   L: int, size of the checkerboard kernel (L by L) preferably power of 2
% output:
%   nvt: float N by 1 vector, audio segmentation novelty function 

function [nvt] = computeSdmNovelty(SDM, L)

% Create the Kronecker product
a = [1 -1;-1 1];
b = ones(L/2,L/2);
kernel = kron(a,b);

% Multiply the kernel by a gaussian
gaussian = fspecial('gaussian',L,L/4);
kernel = kernel.*gaussian;

% You need to convert the distance matrix into self-similarity matrix
SSM = 1 - SDM;

numSteps = size(SSM,1)-L+1;
nvt = zeros(1,numSteps);

for i=1:numSteps
    nvt(i) = sum(sum(kernel.*SSM(i:L+i-1,i:L+i-1)));
end
% This calculation should be padded with zeros on both ends to be at the
% center of the kernel.
nvt = [zeros(1,L/2) nvt zeros(1,L/2)];

