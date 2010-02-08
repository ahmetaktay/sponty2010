function [ersp, itc, pbi, bootersp, bootitc] = differenceHitsMisses(chan, ALLEEG, ...
    subjectID, protocolID, plotitc, erspmax, basedir)
    % function [ersp, itc, pbi, bootersp, bootitc] = differenceHitsMisses(chan, ALLEEG, subjectID, protocolID, [basedir])
    % Time-frequency analysis
    % This function makes the assumption that there are two elements in the ALLEEG structure
    % it will subtract the ersp and itc time-frequency 
    % pbi: phase bifurcation index (ITChits - ITCall) * (ITCmisses - ITCall)
    
    if nargin < 5
        plotitc = 'on';
    end
    
    if nargin < 6
        erspmax = [];
    end
    
    if nargin < 7
        basedir = '/mnt/nfs/psych1/sponty01';
    end

    if isempty(struct2cell(ALLEEG))
        % Fetch participant data
        [ALLEEG EEG CURRENTSET basedir] = loadSubjectData(subjectID, protocolID, struct(), false, basedir);
    end
    
    scrsz = get(0,'ScreenSize');
    
    %% Compare time-frequency plots
    h = figure();
    EEG = ALLEEG(1);
    [ersp, itc, mbase, timesout, freqs, bootEsrp, bootItc, alltfX2] = newtimef({ALLEEG(1).data(chan,:,:), ALLEEG(2).data(chan,:,:)},EEG.pnts, ...
        [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 0.5], 'topovec', chan, ...
        'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'baseline', 0, ...
        'plotphase', 'on', 'padratio', 1, 'plotitc', plotitc, 'erspmax', erspmax);
    set(h+1, 'Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);
    saveas(h+1, sprintf('%s/analysis/figures/time_freq_chan%02i_sub%02i_prot%02i.eps', basedir, chan, subjectID, protocolID), 'psc2');
    
    %% Comput PBI
    
    % Create combined trials (for ITC)
    EEG = pop_mergeset(ALLEEG, [1 2], 0);

    % Calculate all trials together
    eegRange = [EEG.xmin EEG.xmax]*1000;
    figure();
    [allErsp, allItc] = pop_newtimef(EEG, 1, chan, eegRange, [3 0.5] , 'topovec', chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'baseline', 0, 'plotphase', 'off', 'padratio', 1);
    
    % Phase bifurcation index
    pbi = (abs(itc{1}) - abs(allItc)) .* (abs(itc{2}) - abs(allItc));
 
    ersp{4} = allErsp;
    itc{4} = allItc;
    
    % Plot pbi
    %plottimef(pbi, [], [], [], [], freqs, timesout, mbase, maskersp, maskitc, g);
    
    %% Bootstrap time-frequency plots
    [bootersp bootitc] = newtimef({ALLEEG(1).data(chan,:,:), ALLEEG(2).data(chan,:,:)},EEG.pnts, ...
    [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 0.5], 'topovec', chan, ...
        'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'baseline', 0, ...
        'plotphase', 'on', 'padratio', 1, 'alpha', 0.05, 'plotitc', plotitc, 'erspmax', erspmax);
    set(h+3, 'Position',[1 scrsz(4)/2 scrsz(3) scrsz(4)/2]);
    saveas(h+3, sprintf('%s/analysis/figures/boot_time_freq_chan%02i_sub%02i_prot%02i.eps', basedir, chan, subjectID, protocolID), 'psc2');
    
