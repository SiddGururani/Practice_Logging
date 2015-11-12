function [handleFigure] = visualizeTransIndex(transIdxMatrix,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualizeTransIndex.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
% Visualize transposition index matrix. 
%
%
% Input:
%       transIdxMatrix : transposition index matrix 
%       parameter (optional): parameter struct with fields
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

if (nargin< 2)
    parameter = [];
end


%----------- title ------------------------------%

if isfield(parameter,'title')==0
    parameter.title = '';
end

if isfield(parameter,'titleVisible')==0
    parameter.titleVisible = 0;
end

%----------print Figure------------------------------%
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



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Color setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myBlack = [0,0,0];
myWhite = [1,1,1];
myGray = [100,100,100]/255;

myGreen = [0,1,0];
myBlue = [0,0,1];
myRed = [1,0,0];
myYellow = [1,1,0];
myCyan = [0,1,1];
myMagenta = [1,0,1];
myOrange = [0.8906,    0.7148,    0.1055];
myPurple = [ 0.4063,    0.1289,    0.8672];
myLightGreen = [0.5664 ,   0.9375   , 0.7227];
myLightBlue = [0 ,   128/255  ,  1 ];
myPink = [255,128,192]/255;
myDarkRed = [128,0,64]/255;
myPeachRed = [255,0,128]/255;


computedColors = [...
    myBlack;    %0
    myRed;  %7  %dominant
    myCyan;     %6    
    myGreen;    %1
    myBlue;     %2
    myPink;      %3
    myYellow;   %4
    myOrange;   %8
    myPurple;   %9
    myLightBlue;    %11     
    myLightGreen;   %10
    myMagenta;    %5    
    ];




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



handleFigure = figure;
imagesc(transIdxMatrix);
colormap(computedColors);
axis xy;

h = colorbar;

% cValue domain [0,11];
cminValue = -0.5;
cmaxValue = 11.5;
colorbarTicks = [0:1:11];

caxis([cminValue cmaxValue]);
set(h,'YLim',[cminValue cmaxValue]);%
set(h,'YTick',colorbarTicks);
set(h,'YTickLabel',colorbarTicks);


if(size(transIdxMatrix,1)==size(transIdxMatrix,2))
    axis square;
end

xlabel(['Time (samples)']);
ylabel(['Time (samples)']);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if parameter.print

    figureName = strcat([parameter.dirFigure parameter.figureName, '.eps']);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperPosition',parameter.printPaperPosition);
    print('-depsc2',figureName);
    
end



end
