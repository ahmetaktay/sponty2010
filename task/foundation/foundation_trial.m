function history = foundation_trial(params, history, nTrial, percentNoTarget, isTarget, intensity)
% function history = foundation_trial(params, history, nTrial, percentNoTarget, [isTarget])
    
    if nargin < 3
        help foundation_trial;
        error('foundation_trial requires at least 3 inputs: params, history, nTrial.')
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
        elapsedTime = max(0, showTime - history.timing.endTrial(nTrial-1));
    else
        elapsedTime = 0;
    end

    % Prepare stimulus for next trial
    if isTarget == 1
        % Create the contrast adjusted stimulus
        stim = adjustStim(params, intensity);
        t = Screen('MakeTexture', params.wPtr, stim, 0, 0, 1);
    end
    
    % Jitter intertrial interval
    jitterITI = (params.timing.ITIjitterRange * rand()) * ((2 * round(rand)) - 1);
    
    % Wait
    interTrialInterval = params.timing.ITI - (GetSecs - showTime) - elapsedTime + jitterITI;
    history.timing.ITI = [history.timing.ITI interTrialInterval];
    WaitSecs(interTrialInterval);
    
    % Deal with EEG
    eegSignal(params, params.eeg.startTrial);
    
    % Tell participant that stimulus coming
    startTrialTime = GetSecs;
    sound(params.stim.beep);
    history.timing.startTrial = [history.timing.startTrial startTrialTime];
    
    % Jitter
    jitterStart = Sample(params.timing.startJitterSet);
    
    % Prepare display stimulus if target and prepare eeg code
    if isTarget==1
        Screen('DrawTexture', params.wPtr, t);
        eegCode = params.eeg.target;
    else
        eegCode = params.eeg.noTarget;
    end
    % Prepare display of new fixation
    Screen('DrawTexture', params.wPtr, params.stim.fixation);
    
    % Deal with EEG
    if params.is_eeg
        putvalue(params.dio, eegCode);
    end
    
    % Present stimulus
    stimulusStartTime = startTrialTime + params.timing.firstTone + params.timing.startTime + jitterStart;
    startStimulusTime = Screen('Flip', params.wPtr, stimulusStartTime);
    history.timing.startStimulus = [history.timing.startStimulus startStimulusTime-startTrialTime];
    
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
    
    history.timing.stimulusDuration = [history.timing.stimulusDuration endStimulusTime-startStimulusTime];
    
    % Show question mark to indicate that a response is needed
    Screen('FillRect', params.wPtr, params.disp.white*params.disp.bgContrast);
    %%% Save old text size
    Screen(params.wPtr, 'TextFont', 'Arial');
    oldTextSize = Screen('TextSize', params.wPtr, params.txt.fontSize);
    %%% Draw text centered on screen
    DrawFormattedText(params.wPtr, WrapString('?', params.txt.wrap), 'center', 'center');
    %%% Display text
    startResponseTime = Screen('Flip', params.wPtr, startTrialTime + params.timing.endTime);
    %%% Return textsize to normal
    Screen('TextSize', params.wPtr, oldTextSize);
    
    % Get Response
    [thisCorrect thisResponseTime keyCode] = getResponse(isTarget, params.response.yes, params.response.no, startResponseTime + params.timing.responseTime, true);
    endTrialTime = GetSecs;
    
    % End of Trial
    history.timing.endTrial = [history.timing.endTrial endTrialTime];
    history.timing.trialDuration = [history.timing.trialDuration endTrialTime-startTrialTime];
    
    % Take away question mark and replace with fixation
    Screen('FillRect', params.wPtr, params.disp.white*params.disp.bgContrast);
    Screen('DrawTexture', params.wPtr, params.stim.fixation);
    Screen('Flip', params.wPtr, startTrialTime + params.timing.endTime + params.timing.responseTime);
    
    % Code Response (correct and rxn-time)
    history.trial.isCorrect = [history.trial.isCorrect thisCorrect];
    if thisResponseTime == 0
        history.trial.response = [history.trial.response 0];
        history.trial.rxntime = [history.trial.rxntime, thisResponseTime];
        if params.is_eeg
            eegCode = params.eeg.noResponse;
        end
    else
        history.trial.response = [history.trial.response keyCode];
        history.trial.rxntime = [history.trial.rxntime thisResponseTime-startResponseTime];
        if thisCorrect
            eegCode = params.eeg.correct;
        else
            eegCode = params.eeg.incorrect;
        end
    end
    
    % Deal with eeg
    eegSignal(params, eegCode);

end
