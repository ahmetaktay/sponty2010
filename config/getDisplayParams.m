function params = getDisplayParams(params)
% function params = getDisplayParams(params)
%
% Creates psychtoolbox display and saves relevant stimuli/display params
%
    
    % Initialize display params and open the display:
    [params.disp.black params.disp.white params.wPtr params.disp.wRect] = ...
        startDisplay(params.screenNum, params.disp.bgContrast);
        
    % Get center coordinates
    [params.disp.x0, params.disp.y0] = RectCenter(params.disp.wRect);
    