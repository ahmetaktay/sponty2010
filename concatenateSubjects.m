function [HITEEG, MISSEEG] = concatenateSubjects(subjects, protocolID, loadeeglab, basedir)
    % function [HITEEG MISSEEG] = concatenateSubjects([subjects], [protocolID], [loadeeglab], [basedir])
    
    if nargin < 4
        basedir='';
    end
    if nargin < 3 or isempty(loadeeglab)
        loadeeglab=true;
    end
    if nargin < 2 or isempty(protocolID)
        protocolID=01;
    end
    if nargin < 1 or isempty(subjects)
        subjects = [101,103,104,105,106];
    end
    
    if loadeeglab
        eeglab;
    end
    
    % Load datasets
    fprintf('Loading datasets\n');
    ALLEEG = struct();
    for ss = 1:length(subjects);
        ALLEEG = loadSubjectData(subjects(ss), protocolID, ALLEEG, false, basedir);
    end

    % Seperate hit from miss
    fprintf('Seperating hit from miss trials\n');
    totalRuns=length(subjects)*2;
    HITEEG = ALLEEG(1:2:totalRuns);
    MISSEEG = ALLEEG(2:2:totalRuns);

    % Merge hits
    fprintf('Merging hits runs\n');
    HITEEG = pop_mergeset(HITEEG, 1:length(subjects), 0);

    % Merge miss
    fprintf('Merging miss runs\n');
    MISSEEG = pop_mergeset(MISSEEG, 1:length(subjects), 0);
