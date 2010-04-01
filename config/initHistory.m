function history = initHistory(params, q)
    
    %% Trial related details
    history.trial = [];
    history.trial.nTrials = 0;
    history.trial.intensity = [];
    history.trial.isTarget = [];
    history.trial.isCorrect = [];
    history.trial.response = [];
    history.trial.rxntime = [];
    history.trial.blocks = [];
    history.trial.blocksRedoIntensity = [];
    
    %% Staircase history
    history.staircase = [];
    history.staircase.isUp = [];
    history.staircase.isDown = [];
    history.staircase.isReversal = [];
    
    %% Timing info
    history.timing = [];
    % study
    history.timing.startStudy = 0;
    history.timing.endStudy = 0;
    history.timing.durationStudy = 0;
    % block
    history.timing.blocks = [];
    % trial
    history.timing.ITI = [];
    history.timing.startStimulus = [];
    history.timing.stimulusDuration = [];
    history.timing.startTrial = [];
    history.timing.endTrial = [];
    history.timing.trialDuration = [];
    % eeg : section below used for diagnostic purposes...commented out for now
    %history.timing.eegSignalStart = [];
    %history.timing.eegSignalEnd = [];
    
    %% Quest settings
    if nargin < 2
        tGuess = log10(params.quest.startContrast);
        tGuessSd = params.quest.startVariance;
        beta = 3.5; delta = 0.01; gamma = 0;
        history.q = QuestCreate(tGuess, tGuessSd, params.quest.pThreshold, beta, delta, gamma);
        history.q.normalizePdf = 1;
    else
        history.q = q;
    end
