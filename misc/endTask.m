function endTask(params, history, varargin)
% function endTask(params, varargin)
%
% INPUT
%   - params : structure with config settings, etc
%   - history : study information
%
% Optional INPUT should be specified in key-value pairs
%   - '--save' => true (1) or false (0)
%       Do you want to save the program history to a file
%       Default:
%           - if params.isPractice is set then it will
%           use that as the default
%           - otherwise default is 1 or true or to save
%

    if nargin < 2
        help endTask;
        error('You must give at least two arguments');
    end
    
    toSave = keyval('--save', varargin);
    if isempty(toSave),
        if isfield(params, 'isPractice') && ~isempty(params.isPractice)
            toSave = ~params.isPractice;
        else
            toSave = true;
        end
    end
    
    % Get screen back to normal
    Screen('CloseAll');
    ShowCursor;
    
    % Flush key strokes
    FlushEvents('keyDown');
    
    % Deal with eeg
    if isfield(params, 'is_eeg') && params.is_eeg
       eegSignal(params, params.eeg.stop);
    end

    % SAVE TODO: only save if this is not practice
    % TODO
    if toSave
        if params.subjectID ~= 0
            timenow = fix(clock);
            fileName = [ ...
                params.basepath, filesep, 'data', filesep, params.task, filesep, params.task '_behav_', ...
                sprintf('%03i', params.subjectID), '_', num2str(params.sessionID), ...
                '_', num2str(timenow(1)), '-', num2str(timenow(3), '%02i'), '-', num2str(timenow(2), '%02i'), '_', num2str(timenow(4), '%02i'), '-', num2str(timenow(5), '%02i')];
            save(fileName, 'history', 'params');  
        end  
    end
    