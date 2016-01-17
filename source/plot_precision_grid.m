% inputs:
%           detect_p: 2D mat generated from grid_search_eval
%           t: 1D array of t values used in the grid search
%           l: 1D array of l values used in the grid search
function plot_precision_grid(detect_p, t, l, n)
figure;
imagesc(l,t,detect_p);
xlabel('Length of Erosion/Dilation Line (frames)');
ylabel('Threshold for Binarization');
title(['Accuracy In a Parameter Space for ', num2str(n), ' files']);
colorbar;
