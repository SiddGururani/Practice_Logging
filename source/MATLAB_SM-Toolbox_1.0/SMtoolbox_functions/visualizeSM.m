function [handleFigure] = visualizeSM(SM,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualizeSM.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
% Visualization of Similarity Matrix (SM)
%
%
% Input:
%       SM : a similarity matrix
%       parameter (optional): parameter struct with fields
%               .imageRange : range of values to display
%               .colormapPreset : colormap to use
%               .colorbar : show colorbar or not
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





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2
    parameter=[];
end




%--------- value and color-----------------------%

if isfield(parameter,'imagerange')==0
    parameter.imagerange = 0; %[0 1];
end

if isfield(parameter,'colorbar')==0
    parameter.colorbar = 1;
end

if isfield(parameter,'colormapPreset')==0
    parameter.colormapPreset = 3;
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decide colormap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

colormapSet = generateColormapValue();
colormap5 = colormapSet.colormap5;
colormap4 = colormapSet.colormap4;

switch parameter.colormapPreset
    case 1 % gray
        parameter.colormap = gray;
        
    case 2  % exponential
        parameter.colormap = colormap5;
        
    case 3  % enhanced
        parameter.colormap = colormap4;
end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N,M]=size(SM);


%timeline

t1 = 1:1:N;
t2 = 1:1:M;






%main figure
handleFigure = figure;
if parameter.imagerange == 0
    imagesc(t2,t1,SM);
else
    imagesc(t2,t1,SM,parameter.imagerange);
end



%title
if parameter.titleVisible
    title(parameter.title,'Interpreter','none');
end



%color
colormap(parameter.colormap);
if parameter.colorbar
    colorbar;
end


%axis as coordinate system
axis xy;

if(N==M)
    axis square;
end

% xlabel, ylabel
% xlabel(['Time (samples)']);
% ylabel(['Time (samples)']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Print figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if parameter.print
    
    figureName = strcat([parameter.dirFigure parameter.figureName, '.eps']);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperPosition',parameter.printPaperPosition);
    print('-depsc2',figureName);


end


end

