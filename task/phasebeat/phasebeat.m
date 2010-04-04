function history = phasebeat(params, history)
    
    % Calibrate
    [params, history] = calibrate(params, history);
    calTrial = length(history.calibration.trial.response) + 1;
    params.quest.numTrials = round(params.quest.numTrials/2);
    blockBreak(params, params.calibrate.breakTime);
    
    % Task!
    nTrial = 1;
    % Go through blocks
    for nBlock=1:params.taskSet.numBlocks
        
        if nBlock ~= 1
            % Give break to allow them to do whatever
            blockBreak(params, round(params.timing.blockBreak/2));
            
            % Run some quick calibration scans
            eegSignal(params, params.eeg.calibrateStart);
            history.calibration.trial.blocks = [history.calibration.trial.blocks, calTrial];
            history.calibration.timing.blocks = [history.calibration.timing.blocks GetSecs];
            history.calibration.q = history.q;
            [params, history.calibration, calTrial] = staircase('Quest', params, history.calibration, calTrial, params.taskSet.percentNonTarget/2);
            history.q = history.calibration.q;
            eegSignal(params, params.eeg.calibrateEnd);
            
            % Recompute intensity
            params = changeIntensity(params, 10^QuestQuantile(history.q, 0.5));
            
            % Give break to allow them to do whatever
            blockBreak(params, round(params.timing.blockBreak/2));
        end
        
        % Update block info
        startBlockTrial = nTrial;
        history.trial.blocks = [history.trial.blocks, startBlockTrial];
        history.timing.blocks = [history.timing.blocks GetSecs];
        
        % EEG Trigger
        eegSignal(params, params.eeg.blockStart);
        
        % Go through sections in blocks
        for nSection=1:params.taskSet.numBlockSections
            
            % Set trials that are targets and non-targets
            numTargets = round(params.taskSet.numTrialsPerSection * (1-params.taskSet.percentNonTarget));
            numNonTargets = params.taskSet.numTrialsPerSection - numTargets;
            trialTargets = Shuffle([repmat(1, 1, numTargets) repmat(0, 1, numNonTargets)]);
            
            % Update section info
            startSectionTrial = nTrial;
            history.trial.blockSections = [history.trial.blockSections, startBlockTrial];
            history.timing.blockSections = [history.timing.blockSections GetSecs];
            
            % EEG Trigger
            eegSignal(params, params.eeg.blockSectionStart);
            
            % Go through trials!
            for ii=1:params.taskSet.numTrialsPerSection
                
                % Present Trial
                history = phasebeat_trial(params, history, nTrial, params.taskSet.percentNonTarget, trialTargets(ii));
                
                % Update Quest
                if history.trial.isTarget(nTrial) == 1 && history.trial.response(nTrial) ~= 0
                    history.q = QuestUpdate(history.q, log10(history.trial.intensity(nTrial)), history.trial.isCorrect(nTrial));
                end
                
                % Update Trial
                nTrial = nTrial + 1;
            end
            
            % EEG Trigger
            eegSignal(params, params.eeg.blockSectionEnd);
            
            if nSection ~= params.taskSet.numBlockSections
                % Give break to look at fixation cross
                textScreen(params, '+', '--waitforkey', false, '--waitsecs', params.timing.sectionBreak);
                
                % Put up the fixation and wait 3 seconds before starting
                Screen('DrawTexture', params.wPtr, params.stim.fixation);
                Screen('Flip', params.wPtr);
                WaitSecs(3);
            end
        
        end
        
        % EEG Trigger
        eegSignal(params, params.eeg.blockEnd);
        
        if nBlock ~= params.taskSet.numBlocks
            % Update 50% Intensity Level
            % but only if performance above or below 25-75%
            meanCorrect = getMeanCorrect(history, [], nBlock);
            if meanCorrect < 0.25 || meanCorrect > 0.75
                fprintf('Recomputing intensity!\n');
                params = changeIntensity(params, 10^QuestQuantile(history.q, 0.49));
                history.trial.blocksRedoIntensity = [history.trial.blocksRedoIntensity, nBlock];
            end
            
            
        end
            
    end
    
end
