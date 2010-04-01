function [stimulus] = adjustStim(params, intensity)
    %function makeStim(params, intensity)
    %
    % This function makes the stimulus for the detection experiment. 
    % <params> is the data struct with the params,
    % this includes the grating matrix and annulus mask
    % 
    % returns the stimulus as a grayscale matrix
    %
    
    % Adjust the contrast difference between max and min values of grating matrix
    adjGratingMatrix = intensity * params.stim.gratings;

    % Ensure that mean of stimulus contrast difference is same as background
    % this means that fgContrast / 2 will reflect the mean absolute contrast
    % difference between the bacground and stimulus
    adjGratingMatrix = adjGratingMatrix + (params.disp.bgContrast - mean(adjGratingMatrix(:)));

    % Mask image matrix to create gratings within annulus
    imageMatrix = adjGratingMatrix .* params.stim.annulus;

    % Ensure that any values that were masked out (i.e. = 0)
    % are set to the background intensity
    imageMatrix(imageMatrix==0) = params.disp.bgContrast;

    % Convert the matrix to have colors in appropriate range for screen
    stimulus = params.disp.white*imageMatrix;
