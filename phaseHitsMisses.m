function [itc allItc times freqs] = phaseHitsMisses(chan, freqs, ALLEEG, tosave, subjectID, protocolID, rmerp, baseline, itcmax, basedir, plotTitle, plotphaseonly, plotphasesign)
    % function [itc bootitc times freqs] = phaseHitsMisses(chan, freqs, ALLEEG, tosave, subjectID, protocolID, rmerp, baseline, itcmax, basedir, plotTitle, plotphaseonly, plotphasesign)
    %
    % Performs time-frequency analysis
    % This function makes the assumption that there are 2 elements in the ALLEEG structure
    % it will subtract the ersp time-frequncy between those 2 elements
    %
    % Inputs
    % - chan: Electrode channel, might be between 3-33 (required)
    % - freqs: Range of frequencies (e.g. [0 100], required)
    % - ALLEEG: Data structure of EEG data in eeglab format (optional)
    % - tosave: Save plots (true or false, default: false)
    % - subjectID: ID of subject to process (optional but required if ALLEEG is empty)
    % - protocolID
    % - rmerp: Should the mean response (erp) be removed before time-frequency
    %   ('on' or 'off', default: 'off')
    % - baseline: Time period to use as baseline (0=all prestimulus and NaN=don't do, default=0)
    % - itcmax: The ITC magnitude for color scale of plot (default=auto)
    % - basedir: Base directory of project (default='/mnt/nfs/psych1/sponty01')
    % - plottitle: Title of plots (if have more than one, then must be a cell array)
    %
    
    %% Set default input arguments
    
    if nargin < 13
        plotphasesign = 'off';
    end
    
    if nargin < 12
        plotphaseonly = 'off';
    end
    
    if nargin < 11
        plotTitle = {'Hits', 'Misses', 'Hits>Misses'};
    end
    
    if nargin < 10
        basedir = '/mnt/nfs/psych1/sponty01';
    end
    
    if nargin < 9
        itcmax = [];
    end
    
    if nargin < 8
        baseline = 0;
    end
    
    if nargin < 7
        rmerp = 'off';
    end
    if isempty(rmerp)
        rmerp = 'off';
    end
    
    if nargin < 4
        tosave = false;
    end
    if isempty(tosave)
        tosave = false;
    end
    
    if isempty(struct2cell(ALLEEG))
        [ALLEEG EEG CURRENTSET basedir] = loadSubjectData(subjectID, protocolID, struct(), false, basedir);
    end
    
    for ii=1:length(plotTitle);
        plotTitle{ii} = sprintf('%s : %s', ALLEEG(1).chanlocs(chan).labels, plotTitle{ii});
    end
    plotTitle = cell(plotTitle);
    
    scrsz = get(0,'ScreenSize');
    
    %% Removing average erp (not doing this in eeglab since using this option with difference gives errors)
    
    if strcmp(rmerp, 'on')
        disp('Removing average erp response');
        for ii=1:length(ALLEEG);
            avg = repmat(squeeze(ALLEEG(ii).avg(chan,:)), ALLEEG(ii).trials, 1);
            ALLEEG(ii).data(chan,:,:) = squeeze(ALLEEG(ii).data(chan,:,:)) - avg';
        end
    end
    
    %% Setup
    EEG = ALLEEG(1);    
    if length(ALLEEG) == 1
        plotEEG = plotEEG{1};
    else
        plotEEG = {ALLEEG(1).data(chan,:,:), ALLEEG(2).data(chan,:,:)};
    end
    
    %% Compute time-frequency and plot
    disp('Computing time-frequency and plotting');
    h1 = figure();
    [ersp, itc] = newtimef(plotEEG, EEG.pnts, [EEG.xmin EEG.xmax]*1000,  ...
        EEG.srate, [3 0.5], 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
        'baseline', baseline, 'plotersp', 'off', 'plotphaseonly', plotphaseonly, 'itcmax', itcmax, ...
        'title', plotTitle, 'newfig', 'off', 'plotphasesign', plotphasesign);
    set(h1, 'Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);
    
    %% Compute significance of time-frequency and plot (using bootstrapping)
    disp('Computing time-frequency significance and plotting');
    h2 = figure();
    [garbageErsp, garbageItc, powbase, times, freqs, bootersp, bootitc] = ...
    newtimef(plotEEG, EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate,  ...
        [3 0.5], 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
        'baseline', baseline, 'plotersp', 'off', 'plotphaseonly', plotphaseonly, 'alpha', 0.05, ...
        'itcmax', itcmax, 'title', plotTitle, 'newfig', 'off', 'plotphasesign', plotphasesign);
    set(h2, 'Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);
    
    %% Compute ITC for all phases
    EEG = pop_mergeset(ALLEEG, [1 2], 0);
    [allErsp, allItc] = newtimef(EEG.data(chan,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000,  ...
        EEG.srate, [3 0.5], 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
        'baseline', baseline, 'plotersp', 'off', 'plotitc', 'off', 'newfig', 'off');
    
    %% Save plots
    if tosave
        set(h1, 'PaperUnits', 'inches');
        set(h1, 'PaperSize', [11 5]);
        set(h1, 'PaperPositionMode', 'manual');
        set(h1, 'PaperPosition', [0.5 0.5 11 4]);
        set(h1, 'renderer', 'painters');
        print(h1, '-depsc2',  sprintf('%s/analysis/figures/time_freq_phase/tfpa_prot%02i_chan%02i_sub%03i.eps', basedir, protocolID, chan, subjectID));
        
        set(h2, 'PaperUnits', 'inches');
        set(h2, 'PaperSize', [11 5]);
        set(h2, 'PaperPositionMode', 'manual');
        set(h2, 'PaperPosition', [0.5 0.5 11 4]);
        set(h2, 'renderer', 'painters');
        print(h2, '-depsc2',  sprintf('%s/analysis/figures/time_freq_phase/tfpa_boot_prot%02i_chan%02i_sub%03i.eps', basedir, protocolID, chan, subjectID));
    end
    
