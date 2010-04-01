function eegSignal(params, code)
% function eegSignal(params, code)    
    if (params.is_eeg)
        putvalue(params.dio, code);
        WaitSecs(params.eeg.interSample);
        putvalue(params.dio, 0)
    end
end