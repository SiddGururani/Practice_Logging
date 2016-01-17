% This function is originally from Ashis Pati and used for our purposes, 12/05/2015 
% Reason: Algorithmic prototyping. Will be implemented if algorithm works better.
%% Adaptive threshold: median filter
% [thres] = myMedianThres(nvt, order, lambda)
% input: 
%   nvt: m by 1 float vector, the novelty function
%   order: int, size of the sliding window in samples
%   lambda: float, a constant coefficient for adjusting the threshold
% output:
%   thres = m by 1 float vector, the adaptive median threshold

function [thres] = myMedianThres(nvt, order, lambda)

zeroPadnvt = zeros(length(nvt)+order,1);
zeroPadnvt(floor(order/2)+1:floor(order/2)+length(nvt)) = nvt(1:end);

thres = zeros(size(nvt));
for i = 1:length(nvt)
    thres(i) = median(zeroPadnvt(i:i+order));
end

thres = thres + lambda;

end