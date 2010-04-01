function params = getParams
% function params = getParams
%
%   Various configuration variables for the task
%

    %% Other

    params.basepath = pwd;
    params.screenNum = 0;
    params.subjectID = 0;   % ID=0 => nothing is recorded
    
    %% EEG Stuff
    
    samplingRate = 250; % Hz
    
    % EEG trigger setting
    params.eeg.fixHeader = 1;
    interSample = 1/samplingRate;
    params.eeg.interSample = interSample*1.5;
    
    % EEG trigger keys
    params.eeg.start = 255;
    params.eeg.stop = 253;
    params.eeg.blockStart = 101;
    params.eeg.blockEnd = 102;
    params.eeg.blockSectionStart = 105;
    params.eeg.blockSectionEnd = 106;
    params.eeg.calibrateStart = 111;
    params.eeg.calibrateEnd = 112;
    params.eeg.startTrial = 11;
    %%% stimuli/response specific
    params.eeg.target = 21;
    params.eeg.noTarget = 22;
    params.eeg.correct = 31;
    params.eeg.incorrect = 32;
    params.eeg.noResponse = 33;
    
    
    %% Task Stuff
    
    params.disp.bgContrast = 0.5;    % range is 0-1
    
    % Structure
    params.taskSet.percentNonTarget = 0.1;
    params.taskSet.numBlocks = 4;
    params.taskSet.numTrialsPerBlock = 60;
    
    % Instructions/Text
    % params.instructions = {};
    % params.instructions{1} = 'Focus on the square in the center for the whole time. \nPress j if you see the pattern and k if you do not. \nPress any key to continue.';
    % params.instructions{2} = 'Focus on the center square and do not blink too much! \nEspecially after hearing the beep. \n\nPress any key to continue.';
    % params.instructionsfocus = 'Try to stay awake! \nI know it is hard (sorry). \nYou can do it!';
    params.txt.wrap = 30;
    params.txt.fontSize = 60;
    
    % Key Response
    params.response.yes = 'j';
    params.response.no = 'k';
    
    
    %% Practice Settings
    
    params.practice.feedbackDur = 1;
    params.practice.numTrials = 8;
    
    
    %% Calibration stuff
    
    params.calibrate.breakTime = 30;
    
    % One-Up One-Down Settings
    params.staircase.maxIntensity = 0.3;
    params.staircase.minIntensity = 0.001;
    params.staircase.maxTrials = 60;
    
    % Quest Settings
    params.quest.startContrast = 0.03;
    params.quest.startVariance = 3;
    params.quest.pThreshold = 0.63;   % this should correspond to 1 up and 1 down or 50% threshold
    params.quest.numTrials = 10;
    params.quest.numBlocks = 2;
    params.quest.confirmNumTrials = 10;
    params.quest.confirmMinBlocks = 2;
    params.quest.confirmMaxBlocks = 5;
    
end