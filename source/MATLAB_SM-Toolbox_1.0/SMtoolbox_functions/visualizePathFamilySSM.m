function [handleFigure,parameter] = visualizePathFamilySSM(S,pathFamily,parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: visualizeSM.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
%
% Description:
% Visualization of the similarity matrix (S) together with pathFamily.
%
%
% Input:
%       S : a similarity matrix
%       pathFamily :
%       parameter (optional): parameter struct with fields
%               .timeLineUnit : sample or second
%               .featureRate: how many frames correspond to one second.
%               .visualizeWarpingpath :plot warping path or not
%               .visualizeInducedSegments : plot induced segments or not
%               .imageRange : range of values to display
%               .colormapMethod : colormap to use
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
    pathFamily = [];
end

if nargin<3
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


%------------ content of figure--------------------------
if isfield(parameter,'visualizeWarpingpath')==0
    parameter.visualizeWarpingpath = 1;
end

if isfield(parameter,'visualizeInducedSegments')==0
    parameter.visualizeInducedSegments = 0;       
end


%------------ color of figure--------------------------
if isfield(parameter,'colorbar')==0
    parameter.colorbar = 1;
end


if isfield(parameter,'colormapMethod')==0
    parameter.colormapMethod = 3;
end


if isfield(parameter,'imagerange')==0
    parameter.imagerange = 0; %[0 1];
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
% Decide colormap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colormapSet = generateColormapValue();
colormap5 = colormapSet.colormap5;
colormap4 = colormapSet.colormap4;

switch parameter.colormapMethod
    case 1 % gray
        parameter.colormap = gray;
        
    case 2  % exponential
        parameter.colormap = colormap5;
        
    case 3  % for enhanced SSM
        parameter.colormap = colormap4;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualizations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%-----prepare SSM axis----------------%
[N,M]=size(S);
switch parameter.timeLineUnit
    case 'sample'
        %sample index start from 1
        t1 = 1:1:N;
        t2 = 1:1:M;
    case 'second'
        %time index start from 0
        t1 = [0:N-1]/parameter.featureRate;
        t2 = [0:M-1]/parameter.featureRate;
end





%-------show SSM ---------------------%


handleFigure = figure;
if parameter.imagerange == 0
    imagesc(t2,t1,S);
else
    imagesc(t2,t1,S,parameter.imagerange);
end

colormap(parameter.colormap);
if parameter.colorbar == 1
    colorbar;
end



%------decide temporary featureRate for plotting------------%


if(strcmp(parameter.timeLineUnit,'second')&&(parameter.featureRate>0))
    % plot in second
    tempFeatureRate = parameter.featureRate;
    shift = 1;
else % plot in samples
    tempFeatureRate = 1;
    shift = 0;
end



%-------plot pathFamily------------------%

if ~isempty(pathFamily) && ~iscell(pathFamily)
    pathFamily = {pathFamily};
end


if parameter.visualizeWarpingpath == 1 && size(pathFamily,1) > 0
    hold on;
    
    
    numPath = size(pathFamily,1);
    for n=1:numPath
        warpingpath = pathFamily{n};
        
        h = plot((warpingpath(2,:)-shift)/tempFeatureRate,(warpingpath(1,:)-shift)/tempFeatureRate,'o');
        set(h,'Color',[0 0 0]);
        set(h,'LineWidth',3);
        set(h,'Markersize',5);
        h = plot((warpingpath(2,:)-shift)/tempFeatureRate,(warpingpath(1,:)-shift)/tempFeatureRate,'.');
        set(h,'Color',[0.7 1 1 ]);
        set(h,'LineWidth',2);
        set(h,'Markersize',6);
        
    end
    hold off;
end



%-------plot inducedSegments------------------%

if parameter.visualizeInducedSegments
    hold on;
    width = max(ceil(N/40),3);
    height = max(ceil(M/40),3);
    for m = 1:length(pathFamily)
        
        y1 = (pathFamily{m}(1,1)-1 )/ tempFeatureRate;
        y2 = (pathFamily{m}(1,end)-1)/tempFeatureRate ;
        rectangle('Position',[0,y1,width,y2-y1+1],'FaceColor','r');
        
    end
    
    x1 = (pathFamily{1}(2,1)-1 )/ tempFeatureRate;
    x2 = (pathFamily{1}(2,end)-1)/tempFeatureRate;
    
    rectangle('Position',[x1,0,x2-x1+1,height],'FaceColor',[1,    0.5,    0]);
    hold off;
end








%title
if parameter.titleVisible
    title(parameter.title,'Interpreter','none');
end



% xlabel, ylabel
xlabel(['Time (',parameter.timeLineUnit,'s)']);
ylabel(['Time (',parameter.timeLineUnit,'s)']);


%-------additional control-----------------%
axis xy;
axis square;
drawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if parameter.print
    
    figureName = strcat([parameter.dirFigure parameter.figureName, '.eps']);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperPosition',parameter.printPaperPosition);
    print('-depsc2',figureName);
    
end

