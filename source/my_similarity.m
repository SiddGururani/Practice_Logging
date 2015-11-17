% Code for finding the self-similarity of a .wav file from MATLABs
% SM_Toolbox: demoSMToolbox.m
% Modified for our purposes: RMW 11/12/2015

function S_final = my_similarity(filename1, movt)

% Filename1 is a filename in the present directory mp3 format
% Filename2 is the template filenmane in potentially another directory

% It would appear that sideinfo is not being used in the following line, so
% we might even forego wav_to_audio in the first place
%[f_audio,~] = wav_to_audio('', '', filename);

% Now we assume filename is a two-channel mp3 (which it is for our
% purposes)
%f_audio1 = down_mix(mp3read(filename1));
%f_audio2 = down_mix(mp3read(filename2));

% The remainder of the code is a direct copy from demoSMToolbox.m
paramPitch.winLenSTMSP = 4410;
%[f_pitch1] = audio_to_pitch_via_FB(f_audio1,paramPitch);
%[f_pitch2] = audio_to_pitch_via_FB(f_audio2,paramPitch);
paramCENS.winLenSmooth = 11;
paramCENS.downsampSmooth = 5;
%[f_CENS1] = pitch_to_CENS(f_pitch1,paramCENS);
%[f_CENS2] = pitch_to_CENS(f_pitch2,paramCENS);

f_CENS1 = open([filename1 '.mat']);
f_CENS1 = f_CENS1.f_CENS1;

f_CENS2 = open([movt '.mat']);
f_CENS2 = f_CENS2.f_CENS2;

% This block takes the longest to compute
paramVis.colormapPreset = 2;
paramSM.smoothLenSM = 20;
paramSM.tempoRelMin = 0.5;
paramSM.tempoRelMax = 2;
paramSM.tempoNum = 7;
paramSM.forwardBackward = 1;
paramSM.circShift = [0:11];
[S,~] = features_to_SM(f_CENS1,f_CENS2,paramSM);


paramThres.threshTechnique = 1;
paramThres.threshValue = 0.75;
paramThres.applyBinarize = 1;
[~,paramThres] = threshSM(S,paramThres);

paramThres.threshTechnique = 2;
paramThres.threshValue = 0.15;
paramThres.applyBinarize = 0;
paramThres.applyScale = 1;
paramThres.penalty = -2;
[S_final] = threshSM(S,paramThres);  

% paramVis.imagerange = [-2,1];
% paramVis.colormapPreset = 3;
% paramVis.print=1;
% paramVis.figureName='SM_final';
% handleFigure = visualizeSM(S_final,paramVis);

% parameterMPP.fs = 22050;
% parameterMPP.featureRate = 2;
% makePlotPlayable(f_audio1, handleFigure, parameterMPP);


