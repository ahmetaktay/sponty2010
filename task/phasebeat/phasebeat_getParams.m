function params = phasebeat_getParams(params)
% function params = slowvision3_getParams(params)
    
    params.taskSet.numBlocks = 1;
    params.taskSet.numBlockSections = 5;
    params.taskSet.numTrialsPerSection = 50;
    params.taskSet.percentNonTarget = 0.2;
    % Instructions/Text
    params.instructions = {};
    params.instructions{1} = 'Focus on the square in the center for the whole time. \nPress j if you see a pattern and k if you do not. \nPress any key to continue.';
    %params.instructions{2} = 'Remember to focus on the center square and try not to blink too much! \n\nPress any key to continue.';
    
	% specialized EEG signals
    params.eeg.target_short = 111;
	params.eeg.target_long = 121;
	params.eeg.target_control = 101;
	params.eeg.noTarget_control = 102;
    params.eeg.noTarget_short = 112;
	params.eeg.noTarget_long = 122;
    % params.eeg.correct_control = 31;
    % params.eeg.incorrect_control = 32;
    params.eeg.noResponse = 33;

    
    % Stimuli Settings
    params.stimSet.intensity = 0.028;
    params.stimSet.radius = 200;    % in pixels
    params.stimSet.outerRadius = 120;   % in pixels
    params.stimSet.outerFixationSize = 10; % in pixels
    params.stimSet.innerFixationSize = 4; % in pixels
    params.stimSet.pixelsPerPeriod = 33; % How many pixels will each period/cycle occupy?
    
    % Actual Stimuli
    
    % Stimuli Timing Settings
    params.timing.intertrialSet = [2.05 2.0 1.95]; % range in seconds. largest becomes long, shortest becomes short, anything else is control
    params.timing.stimulusDuration = 0.007;  % seconds. .007 will hopefully display exactly one refresh rate
	params.timing.trialDuration = 2.2; % seconds of fixation period (total until qmark, including stimulus showing up & after)
    params.timing.responseTime = 2;  % seconds given to respond (after which ? disappears and trial ends)
    
    params.timing.sectionBreak = 30; % seconds with + on the screen for participant to rest
    params.timing.blockBreak = 30; % minimum number of seconds between blocks as break
    
    
    %% Create Stimuli
    
    % Create the main parts of the stimulus
    [params.stim.gratings params.stim.annulus params.stim.fixationRect] = makeStim(params);
    
    % Get fixation
    params.stimSet.fixDim = [params.disp.x0-params.stimSet.outerFixationSize/2, params.disp.y0-params.stimSet.outerFixationSize/2, ...
        params.disp.x0+params.stimSet.outerFixationSize/2, params.disp.y0+params.stimSet.outerFixationSize/2];
    
    params.stim.fixation = Screen('MakeTexture', params.wPtr, params.stim.fixationRect*params.disp.white, 0, 0, 1);
    
    % Get stimulus dimensions
    params.stim.stimDim = [params.disp.x0-params.stimSet.radius, params.disp.y0-params.stimSet.radius,  ...
        params.disp.x0+params.stimSet.radius, params.disp.y0+params.stimSet.radius];

end