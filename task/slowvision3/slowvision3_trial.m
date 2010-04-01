function history = slowvision3_trial(params, history, nTrial, percentNoTarget, isTarget, intensity)
% function history = slowvision3_trial(params, history, nTrial, percentNoTarget, [isTarget, intensity])
    
    if nargin < 3
        help slowvision2_trial;
        error('slowvision2_trial requires at least 3 inputs: params, history, nTrial.')
    % Set percentage non-target stimuli
    end
    
    if nargin < 4
       percentNoTarget = 0; 
    % Determine whether to show a target in this trial, record as you go
    end
    
    if nargin < 5
        isTarget = rand > percentNoTarget;
    end
    
    if nargin < 6
        intensity = params.stimSet.intensity;
    end
    
    
    %% Intertrial Interval
    
    % Set stuff
    history.trial.isTarget = [history.trial.isTarget isTarget];
    history.trial.intensity = [history.trial.intensity intensity];
    
    % Fixation
    Screen('DrawTexture', params.wPtr, params.stim.fixation);
    showTime = Screen('Flip', params.wPtr);
    
    % Get timing difference since end of last trial to now
    if nTrial > 1
        elapsedTime = max(showTime - history.timing.endTrial(nTrial-1), 0);
    else
        elapsedTime = 0;
    end
    
    % Prepare stimulus for next trial
    if isTarget == 1
        % Create the contrast adjusted stimulus
        stim = adjustStim(params, intensity);
        t = Screen('MakeTexture', params.wPtr, stim, 0, 0, 1);
    end
    
    % Prepare display stimulus if target and prepare eeg code
    if isTarget==1
        Screen('DrawTexture', params.wPtr, t);
        eegCode = params.eeg.target;
    else
        eegCode = params.eeg.noTarget;
    end
    % Prepare display of new fixation
    Screen('DrawTexture', params.wPtr, params.stim.fixation);
    
    % Jitter intertrial interval
    interTrialInterval = Sample(params.timing.intertrialSet);
    history.timing.ITI = [history.timing.ITI interTrialInterval];    
    
    % Wait
    WaitSecs(interTrialInterval - (GetSecs - showTime) - elapsedTime);
        
    % Deal with EEG
    if params.is_eeg
        putvalue(params.dio, eegCode);
    end
    
    % Present stimulus
    startStimulusTime = Screen('Flip', params.wPtr);
    
    % Put back only grey background + the fixation
    if isTarget==1
        Screen('Close', t);
    end
    Screen('FillRect', params.wPtr, params.disp.white*params.disp.bgContrast);
    Screen('DrawTexture', params.wPtr, params.stim.fixation);
    endStimulusTime = Screen('Flip', params.wPtr, startStimulusTime + params.timing.stimulusDuration);
    %%% fix for when intensity is actually zero
    if params.stimSet.intensity == 0
        isTarget = 0;
    end
    
    % Deal with EEG
    if params.is_eeg
        putvalue(params.dio, 0);
    end
    
    % Get Response
    [thisCorrect, thisResponseTime, keyCode] = getResponse(isTarget, params.response.yes, params.response.no, endStimulusTime+params.timing.responseTime);
    endTrialTime = GetSecs;
    
    % old stuff done here
    history.timing.startStimulus = [history.timing.startStimulus, startStimulusTime];
    history.timing.stimulusDuration = [history.timing.stimulusDuration endStimulusTime-startStimulusTime];
    
    % End of Trial
    history.timing.startTrial = [history.timing.startTrial, startStimulusTime];
    history.timing.endTrial = [history.timing.endTrial endTrialTime];
    history.timing.trialDuration = [history.timing.trialDuration, endTrialTime-startStimulusTime];
    
    if nTrial > 1
        history.timing.actualITI = [history.timing.actualITI, max(startStimulusTime-history.timing.endTrial(nTrial-1), 0)];
    else
        history.timing.actualITI = 0;
    end
    
    % Randomise thisCorrect
    thisCorrect = Sample([0 1]);
    
    % Code Response (correct and rxn-time)
    history.trial.isCorrect = [history.trial.isCorrect thisCorrect];
    if thisResponseTime == 0
        % note that a no response is equivalent to a wrong answer here
        history.trial.response = [history.trial.response, 1];
        history.trial.rxntime = [history.trial.rxntime, 0];
        if params.is_eeg
            eegCode = params.eeg.incorrect;
        end
    else
        if thisCorrect
            history.trial.response = [history.trial.response keyCode];
            history.trial.rxntime = [history.trial.rxntime thisResponseTime-startStimulusTime];
            eegCode = params.eeg.correct;
        else
            % something went wrong here!
            history.trial.response = [history.trial.response 0];
            history.trial.rxntime = [history.trial.rxntime thisResponseTime-startStimulusTime];
            eegCode = params.eeg.noResponse;
        end
    end
    
    % EEG Trigger
    eegSignal(params, eegCode);


    printDiag(history);
end
