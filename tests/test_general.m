
try
    test_base
    
    PsychJavaTrouble

    %% Params
    % Get parameters for the experiment
    params = getParams;
    params = getUserParams(params);
    params = getDisplayParams(params);
    % load any task specific params
    if exist([params.task '_getParams'], 'file') == 2
        params = eval([params.task '_getParams(params)']);
    end
    
    %% History
    % Initialize history (= object that stores stimuli-timing/response
    % info)
    history = initHistory(params);
    % load any task specific history
    if exist([params.task '_initHistory'], 'file') == 2
        history = eval([params.task '_initHistory(history)']);
    end
    
    %% Prepare Screen
    % Start with a ready screen
    textScreen(params, 'Ready?', '--waitforkey', true, '--waitsecs', 1);
    % Give instructions
    textScreen(params, params.instructions{1}, '--waitforkey', true, '--waitsecs', 1);
    
    %% EEG
    % Initialize EEG
    eegSignal(params, 0);
    eegSignal(params, params.eeg.start);
    
    if params.isPractice
        history = practice(params, history);
    else
        [params, history] = calibrate(params, history);
    end

    endTask(params, '--save', false);
catch
    % Get screen back to normal
    Screen('CloseAll');
    ShowCursor;
    
    psychrethrow(psychlasterror);
    
end