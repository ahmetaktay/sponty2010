function params = getUserParams(params)
% function params = getUserParams(params)
%
% User set paramaters
%

    fprintf('--------\n');
    fprintf('SETTING USER PARAMETERS\n\n');

    %% Get the task
    % note that additional settings can be set in the task
    
    % Will look in the task folder for different options
    taskdirs = dir(fullfile(params.basepath, 'task'));
    taskdirs = taskdirs(3:end);
    options = cell(1,length(taskdirs));
    for ii=1:length(taskdirs);
        if taskdirs(ii).isdir
           options{ii} = taskdirs(ii).name; 
        end
    end
    
    % and give user the option to choose
    choice = menu('Choose a task', options);
    
    % save the path to task directory & add to path
    t = options(choice);
    params.task = t{1};
    params.taskDir = fullfile(params.basepath, 'task', params.task);
    addpath(params.taskDir);
    fprintf('Task: %s\n', params.task);
    
    %% Is this practice?
    
    choice = questdlg('Is this a practice run?', 'Practice', 'Yes', 'No', 'No');
    fprintf('Practice: ');
    
    switch choice
        case 'Yes'
            fprintf('YES\n');
            params.isPractice = 1;
        case 'No'
            fprintf('NO\n');
            params.isPractice = 0;
    end
    
    
    %% Set response keys (TODO: MOVE TO SPECIFIC SCRIPTS)
    % (allow to switch keys for left handers)
    
    choice = questdlg('Do you want to use the left-handed response keys (f and d)?', 'Left Hander', 'Yes', 'No', 'No');
    
    switch choice
        case 'Yes'
            fprintf('Setting response keys to f=yes and d=no\n');
            params.response.yes = 'f';
            params.response.no = 'd';
    end
    
    
    %% Subject and Session ID
    
    name = 'ID Info';
    prompt = {'What is the subject ID (input 0 to not save response data)?', 'What is the session number?'};
    numlines = 1;
    defaultanswer = {'0', '1'};
    answer = inputdlg(prompt, name, numlines, defaultanswer);
    
    params.subjectID = str2double(answer{1});
    fprintf('Subject ID: %s\n', params.subjectID);
    params.sessionID = str2double(answer{2});
    fprintf('Session ID: %i\n', params.sessionID);
        
    
    %% EEG experiment
    
    choice = questdlg('Is this an EEG experiment (default is Yes)?', 'EEG', 'Yes', 'No', 'Yes');
    fprintf('EEG Experiment: ');
    
    switch choice
        case 'Yes'
            fprintf('YES\n');
            params.is_eeg = true;
        case 'No'
            fprintf('NO\n');
            params.is_eeg = false;
    end
    
    % setup eeg trigger
    if params.is_eeg
        params.dio = digitalio('nidaq', 1);
        addline(params.dio, 0:7, 'out');
        putvalue(params.dio, 0);
    end
    
    
    fprintf('--------\n');

end

