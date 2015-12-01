% Code for finding the self-similarity of a .wav file from MATLABs
% SM_Toolbox: demoSMToolbox.m
% Modified for our purposes: RMW 11/12/2015

function my_self_similarity(filename)

% Filename is a filename in the present directory mp3 format

% It would appear that sideinfo is not being used in the following line, so
% we might even forego wav_to_audio in the first place
%[f_audio,~] = wav_to_audio('', '', filename);

% Now we assume filename is a two-channel mp3 (which it is for our
% purposes)
f_audio = down_mix(mp3read(filename));

% The remainder of the code is a direct copy from demoSMToolbox.m
paramPitch.winLenSTMSP = 4410;
[f_pitch] = audio_to_pitch_via_FB(f_audio,paramPitch);
paramCENS.winLenSmooth = 11;
paramCENS.downsampSmooth = 5;
[f_CENS] = pitch_to_CENS(f_pitch,paramCENS);

% This block takes the longest to compute
paramVis.colormapPreset = 2;
paramSM.smoothLenSM = 20;
paramSM.tempoRelMin = 0.5;
paramSM.tempoRelMax = 2;
paramSM.tempoNum = 7;
paramSM.forwardBackward = 1;
paramSM.circShift = [0:11];
[S,~] = features_to_SM(f_CENS,f_CENS,paramSM);


paramThres.threshTechnique = 1;
paramThres.threshValue = 0.75;
paramThres.applyBinarize = 1;
[~,paramThres] = threshSM(S,paramThres);

paramThres.threshTechnique = 2;
paramThres.threshValue = 0.15;
paramThres.applyBinarize = 1;
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

%Normalize S_final
S_final_norm = S_final + 2;
S_final_norm = S_final_norm/max(S_final_norm(:));
