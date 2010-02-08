function [pdiff pbi times freqs] = comparePhases(chan, subjectID, protocolID, tosave, basedir)
    % function [diff pbi] = comparePhases(chan, subjectID, protocolID, tosave)
    
    if nargin < 5
        basedir = '/mnt/nfs/psych1/sponty01';
    end
    
    if nargin < 4
        tosave = false;
    end
    
    % Compute Phase
    [itc allitc times freqs] = phaseHitsMisses(chan, [0 60], struct(), tosave, subjectID, protocolID, false, [0 100], 0.5);

    % phase difference
    hitPhase = angle(itc{1});
    missPhase = angle(itc{2});
    pdiff = (hitPhase - missPhase) * 180/pi;
    pdiff = mod(pdiff+180, 360) - 180;

    % pbi
    hitGTall = abs(itc{1}) - abs(allitc);
    missGTall = abs(itc{2}) - abs(allitc);
    pbi = hitGTall .* missGTall;

    % save
    if tosave
        csvwrite(sprintf('%s/analysis/compare_phases/pdiff_prot%02i_chan%02i_sub%03i.csv', basedir, protocolID, chan, subjectID), pdiff);
        csvwrite(sprintf('%s/analysis/compare_phases/pbi_prot%02i_chan%02i_sub%03i.csv', basedir, protocolID, chan, subjectID), pbi);
    end
    