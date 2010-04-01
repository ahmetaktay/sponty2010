function [params, history] = checkOneUpDown(params, history, nTrial, adjustThresh)
    % history=checkOneUpDown(params, history, nTrial)
    % will change threshold down if right or up if wrong
    
    if nargin < 4
       adjustThresh = true;
    end
    
    % Defaults
    isReversal = 0;
    isUp = 0;
    isDown = 0;
    intensity = params.stimSet.intensity;
    
    % There was a target so maybe move threshold up or down
    if history.trial.isTarget(nTrial)
        isReversal = 1;
        % Correct - Move Down Threshold
        if history.trial.isCorrect(nTrial)
            isDown = 1;
            intensity = intensity - params.staircase.change;
        % Incorrect - Move Up Threshold
        else
            isUp = 1;
            intensity = intensity + params.staircase.change;
        end
    end

    % Set history
    history.staircase.isReversal = [history.staircase.isReversal isReversal];
    history.staircase.isUp = [history.staircase.isUp isUp];
    history.staircase.isDown = [history.staircase.isDown isDown];
    
    % Change threshold
    if adjustThresh
        params = changeIntensity(params, intensity);
    end
