function splitRecomputeBlocks(eegFile, behavFile, outputEegFile)
% function splitRecomputeBlocks(eegFile, behavFile, outputEegFile)
    
    % Load in history
    fprintf('Loading history structure (i.e. behavioral data) in %s\n', behavFile);
    d = load(behavFile);
    history = d.history;
    
    % Get old codes
    fprintf('Reading in data %s\n', eegFile);
    eeg = MIPRead(eegFile);
    oldCodes = squeeze(eeg.data(eeg.nChannels+1,:));
    numCodes = length(oldCodes);

    % Get params
    params = getParams(true);

    % Split block in half if had to recompute contrast
    % Note that this is a ghetto fix to a problem

    % Decide if need to do anything
    if isempty(history.recomputeContrastBlocks)
        fprintf('No blocks where contrast was recomputing\n');
        newCodes = oldCodes;
    else
        fprintf('Dividing blocks with contrast recomputed\n');
        % Index in old code to create a block divider
        divideBlockIndices = [];

        % Random variables used in the loop
        isBlock = false;
        nBlock = 0;
        nBlockTrials = 0;
        
        % Loop through trials
        for ii=1:length(oldCodes)
            switch oldCodes(ii)
                case params.eegBlockStart
                    nBlock = nBlock + 1;
                    % Only look at this block if contrast was recomputing
                    if sum(history.recomputeContrastBlocks == nBlock)
                        isBlock = true;
                        nBlockTrials = 0;
                    end
                case params.eegBlockEnd
                    isBlock = false;
                otherwise
                if isBlock
                    switch oldCodes(ii)
                        % Start of Trial
                        case params.eegStartTrial
                            % Update block trial number
                            nBlockTrials = nBlockTrials + 1;
                            % Midway through trial
                            % hardcoded 18 but should make this abstract
                            if nBlockTrials == 19
                                fprintf('...will be dividing block %i\n', nBlock);
                                divideBlockIndices = [divideBlockIndices, ii];
                            end
                    end
                end
            end
        end
        
        % Loop through divide block indices and save in new list
        % by dividing we are just adding block end and block start codes
        % before the beginning of the 19th trial
        
        newCodes = oldCodes;
        
        for ii=1:length(divideBlockIndices);
            endIndex = divideBlockIndices(ii) - 2;
            startIndex = divideBlockIndices(ii) - 1;
            
            % Check that previous two spots are empty
            if newCodes(endIndex) ~= 0 || newCodes(startIndex) ~= 0
                error('Could not insert end block trigger at %i or start block trigger at %i since one of these indices was non-zero.', endIndex, startIndex);
            end
            
            newCodes(endIndex) = params.eegBlockEnd;
            newCodes(startIndex) = params.eegBlockStart;
        end
    end

    % Write out new file
    fprintf('Writing eeg file (%s) with new codes\n', outputEegFile);
    eeg.data(eeg.nChannels+1,:) = newCodes;
    MIPWrite(eeg, outputEegFile);
    