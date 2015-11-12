function [handleFigure] = visualizeSegFamily(segmentStructArray,parameter,handleFigure)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualizeSegFamily.m
% Date of Revision: 2013-08
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
%   Visualization of fitness scape plot pathFamily.
%
%
% Input:
%       struct array of segments having the fields:
%                 .start (in seconds)
%                 .end   (in seconds)
%                 .label

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

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin < 2)
    parameter = [];
end


if (nargin < 3)
    handleFigure = [];
end


if isfield(parameter,'duration')==0
    error('please provide parameter.duration\n');
end

if isfield(parameter,'showXTick')==0
    parameter.showXTick = 1;
end


if isfield(parameter,'showLabelText')==0
    parameter.showLabelText = 0;
end

if isfield(parameter,'segType')==0 || isempty(parameter.segType)
    parameter.segType = 'computed';
end

if isfield(parameter,'colorSpec')==0
    parameter.colorSpec = 0;
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




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% color speficication
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here the 10 color are predefined.
% The later 20 more colors are random generated.
% If more color is needed, please give the value yourself.
colorSpecGroundtruth = [...
    1,      0.5,    0;%orange
    0.33,   0.75,   0.96;%light blue
    0,      1,      0;%green
    1,      1,      0;%yellow
    0,      1,      1;%cyan
    1,      0,      1;%magenta
    0.99,   0.51,   0.71 ;%light red
    0.53,   0.0,    0.46;% darker purple
    0.56,   0.93,   0.72; % light green
    0,      0,      0.9;% newblue
    rand(20,3);
    ];


colorSpecComputed = [...
    1,      0,      0;%red
    0,      1,      0;%green
    0,      0,      1;%blue
    1,   0.85,      0;% new yellow
    0,   0.85,      1;% new cyan
    0.9,      0,    0.9;% new magenta
    1,      0.5,    0; %orange
    0.53,   0.0,    0.46;% darker purple
    0.56,   0.93,   0.72; % light green
    0.99,   0.51,   0.71 ;%light red
    rand(20,3);
    ];


if (parameter.colorSpec==0)
    if(strcmpi(parameter.segType,'groundtruth'))
        colorSpec = colorSpecGroundtruth;
    else
        colorSpec = colorSpecComputed;
    end
    
else
    colorSpec = parameter.colorSpec;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yPos =0.5;
yPosText = 0.6;
recHeight = 1;
duration = parameter.duration;


% map label to number, this number served as color index
labels = {segmentStructArray.label};
[labelsColorIdx] = map_labels_to_colorIndices(labels);



if isempty(handleFigure)
    handleFigure = figure;
end




if(parameter.showLabelText)
    % for label with many characters, we need to rotate them 90degrees to display
    maxLabelLength = findMaximumLabelLength(segmentStructArray);
    if(maxLabelLength > 7) % threshold hard coded for label with more than 10 characters
        rotationDegree = 90;
    else
        rotationDegree = 0;
    end
end


% all blocks plotted in timeline of seconds, not samples.
blocks = segmentStructArray;
tick_time = [];

for l = 1:length(blocks)
    
    curLabel = blocks(l).label;
    
    seg_start = blocks(l).start;
    seg_end = blocks(l).end;
    seg_start = max(0,seg_start);
    seg_end = min(duration,seg_end);
    
    seg_color = colorSpec( labelsColorIdx(l),: ) ;
    
    recWidth = seg_end - seg_start;
    
    if(recWidth > 0)
        h=rectangle('Position',[seg_start,yPos,recWidth,recHeight],'FaceColor', seg_color);
        
        
        
        
        
        if(parameter.showLabelText)
            offset = 3;
            text(seg_start + offset,yPosText,curLabel,'Interpreter','none','FontSize',10,'Rotation',rotationDegree);
        end
        
        
    else
        warning('segment %d can not be visualized, segment start: %.2f, end: %.2f, label: %s\n',l,seg_start,seg_end,curLabel);
    end
    
    
    
    
    % save time pos as xtick
    tick_time(2*l-1) = blocks(l).start;
    tick_time(2*l) = blocks(l).end;
    
    
    
end


tick_time = sort(tick_time);
tick_time = floor(tick_time * 10)/10;
tick_time = unique(tick_time);

if(parameter.showXTick)
    set(gca,'XTick',tick_time);
end


xlim([0,duration]);
ylim([0.5,1.0]);

set(gca,'YTick',[]);
xlabel(['Time (seconds)']);

box on;





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if parameter.print
    
    figureName = strcat([parameter.dirFigure parameter.figureName, '.eps']);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperPosition',parameter.printPaperPosition);
    print('-depsc2',figureName);
    
end


end




function [maxLabelLength] = findMaximumLabelLength(segArray)

maxLabelLength = 0;
for l = 1:length(segArray)
    curLabel = segArray(l).label;
    lengthCurLabel = length(curLabel);
    maxLabelLength = max(maxLabelLength,lengthCurLabel);
end


end


