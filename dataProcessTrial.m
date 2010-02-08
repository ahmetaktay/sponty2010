function dataProcessTrial(subjectID, protocolID, loadeeglab)
% function dataProcessTrial(subjectID, protocolID, loadeeglab)
    if nargin < 3
        loadeeglab=true;
    end
    if nargin < 2
        protocolID=11;
    end
    binmode = false;
    if protocolID == 21
        binmode = true;
    end
   fprintf('running for subject %03i, protocol %02i\n', subjectID, protocolID);
   
    
    % Go into directory
    oldpath = cd('/mnt/nfs/psych1/sponty01');
    
    % add scripts to path
    addpath('/mnt/nfs/psych1/sponty01/stimuli');
    addpath('/mnt/nfs/psych1/sponty01/scripts');
    addpath('/mnt/nfs/programs/eeglab/eeglab7_1_4_16b');
    addpath('/mnt/nfs/programs/hnlMatlabTools/alpha/hnltools');
    
    % making subject directory
    subdir = sprintf('data/s%03i', subjectID);
    disp('DATAPROCESS: Creating subject directory');
    mkdir(subdir);
    
    % copy over data
    disp('DATAPROCESS: Copying over data');
    infile = dir(sprintf('raw/behavior/subject%03i_sponty_task_behavior.mat', subjectID));
    copyfile(sprintf('raw/behavior/%s', infile.name), sprintf('data/s%03i/behavioral_data.mat', subjectID));
    copyfile(sprintf('raw/eeg/subject%03i_sponty_task_FIX.EEG', subjectID), sprintf('data/s%03i/raw.EEG', subjectID));
    
    % go into subject directory
    cd(sprintf('data/s%03i', subjectID));
    
    % create new codes
    disp('DATAPROCESS: Creating new code file');
    if binmode
        mipRecodeTrialBins('raw.EEG', 'new_codes_trial.rcd');
    else
        mipRecodeTrial('raw.EEG', 'new_codes_trial.rcd');
    end
    
    % get average EEG epoch signal
    protocoldir = sprintf('protocol%02i', protocolID);
    mkdir(protocoldir);
    cd(protocoldir);
    disp('DATAPROCESS: Running mipavg3');
    %mipavg3('../raw.EEG', sprintf('../../../scripts/config/protocol_%02i.arf', protocolID), sprintf('../../../scripts/config/protocol_%02i.sgc',protocolID), ...
    %    'mipped.avg', 'mipped.log', '../../../scripts/config/Cap34_ChinRef.mon', '../new_codes.rcd', ...
    %    '-ra', sprintf('-psub%03i', subjectID), '-v');
    mipavg3v2('../raw.EEG', ...
        sprintf('../../../scripts/config/protocol_%02i.arf', protocolID), ...
        sprintf('../../../scripts/config/protocol_%02i.sgc',protocolID), ...
        'mipped.avg', 'mipped.log', '../../../scripts/config/Cap34_ChinRef.mon', '../new_codes_trial.rcd', ...
        sprintf('-ssub%03i', subjectID), '-v');
    fprintf('arf output for subject%03i\n', subjectID);
    !tail -n 4 mipped.log
    
    %% convert files into eeglab
    %disp('DATAPROCESS: Converting to eeglab format');
    %if loadeeglab
    %    eeglab;
    %end
    %hnl_export_to_eeglab(sprintf('sub%03i_erpin_Hit_code001.mat', subjectID), 'eeglab_hit.set', 'cap34');
    %hnl_export_to_eeglab(sprintf('sub%03i_erpin_Miss_code002.mat', subjectID), 'eeglab_miss.set', 'cap34');
    %hnl_export_to_eeglab(sprintf('sub%03i_erpin_CorrectReject_code003.mat', subjectID), 'eeglab_correctreject.set', 'cap34');
    
    % go back to previous directory
    cd(oldpath);
    