function [correct response keyCode] = getResponse(isTarget, keyYes, keyNo, timeLimit,  varargin)
    % function [correct response keyCode] = getResponse(isTarget, keyYes, keyNo, timeLimit, [lastForlimit, keyEnd])
    % 
    % Input:
    %   - isTarget = was a target stimulus presented?
    %   - keyYes = participant thought there was a target stimulus?
    %   - keyNo = participant did not think there was a target stimulus?
    %   - timeLimit = time limit for checking for response
    %
    % Optional Input (should be specified in key-value pairs):
    %   --lastforlimit => true or false
    %       Should I continue checking for the whole time period (true)
    %       or stop when I get the first response (false)
    %       Default: true
    %   --keyend => Key that will kill the script
    %       Default: ESCAPE
    %   --startvals => Key values to start
    %       This should be a list as [secs keyCode]
    %       Defaults: [0 0]
    %
    % Output:
    %   - correct: was the participant correct
    %   - response: did they respond (0=no) and what was the response time (anything besides 0 indicates they had a response and the time it took)
    %
    
    KbName('UnifyKeyNames');
    
    
    %% Options
    
    lastForLimit = keyval('--lastforlimit', varargin);
    if isempty(lastForLimit), lastForLimit = true; end
    
    keyEnd = keyval('--keyend', varargin);
    if isempty(keyEnd), keyEnd = KbName('ESCAPE'); end
        
    startVals = keyval('--startvals', varargin);
    if isempty(startVals), startVals = [0 0]; end
    secs = startVals(1);
    keyCode = startVals(2);
    if keyCode == 0
        keyIsDown = 0;
    else
        keyIsDown = 1;
    end
    
    
    %% Check for Key Press
    
    % Loop through checking for keypress up to time limit of response
    if lastForLimit == true
        while GetSecs < timeLimit
            [tmpKeyIsDown tmpSecs tmpKeyCode] = KbCheck;
            if tmpKeyIsDown == 1
                keyIsDown = tmpKeyIsDown;
                secs = tmpSecs;
                keyCode = tmpKeyCode;
                %if params.eeg
                %    eegSignal(params.eegResponse);
                %end
            end
        end
    else
        while GetSecs < timeLimit && keyIsDown == 0
            [keyIsDown, secs, keyCode] = KbCheck;
        end
        %if keyIsDown ~= 0 && params.eeg ~= 0
        %    eegSignal(params.eegResponse)
        %end
    end
    
    % If no key press, wrong answer and no response
    if keyIsDown == 0
       correct = 0;
       response = 0;
    else
        if length(keyCode) ~= 1
            keyCode = find(keyCode);
        end
        
        % Check if want to quit
        if keyCode == keyEnd
            error('%s key pressed, quitting', KbName(keyEnd))
        end
        
        % Save reaction-time in response variable
        response = secs;
         
        % Target was shown
        if isTarget
            if keyCode == KbName(keyYes)
                correct = 1;
            else
                correct = 0;
            end
        % Target was not shown
        else
            if keyCode == KbName(keyNo)
                correct = 1;
            else
                correct = 0;
            end
        end
    end
