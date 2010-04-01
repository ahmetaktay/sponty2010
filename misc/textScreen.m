function textScreen(params, txt, varargin)
% function textScreen(params, txt, varargin)
%
% INPUT
%   - params : structure with config settings, etc
%   - txt : text to display on screen
%
% Optional INPUT should be specified in key-value pairs and can be
%   - '--waitforkey' => true (1) or false (0); default=false
%       Do you want to wait for a key press before continuing?
%   - '--waitsecs' => decimal; default=0
%       Number of seconds that you want to wait before continuing
%       note that if waitforkey is specified than this is the amt
%       time after the key press
%   - '--color' => list with [r g b] values of text color
%                  default: [0 0 0] or black
%

    % require 2 args
    if nargin < 2
        help textScreen;
        error('You must give at least two inputs to textScreen\n');
    end

    % get the options
    toWaitForKey = keyval('--waitforkey', varargin); if isempty(toWaitForKey), toWaitForKey = false; end
    waitSecs = keyval('--waitsecs', varargin); if isempty(waitSecs), waitSecs = 0; end
    txtColor = keyval('--color', varargin); if isempty(txtColor), txtColor = [0 0 0]; end
        
    % Save old text size
    Screen(params.wPtr, 'TextFont', 'Arial');
    oldTextSize = Screen('TextSize', params.wPtr, params.txt.fontSize);
    
    % Draw text centered on screen
    DrawFormattedText(params.wPtr, WrapString(txt, params.txt.wrap), 'center', 'center', txtColor);
    
    % Display text
    Screen('Flip', params.wPtr);
    
    % Return textsize to normal
    Screen('TextSize', params.wPtr, oldTextSize);
    
    % Wait for anything to continue
    if toWaitForKey
        KbWait;
        Screen('FillRect', params.wPtr, params.disp.white*params.disp.bgContrast);
        Screen('Flip', params.wPtr);
    end
    
    % Wait for a number of seconds
    if waitSecs
        WaitSecs(waitSecs);
        Screen('FillRect', params.wPtr, params.disp.white*params.disp.bgContrast);
        Screen('Flip', params.wPtr);
    end

    FlushEvents('keyDown');
    