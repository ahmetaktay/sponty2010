function params = slowvision3_getParams(params)
% function params = slowvision3_getParams(params)
    
    params.taskSet.numBlocks = 2;
    params.taskSet.numBlockSections = 1;
    params.taskSet.numTrialsPerSection = 10;
    
    % Instructions/Text
    params.instructions = {};
    params.instructions{1} = 'Focus on the square in the center for the whole time. \nPress j if you see a pattern and k if you do not. \nPress any key to continue.';
    %params.instructions{2} = 'Remember to focus on the center square and try not to blink too much! \n\nPress any key to continue.';
    
    
    % Stimuli Settings
    params.stimSet.intensity = 0.03;
    params.stimSet.radius = 200;    % in pixels
    params.stimSet.outerRadius = 120;   % in pixels
    params.stimSet.outerFixationSize = 10; % in pixels
    params.stimSet.innerFixationSize = 4; % in pixels
    params.stimSet.pixelsPerPeriod = 33; % How many pixels will each period/cycle occupy?
    
    % Actual Stimuli
    
    % Stimuli Timing Settings
    params.timing.intertrialSet = [0 0.5 1.0 1.5 2.0 2.5]; % range in seconds
    params.timing.stimulusDuration = 0.007;  % seconds
    params.timing.responseStartSet = [0.2]; % range in seconds
    params.timing.responseTime = 2;  % seconds given to respond
    
    params.timing.sectionBreak = 20;
    params.timing.blockBreak = 40; % minimum number of seconds between blocks as break
    
    
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