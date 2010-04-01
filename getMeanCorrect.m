function [meanCorrect goodTrial] = getMeanCorrect(history, trialIndices, blockNum)
% Will find the mean number of correct responses
% can restrict by block number otherwise will get mean of everything
% Does not include non-target trials and no response trials in calculation
%
% function [meanCorrect correctTrials] = getMeanCorrect(history, [trialIndices], [blockNum])
%
% note the function will use either blockNum instead of trialIndices if
% specefied
    
    if nargin < 2
        trialIndices = 1:length(history.trial.isCorrect);
    elseif nargin == 3
        blocks = [history.trial.blocks (length(history.trial.isCorrect)+1)];
        trialIndices = blocks(blockNum):(blocks(blockNum+1)-1);
    end
    
    isTarget = history.trial.isTarget(trialIndices);
    response = history.trial.response(trialIndices);
    correct = history.trial.isCorrect(trialIndices);
    
    fprintf('Number of no responses: %i', sum(response==0));
    
    correctTrials = correct(isTarget==1 & response~=0);
    
    meanCorrect = mean(correctTrials);

    goodTrial = [];
    goodTrial.isCorrect = correctTrials;
    rxntime = history.trial.rxntime(trialIndices);
    goodTrial.rxntime = rxntime(isTarget==1 & response~=0);
    
