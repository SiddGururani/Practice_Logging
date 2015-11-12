%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: makePlotPlayable.m
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
% Programmer:   Harald G. Grohganz, University of Bonn (grohganz@cs.uni-bonn.de)
%               May-June 2012
%               Version 1.92st, 2013-06-10
%
% Input:        audio           - audio stream
%               imageHandle     - handle for image, plot etc. objects
%                                 if this is not set, we will use current axis object
%               parameter       - struct containing setting information
%
% Output:       xPlayer         - handle of audioplayer instance
%               playback        - handle of line plot (shows current audio position within the image)
%
%
%       parameter
%           fs                  - audio sampling rate [Hz] (std: 22050)
%           refreshRate         - actualization rate for playback position [Hz]
%           scrollRate          - factor of mouse wheel scrolling impact [<1]
%           featureRate         - feature vectors per second (std: audioLength/imageWidth)
%           featureTimeResType  - type of x axis' division (std: features)
%           lineColor           - color of playback line
%
%           scoreFollowing      - enables score following functionality (std: true)
%           noscroll            - disables mouse wheel zoom-in (std: false)
%           toolbar             - enables MATLAB figure toolbar (std: true)
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
 function fcn_update = makePlotPlayable(audio, imageHandle, parameter)
 
    if nargin < 1
        error('Please specify audio samples!')
    end
    
    if nargin < 2
        imageHandle = [];
    end
         
    if nargin < 3
        parameter = [];
    end
    
    if ~isempty(imageHandle) && strcmp('image', get(imageHandle,'type'))
        axisHandle = get(imageHandle, 'Parent');
        figureHandle = get(axisHandle, 'Parent');
        set(imageHandle,'HitTest','off');
        if ~isfield(parameter,'lineColor') || isempty(parameter.lineColor)
            parameter.lineColor = [1 1 1];
        end
        
    else
        axisHandle = gca;
        figureHandle = gcf;
        if ~isfield(parameter,'lineColor') || isempty(parameter.lineColor)
            parameter.lineColor = [0 152/255 1];
        end
    end
    
    maxX = max(get(axisHandle,'XLim'));
    minX = min(get(axisHandle,'XLim'));
    maxY = max(get(axisHandle,'YLim'));
    minY = min(get(axisHandle,'YLim'));
    
    if ~isfield(parameter, 'fs')
        parameter.fs = 22050;
    end
    
    if ~isfield(parameter, 'featureRate')
        parameter.featureRate = parameter.fs * (maxX-minX)/size(audio,1);
    end
    
    if isfield(parameter, 'cleanUp') && parameter.cleanUp == 1
        java.lang.System.gc();
    end
    
    if ~isfield(parameter, 'featureTimeResType')
        parameter.featureTimeResType = 'features';
    end
        
    if ~isfield(parameter, 'scoreFollowing')
        parameter.scoreFollowing = 1;
    end
    
    if ~isfield(parameter, 'noscroll')
        parameter.noscroll = 0;
    end
    
    if ~isfield(parameter, 'refreshRate')
        parameter.refreshRate = 50;
    end
    
    if ~isfield(parameter, 'scrollRate')
        parameter.scrollRate = 0.75;
    end
    
    if ~isfield(parameter, 'toolbar')
        parameter.toolbar = 1;
    end
    
    if parameter.toolbar == 1
        set(figureHandle,'Toolbar','figure');
    else
        set(figureHandle,'Toolbar','none');
    end
    
    if parameter.scoreFollowing == 1
        parentColor = get(figureHandle, 'color');
        boxHandle = uicontrol('Style', 'checkbox', 'String', 'Score Following',...
        'Position', [10 10 150 20], 'Callback', @checkFollowStatus, ...
        'BackgroundColor', parentColor);     
    end
    
    switch parameter.featureTimeResType

        case 'seconds'
            image2audio = @(x) x; % identity
            audio2image = @(x) x;
            
        case 'features'
            image2audio = @(x) x/parameter.featureRate;
            audio2image = @(x) x*parameter.featureRate;
            
        otherwise
            error('parameter.featureTimeResType is not set to a valid entry.')
            
    end
    
    
    % Some global settings
    
    scoreFollowing = 0;
    xPast = (maxX-minX)*0.39; xFuture = (maxX-minX)*0.61;
    curXpos = eps;

    
    % Insert playback functionality
   
    playback = line([curXpos curXpos],[minY-0.5 maxY+0.5], ...
                    'LineStyle', '-.', 'Color', parameter.lineColor, 'LineWidth', 2);
    
    xPlayer = [];
    initPlayer();

    set(axisHandle,'ButtonDownFcn', @onClickSegButton_down_player);
    if parameter.noscroll ~= 1
        set(figureHandle, 'WindowScrollWheelFcn', @mouseWheel);
    end
    set(figureHandle, 'KeyPressFcn', @keys);
    
    set(figureHandle, 'CloseRequestFcn', @closeFigureAndPlayer)
        
    fcn_update = @updateAudio;
    
    
    % Playback functions
    
    function initPlayer()
   
        xPlayer = audioplayer(audio, parameter.fs);
        
        set(xPlayer,'TimerFcn',@(s,o) playerUpdatePos('timer') );
        xPlayer.TimerPeriod = 1/parameter.refreshRate;
    
    end


    function onClickSegButton_down_player(s,o)
    
        backupFollow = scoreFollowing;
        scoreFollowing = 0;
        
        curr_xAxis = get(axisHandle, 'XLim');
        
        button = get(figureHandle,'SelectionType');
        cPoint = get(gca, 'Currentpoint');
        x = cPoint(1,1);
        
        if isplaying(xPlayer)
            stop(xPlayer);
        end
        
        if (strcmp(button, 'normal') && x >= curr_xAxis(1) && x <= curr_xAxis(2))
            curXpos = x;
            playerUpdatePos('start');        
            
            if backupFollow == 1
                checkFollowStatus(boxHandle);
            end
        elseif (strcmp(button, 'alt') && x >= curr_xAxis(1) && x <= curr_xAxis(2))
            curXpos = eps;
            playerUpdatePos('stop');
        end
    
    end


    function playerUpdatePos(task)

        if nargin < 1
            task = 'timer';
        end
        
        if ~ishandle(axisHandle) || ~ishandle(figureHandle)
            stop(xPlayer);
            return;
        end

        if strcmp(task, 'start');
            audioPos = floor(image2audio(curXpos) * parameter.fs);
            play(xPlayer, max(1, audioPos));
            
        elseif strcmp(task, 'pause')
            pause(xPlayer);
            return
            
        elseif strcmp(task, 'stop')
            curXpos = eps;
            set(playback, 'XData', [curXpos curXpos]);
            stop(xPlayer);
            return
        end
        
        audioPos = get(xPlayer,'CurrentSample')/parameter.fs;
        imagePos = audio2image(audioPos);
        set(playback, 'XData', [imagePos imagePos]);
        curXpos = imagePos;

        if scoreFollowing == 1
            set(axisHandle, 'XLim', [curXpos-xPast curXpos+xFuture]);
        end
        drawnow;

    end


    function mouseWheel(s,o)
        scroll = o.VerticalScrollCount;
        
        xPast = xPast / parameter.scrollRate^sign(scroll);
        xFuture = xFuture / parameter.scrollRate^sign(scroll);

        if scoreFollowing == 0
            cPoint = get(axisHandle, 'Currentpoint');
            cLim = get(axisHandle, 'XLim');
            t = cPoint(1,1);
            tPast = abs(min(cLim)-t) / parameter.scrollRate^sign(scroll);
            tFuture = abs(max(cLim)-t) / parameter.scrollRate^sign(scroll);
            set(axisHandle, 'XLim', [t-tPast t+tFuture]);
        else
            playerUpdatePos();
        end
    end

    function keys(s,o)
        
        if strcmp(o.Key,'space')
            if isplaying(xPlayer)
                playerUpdatePos('pause')
            else
                playerUpdatePos('start')
            end
        end
        
    end
    
    
    function checkFollowStatus(s,o)
        scoreFollowing = get(s,'Value');
    end


    function closeFigureAndPlayer(varargin)
        stop(xPlayer);
        delete(figureHandle);
    end


    %% Nested function for outside audio update
    
    function updateAudio(new_audio)
        
        if size(audio) ~= size(new_audio)
            error('Wrong audio size.');
        end
        
        currentSample = get(xPlayer,'CurrentSample');
        
        if isplaying(xPlayer)
            wasPlaying = 1;
            stop(xPlayer);
        else
            wasPlaying = 0;
        end
        
        clear xPlayer;
        audio = new_audio;
        initPlayer();
        
        if wasPlaying == 1
            play(xPlayer, max(1,currentSample));
        end
        
    end

end