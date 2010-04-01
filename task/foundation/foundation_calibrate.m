function history = foundation_calibrate(params, history)

    nTrial = 1;

    % Create calibration structure (keep seperate from actual task info)
    calHistory = initHistory(params, history.q);

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
        blockBreak(params, params.timing.breakTime);
        
        calHistory.trial.blocks = [calHistory.trial.blocks, nTrial];
        calHistory.timing.blocks = [calHistory.timing.blocks GetSecs];
        
        [params, calHistory, nTrial] = staircase('Quest', params, calHistory, nTrial, params.taskSet.percentNonTarget/2);
    end
    
    history.calibration = calHistory;
    history.q = calHistory.q;
end
