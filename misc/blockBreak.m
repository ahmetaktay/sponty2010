function blockBreak(params, breakTime)
    if nargin < 2
        breakTime = params.breakTime;
    end
    
    % Give break
    textScreen(params, 'Please Take A Break!', '--waitforkey', false, '--waitsecs', breakTime);
    
    % Create a Ready screen
    textScreen(params, 'Get Ready', '--waitforkey', false, '--waitsecs', 3);
    
    % Remind person to focus on fixation
    for ii=1:length(params.instructions)
        textScreen(params, params.instructions{ii}, '--waitforkey', true, '--waitsecs', 1);
    end
    
    % Put up the fixation and wait 3 seconds before starting
    Screen('DrawTexture', params.wPtr, params.stim.fixation);
    Screen('Flip', params.wPtr);
    WaitSecs(3);

end
