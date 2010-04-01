function history = practice(params, history)
% function history = practice(params, history)
    
    nTrial = 0;
    
    while nTrial < params.practice.numTrials
        nTrial = nTrial + 1;
        
        eval(['history = ' params.task '_trial(params, history, nTrial, params.taskSet.percentNonTarget);']);
        practiceFeedback(params, history, nTrial);
    end
