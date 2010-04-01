function practiceFeedback(params, history, nTrial)

    % Set TextSize
    oldTextSize = Screen('TextSize', params.wPtr, 48);

    % See if gave response
    if history.trial.response(nTrial) == 0
        txt = 'No Response';
        txtDim = Screen('TextBounds', params.wPtr, txt);
        Screen('DrawText', params.wPtr, txt, params.disp.x0-RectWidth(txtDim)/2, params.disp.y0-RectHeight(txtDim)/2, [255 0 0]);
    elseif history.trial.isCorrect(nTrial)
        txt = 'Correct';
        txtDim = Screen('TextBounds', params.wPtr, txt);
        Screen('DrawText', params.wPtr, txt, params.disp.x0-RectWidth(txtDim)/2, params.disp.y0-RectHeight(txtDim)/2, [0 0 255]);
    else
        txt = 'Incorrect';
        txtDim = Screen('TextBounds', params.wPtr, txt);
        Screen('DrawText', params.wPtr, txt, params.disp.x0-RectWidth(txtDim)/2, params.disp.y0-RectHeight(txtDim)/2, [255 0 0]);
    end
    
    % Give feedback
    Screen('Flip', params.wPtr);
    Screen('TextSize', params.wPtr, oldTextSize);
    WaitSecs(params.practice.feedbackDur);
    %%% ghetto fix for some color issue
    Screen('DrawText', params.wPtr, '', params.disp.x0-RectWidth(txtDim)/2, params.disp.y0-RectHeight(txtDim)/2, [0 0 0]);

