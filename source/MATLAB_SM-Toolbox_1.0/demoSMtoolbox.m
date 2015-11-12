%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name: demoSMtoolbox.m
% Date of Revision: 2013-06
% Programmer: Nanzhu Jiang, Peter Grosche, Meinard Müller
% http://www.audiolabs-erlangen.de/resources/MIR/SMtoolbox/
%
% Description: 
%   This is the main demo file which illustrates main functionalities of
%   the 'SM tool box'. We refer to the paper [MJG13] (see below reference) for 
%   a detailed description.   
%
%   1. Loads a wav file and converts it into 22050 Hz, mono
%   2. Computes chroma features (CENS variant with a feature resolution 
%      of 2 Hertz). The used functions are part of the Chroma Toolbox
%      http://www.mpi-inf.mpg.de/resources/MIR/chromatoolbox/ 
%   3. Computes and visualizes similarity matrices using different
%      enhancement strategies. These funtions are contained in the folder
%      '/SMtoolbox_functions/';
%   4. Supplies synchronized audio playback. To test this functionality,
%      Please use a left mouse click on the horizontal time axis of Figure 8.
%
% Note: The audio example 'Test_AABA.wav' is a structurally modified and 
%   time-stretched version of the file 'Chopin_Op010-03_007_20100611-SMD'
%   contained in the 'SMD MIDI-Audio Piano Music' of the Saarland Music 
%   Data (SMD): http://www.mpi-inf.mpg.de/resources/SMD/
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


initPaths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following lines are identical to the code of Table 2, [MJG13].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; close all;
filename = 'Test_AABA.wav';
[f_audio,sideinfo] = wav_to_audio('', 'data_music/', filename);
paramPitch.winLenSTMSP = 4410;
[f_pitch] = audio_to_pitch_via_FB(f_audio,paramPitch);
paramCENS.winLenSmooth = 11;
paramCENS.downsampSmooth = 5;
[f_CENS] = pitch_to_CENS(f_pitch,paramCENS);

S = features_to_SM(f_CENS,f_CENS);
paramVis.colormapPreset = 2;
visualizeSM(S,paramVis);

paramSM.smoothLenSM = 20;
S = features_to_SM(f_CENS,f_CENS,paramSM);
visualizeSM(S,paramVis);

paramSM.tempoRelMin = 0.5;
paramSM.tempoRelMax = 2;
paramSM.tempoNum = 7;
S = features_to_SM(f_CENS,f_CENS,paramSM);
visualizeSM(S,paramVis);

paramSM.forwardBackward = 1;
S = features_to_SM(f_CENS,f_CENS,paramSM);
visualizeSM(S,paramVis);

paramSM.circShift = [0:11];
[S,I] = features_to_SM(f_CENS,f_CENS,paramSM);
visualizeSM(S,paramVis);
visualizeTransIndex(I,paramVis);

paramThres.threshTechnique = 1;
paramThres.threshValue = 0.75;
paramThres.applyBinarize = 1;
[S_thres,paramThres] = threshSM(S,paramThres);
visualizeSM(S_thres,paramVis);

paramThres.threshTechnique = 2;
paramThres.threshValue = 0.15;
paramThres.applyBinarize = 0;
paramThres.applyScale = 1;
paramThres.penalty = -2;
[S_final] = threshSM(S,paramThres);  
paramVis.imagerange = [-2,1];
paramVis.colormapPreset = 3;
paramVis.print=1;
paramVis.figureName='SM_final';
handleFigure = visualizeSM(S_final,paramVis);

parameterMPP.fs = 22050;
parameterMPP.featureRate = 2;
makePlotPlayable(f_audio, handleFigure, parameterMPP);
