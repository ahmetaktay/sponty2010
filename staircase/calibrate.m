function [params, history] = calibrate(params, history)

    nTrial = 1;

    % Create calibration structure (keep seperate from actual task info)
    calHistory = initHistory(params, history.q);
    % load any task specific history
    if exist([params.task '_initHistory'], 'file') == 2
        calHistory = eval([params.task '_initHistory(calHistory)']);
    end
    
    % EEG Trigger
    eegSignal(params, params.eeg.calibrateStart);

    %% One-up One-down staircase
    % Use medium stair-case gap
    % -- stop when have 6 trials with 50% up+down
    % -- or stop if reach maximum number of trials
    % -- stair-case gap: 0.001
    %%% parameters
    calHistory.trial.blocks = [calHistory.trial.blocks, nTrial];
    calHistory.timing.blocks = [calHistory.timing.blocks GetSecs];
    params.staircase.change = 0.001;
    params.staircase.nTrialsCheck = 6;
    [params, calHistory, nTrial] = staircase('OneUpDown', params, calHistory, nTrial, params.taskSet.percentNonTarget/2);
    
    %% Quest Setup
    
    % take starting intensity from previous procedure
    useTrials = calHistory.trial.isTarget==1 & calHistory.trial.response~=0;
    trialIntensities = calHistory.trial.intensity(useTrials);
    qStartIntensity = mean(trialIntensities((end-5):end));
    
    % create new quest struct
    calHistory.q = QuestCreate(qStartIntensity, history.q.tGuessSd, history.q.pThreshold, history.q.beta, history.q.delta, history.q.gamma);
    
    % if old quest struct has items in it, then add on
    if isempty(history.q.intensity) == 0
        calHistory.q = qUpdate(calHistory.q, history.q.intensity, history.q.response);
    end
    
    % add trials from one up one down staircase
    calHistory.q = qUpdate(calHistory.q, calHistory.trial.intensity(useTrials), calHistory.trial.isCorrect(useTrials));
    
    
    %% Quest Trials
    
    for ii=1:params.quest.numBlocks
        blockBreak(params, params.calibrate.breakTime);
        
        calHistory.trial.blocks = [calHistory.trial.blocks, nTrial];
        calHistory.timing.blocks = [calHistory.timing.blocks GetSecs];
        
        [params, calHistory, nTrial] = staircase('Quest', params, calHistory, nTrial, params.taskSet.percentNonTarget/2);
    end
    
    blockBreak(params, params.calibrate.breakTime);
    
    
    %% Get 50% from quest and run a few test trials
    
    startBlockNum = length(calHistory.trial.blocks);
    nBlock = 1;
    toStop = false;
    while ~toStop
        % Update Intensity to 50% level
        params = changeIntensity(params, 10^QuestQuantile(calHistory.q, 0.49));
        
        % Update block info
        calHistory.trial.blocks = [calHistory.trial.blocks, nTrial];
        calHistory.timing.blocks = [calHistory.timing.blocks GetSecs];
        
        % Go through trials
        for ii=1:params.quest.confirmNumTrials
            % Present Trial
            calHistory = eval([params.task '_trial(params, calHistory, nTrial, params.taskSet.percentNonTarget/2)']);
            
            % Update Quest
            if calHistory.trial.isTarget(nTrial) == 1 && calHistory.trial.response(nTrial) ~= 0
                calHistory.q = QuestUpdate(calHistory.q, log10(calHistory.trial.intensity(nTrial)), calHistory.trial.isCorrect(nTrial));
            end
            
            % Update Trial
            nTrial = nTrial + 1;
        end
        
        % Check if we are good
        if nBlock >= params.quest.confirmMinBlocks
            meanCorrect = getMeanCorrect(calHistory, [], startBlockNum + nBlock);
            if meanCorrect < 0.75 && meanCorrect > 0.25
                toStop = true;
            end
        elseif nBlock == params.quest.confirmMaxBlocks
            toStop = true;
        end
        
        % Update Block
        nBlock = nBlock + 1;
    end

    
    
    
    % EEG Trigger
    eegSignal(params, params.eeg.calibrateEnd);
    
    %% Save 
    
    % Calibration
    history.calibration = calHistory;
    history.q = calHistory.q;
    
    % New 50% intensity level
    params = changeIntensity(params, 10^QuestQuantile(calHistory.q, 0.49));
    
end
