function params = foundation_getParams(params)
% function params = foundation_getParams(params)
    
    % Stimuli Settings
    params.stimSet.intensity = 0.03;
    params.stimSet.radius = 200;    % in pixels
    params.stimSet.outerRadius = 140;   % in pixels
    params.stimSet.outerFixationSize = 10; % in pixels
    params.stimSet.innerFixationSize = 4; % in pixels
    params.stimSet.pixelsPerPeriod = 33; % How many pixels will each period/cycle occupy?
    
    % Actual Stimuli
    %%% if have auditory cue
    params.stim.beep = 0.5 * tukeywin(199,10) .* transpose(sin(1:0.5:100));
    
    % Stimuli Timing Settings
    params.timing.ITI = 1.5; % average number of seconds to wait till start of next trial
    params.timing.ITIjitterRange = 0.25; % range in seconds
    params.timing.stimulusDuration = 0.007;  % seconds
    params.timing.endTime = 3; % number of seconds to wait from start of trial to end trial and ask participant their response
    params.timing.responseTime = 2;  % seconds given to respond
    params.timing.breakTime = 10; % minimum number of seconds between blocks as break
    %%% if have auditory cue
    params.timing.firstTone = 0.1; % seconds before stimulus onset that tone is presented
    params.timing.cueDuration = 0.1; % seconds that auditory cue is presented
    params.timing.startTime = 1.0;  % wait on average this many seconds before showing stimulus
    % params.startJitterRange = 0.5; % +/- number of seconds to jitter starting of stimulus
    params.timing.startJitterSet = [0.2 0.4 0.6 0.8 1.0]; % set of +/- number of seccond of jitter to pick randomly from
    
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