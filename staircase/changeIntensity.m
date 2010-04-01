function params = changeIntensity(params, intensity)
    
    % Put limits on the contrasts (i.e. so don't go below 0)
    if isfield(params.stim, 'minIntensity')
        intensity = max(params.staircase.minIntensity, intensity);
    end
    if isfield(params.stim, 'maxIntensity')
        intensity = min(params.staircase.maxIntensity, intensity);
    end
    
    params.stimSet.intensity = intensity;
    