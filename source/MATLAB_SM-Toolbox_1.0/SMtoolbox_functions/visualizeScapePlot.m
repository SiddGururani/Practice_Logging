function [handleFigure,time,len]= visualizeScapePlot(T,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualizeScapePlot.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
% Visualization of fitness scape plot pathFamily.
%
%
% Input:
%       S : a similarity matrix
%       pathFamily :
%       parameter (optional): parameter struct with fields
%               .timeLineUnit : sample or second
%               .featureRate: how many frames correspond to one second.
%               .colormap : colormap to use
%               .title : title of figure
%               .titleVisible: show title of not
%               .print : print (output) figure or not
%               .dirFigure : directory where the figure is saved
%               .figureName : file name of figure
%               .printPaperPosition : size of printed figure
%
% Output:
%       handleFigure
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

if nargin<2
    parameter=[];
end

%------------ time line of figure--------------------------

if isfield(parameter,'timeLineUnit')==0
    parameter.timeLineUnit = 'sample'; % or alternatively, 'second'.
end


if isfield(parameter,'featureRate')==0
    switch parameter.timeLineUnit
        case 'sample'
            parameter.featureRate = 0;
            
        case 'second' 
            % If unit using time in seconds, featureRate must be provided. If not provided, we switch to time in samples
            warning('parameter.featureRate unknown for timeline in seconds, switch to timeline in samples.');
            parameter.timeLineUnit = 'sample';
            parameter.featureRate = 0;
            
        otherwise
            % Default mode. if neither 'second' nor 'sample' is specified, we take 'sample' mode.
            warning('parameter.featureRate unknown for timeline in %s, switch to timeline in samples.',parameter.timeLineUnit);
            parameter.timeLineUnit = 'sample';
            parameter.featureRate = 0;
    end
end


%------------ color of figure--------------------------
if isfield(parameter,'colormap')==0
    figure;
    parameter.colormap = flipud(hot);
    close;
end


%------------ title of figure--------------------------

if isfield(parameter,'title')==0
    parameter.title = '';
end


if isfield(parameter,'titleVisible')==0
    parameter.titleVisible = 1;
end


%------------ print figure--------------------------
if isfield(parameter,'print')==0
    parameter.print = 0;
end

if isfield(parameter,'dirFigure')==0
    parameter.dirFigure ='./';
end

if isfield(parameter,'figureName')==0
    parameter.figureName = 'figure';
end

if isfield(parameter,'printPaperPosition')==0
    parameter.printPaperPosition = [1   1   3*4.2  3*4];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Visualizations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



N = size(T,1);


% generate x_axis as segment_start in seconds or samples, 
%          y_axis as segment_length in seconds or samples.
% halfFrameLen is used later, for plotting edges of scapeplot trangle
switch parameter.timeLineUnit
    case 'sample'
        %sample index start from 1
        time = 1:1:N;
        len = 1:1:N;
        halfFrameLen = (1/1)/2;
    case 'second'
        %time index start from 0
        time= (0:N-1)./parameter.featureRate;
        len  = (1:N)./parameter.featureRate;
        halfFrameLen = (1/parameter.featureRate)/2;
end






% generate scapeplot matrix S
% convert coordinate in T (x,y) representing (segment_start,  segment_length)
% to      coordinate in S (x,y) representing (segment_center, segment_length)
S = zeros(N,N);
for n = 1:N
    shift = floor(n/2);
    row = T(n,:);
    S(n,:) = circshift(row,[0 shift]);
end



% plot Scapeplot S
handleFigure = figure;
imagesc(time,len,S);
colormap(parameter.colormap);
colorbar;
axis xy;



% plot triangle edge
linewidth = 2;
eps = halfFrameLen;
hold on;
plot([time(1)- eps,time(end)+eps],[time(1)-eps, time(1)-eps],'LineWidth',linewidth,'Color','k'); %horizontal
plot([time(1) - eps,time(end)/2 ],[ time(1) - eps,time(end) + eps],'LineWidth',linewidth,'Color','k'); %
plot([time(end)/2,time(end) + eps],[time(end)+eps,time(1)],'LineWidth',linewidth,'Color','k'); %
hold off;



% title
if parameter.titleVisible
    title(parameter.title,'Interpreter','none');
end


% xlabel, ylabel
xlabel(['Time (',parameter.timeLineUnit,'s)']);
ylabel(['Time (',parameter.timeLineUnit,'s)']);



% additional control
axis square;
box on;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if parameter.print
    
    figureName = strcat([parameter.dirFigure parameter.figureName, '.eps']);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperPosition',parameter.printPaperPosition);
    print('-depsc2',figureName);
    
end



end

