
function [ALLEEG, EEG, CURRENTSET, basedir] = loadSubjectData(subjectID, protocolID, ...
    ALLEEG, loadeeglab, basedir)
    % Load hits and misses for one participant
    % function [ALLEEG, EEG, CURRENTSET, basedir] = loadSubjectData(subjectID, protocolID, [ALLEEG], [loadeeglab], [basedir])
    
    % Default values
    if nargin < 5 || isempty(basedir)
        basedir='/mnt/nfs/psych1/sponty01';
    end
    if nargin < 4
        loadeeglab=true;
    end
    if nargin < 3
        ALLEEG = struct();
    end
    hitfile=sprintf('sub%03i_Hit_code001.set', subjectID);
    missfile=sprintf('sub%03i_Miss_code002.set', subjectID);
    
    % Set current eeg element
    if isempty(struct2cell(ALLEEG))
        CURRENTSET = 1;
    else
        CURRENTSET = size(ALLEEG, 2) + 1;
    end
    
    % Load eeglab
    if loadeeglab
        add_eeglab;
        addpathsEEGLAB;
    end
    
    % Create different directory paths
    scriptsdir=sprintf('%s/scripts', basedir);
    stimulidir=sprintf('%s/stimuli', basedir);
    datadir=sprintf('%s/data', basedir);
    protocoldir=sprintf('%s/s%03i/protocol%02i', datadir, subjectID, protocolID);    
    fprintf('running for subject %03i, protocol %02i', subjectID, protocolID);
    
    % Load hits
    EEG = pop_loadset('filename', hitfile, 'filepath', protocoldir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
    
    % Load misses
    EEG = pop_loadset('filename', missfile, 'filepath', protocoldir);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET+1);
    
end
