function history = spontyMain(q)
% spontyMain.m
%
% function [history, params] = spontyMain(q)
%
% Will run the sponty task
%
% Optional INPUT:
%   - q : quest structure
%
% OUTPUT
%   - history : object with presentation timing and response info
%

% TODO:
% 1. Create seperate main instructions and seperate instructions for each block
% 2. 
    
    % Remove any open windows
    close all;
    
    % Set DebugLevel to 3:
    Screen('Preference', 'VisualDebuglevel', 3);
    
    % Add relevant paths
    addpath('config', 'misc', 'staircase', 'stimuli');
    
    try 
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
        % Initialize history (= object that stores stimuli-timing/response info)
        if nargin < 1
            history = initHistory(params);
        else
            history = initHistory(params, q);
        end
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
        
        %% Call task
        if params.isPractice
            history = practice(params, history);
        else
            % start
            history.timing.startStudy = GetSecs;
            history = eval([params.task '(params, history);']);
            % end
            history.timing.endStudy = GetSecs;
            history.timing.durationStudy = (history.timing.endStudy - history.timing.startStudy)/60;
        end
        
        %% End things
        textScreen(params, 'You are all done!', '--waitforkey', false, '--waitsecs', 5);
        endTask(params, history, '--save', true);
    catch
        %% Whoops, something went terribly wrong
        
        % End things
        history.error = 'yes';
        endTask(params, history, '--save', true);
        
        % Give error
        psychrethrow(psychlasterror);
    end
