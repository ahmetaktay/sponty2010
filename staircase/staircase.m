function [params, history, nTrial] = staircase(typeStaircase, params, history, nTrial, percentNonTarget)
% function [history,nTrial] = staircase(params, history, nTrial, typeStaircase, [percentNonTarget])
    
    if nargin < 5
        percentNonTarget = params.percentNonTarget;
    end
    
    if nargin < 4
        help staircase;
        error('staircase function requires at lest 4 input arguments');
    end
    
    if strcmp(typeStaircase, 'OneUpDown')
        
        if mod(params.staircase.nTrialsCheck, 2)
            error('param.nTrialsCheck must be an even number')
        end
        
        startTrialCheck = params.staircase.nTrialsCheck + 4 + nTrial;
        maxTrials = nTrial + params.staircase.maxTrials;
        
        while nTrial < maxTrials
            history = eval([params.task '_trial(params, history, nTrial, percentNonTarget)']);
            [params, history] = checkOneUpDown(params, history, nTrial);
            if nTrial > startTrialCheck
                useTrials = history.trial.isTarget==1 & history.trial.response~=0;
                upTrials = history.staircase.isUp(useTrials);
                if (params.staircase.nTrialsCheck-1)<length(upTrials)
                    percentUp = mean(upTrials(end-(params.staircase.nTrialsCheck-1):end));
                    if percentUp == 0.5
                        nTrial = nTrial + 1;
                        break
                    end 
                end
            end
            nTrial = nTrial + 1;
        end
    elseif strcmp(typeStaircase, 'Quest')
        
        % Set the number of trials to test
        qTrials = nTrial + params.quest.numTrials;
        maxTrials = qTrials * 2; % this is because qTrials is updated if there is a no response
        
        while nTrial < qTrials && nTrial < maxTrials
            % Do trial
            history = eval([params.task '_trial(params, history, nTrial, percentNonTarget)']);
            % Update Quest
            if history.trial.isTarget(nTrial) && history.trial.response(nTrial) ~= 0
                history.q = QuestUpdate(history.q, log10(history.trial.intensity(nTrial)), history.trial.isCorrect(nTrial));
                trialTheta = QuestQuantile(history.q);
                params = changeIntensity(params, 10^trialTheta);
            elseif history.trial.response(nTrial) == 0
                % Do more trials if a no response
                qTrials = qTrials + 1;
            end
            % Update number of trials
            nTrial = nTrial + 1;
        end
    end
