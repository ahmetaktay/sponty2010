function mipRecodeTrial(inputFile, outputFile)
   % function mipRecode(inputFile, outputFile)
   %
   % inputFile = foobar.eeg file from mip
   % outputFile = recode text file with 2 columns
   % 1st column are old codes, 2nd column are new codes
   % this will be input for mipavg3
 
   % PARAMS HERE CONTROL THE BINNING
   basePoints = 277;
   binSize = 50;
   
   % Get old codes
   eeg = MIPRead(inputFile);
   trigChan = squeeze(eeg.data(eeg.nChannels+1,:));
   
   % ignore start and stop codes
   oldCodes = trigChan(trigChan~=253 & trigChan~=255);
   
      % Build an array of indices
   indices = 1:length(oldCodes);
   for k=1:length(oldCodes)
       if oldCodes(k) == 0
           indices(k) = 0;
       end
   end
   oldCodes = oldCodes(oldCodes~=0);
   indices = indices(indices~=0);
   numCodes = length(oldCodes);
   fprintf('There are %i different codes\n', numCodes);

   fprintf('Created index for %i codes\n', length(indices));
   
   % Get params
   params = getParams(true);
    
   % var to store how many blocks get kept
   good_blocks = 0;
   
   % New Codes
   noResponse = 1;
   falseAlarm = 2;
   correctReject = 3;
   hit = [4 6 8 10 12];
   miss = [5 7 9 11 13];
   
   % Random 1s appear to sometimes come
   badCode = 1;
   badCodeFix = 999;
 
   % Create new codes
   newCodes = oldCodes;
   nBlock = 0;
   isBlock = false;
   hitArray = [];
   missArray = [];
   for ii=1:length(oldCodes)
      switch oldCodes(ii)
         case 0
         case badCode
           fprintf('Found bad code %i at trial %i', badCode, ii);
           newCodes(ii) = badCodeFix;
         case params.eegBlockStart
           nBlock = nBlock + 1;
           fprintf('Checking block %i\n', nBlock);
           isBlock = check_block_goodness(ii);
         case params.eegBlockEnd
           isBlock = false;
         otherwise
            if isBlock
               switch oldCodes(ii)
                  % Target
                  case params.eegTarget
                        % Confirm that previous code is start of trial
                        if oldCodes(ii - 1) ~= params.eegStartTrial
                            error('Setting eeg target trial but did not find the start of the trial');
                        end
                        switch oldCodes(ii+1)
                           case params.eegCorrect
                               hitArray = [hitArray timeBin(ii)];
                              newCodes(ii-1) = hit(timeBin(ii));
                           case params.eegIncorrect
                               missArray = [missArray timeBin(ii)];
                              newCodes(ii-1) = miss(timeBin(ii));
                           case params.eegNoResponse
                              newCodes(ii-1) = noResponse;
                        end
                  % No Target
                  case params.eegNoTarget
                    if oldCodes(ii-1) ~= params.eegStartTrial
                        error('Setting eeg non-target trial but did not find the start of the trial');
                    end
                     switch oldCodes(ii+1)
                        case params.eegCorrect
                           newCodes(ii-1) = correctReject;
                        case params.eegIncorrect
                           newCodes(ii-1) = falseAlarm;
                        case params.eegNoResponse
                           newCodes(ii-1) = noResponse;
                     end
               end
            end
      end
   end
    
    function good_block_bool = check_block_goodness(jj)
        % acceptable difference between correct and incorrect
        % in half a block => 18 trials
        diff_tolerance = 0.5; % 0.5 means %75/%25 will be a barely acceptable split
        max_false_alarms = 1; % don't accept anything more than x false alarms
        max_no_responses = 3; % don't accept more than x no responses
       
        temp_hits = 0;
        temp_misses = 0;
        temp_false_alarms = 0;
        temp_no_responses = 0;
        temp_correct_rejects = 0;
        trial_count = 0;
        
        jj = jj + 1; % skip the start of block code
        
        while oldCodes(jj) ~= params.eegBlockEnd
            switch oldCodes(jj)
                % Target
                case params.eegTarget
                    trial_count = trial_count + 1;
                    switch oldCodes(jj+1)
                        case params.eegCorrect
                            temp_hits = temp_hits + 1;
                        case params.eegIncorrect
                            temp_misses = temp_misses + 1;
                        case params.eegNoResponse
                            temp_no_responses = temp_no_responses + 1;
                    end
                % No Target
                case params.eegNoTarget
                    trial_count = trial_count + 1;
                    switch oldCodes(jj+1)
                        case params.eegCorrect
                            temp_correct_rejects = temp_correct_rejects + 1;
                        case params.eegIncorrect
                            temp_false_alarms = temp_false_alarms + 1;
                        case params.eegNoResponse
                            temp_no_responses = temp_no_responses + 1;
                    end
                otherwise
            end
            jj = jj + 1;
        end
        
        
        temp_total = temp_hits + temp_misses;
        tolerated_diff = (diff_tolerance * temp_total) > abs(temp_hits - temp_misses);
        good_block_bool = tolerated_diff && (max_no_responses >= temp_no_responses) && (max_false_alarms >= temp_false_alarms);
        fprintf('...');
        if good_block_bool
            good_blocks = good_blocks + 1;
            fprintf('good ');
        end
                fprintf('block, %02i hits and %02i misses. %i false_alarms, %i correct rejects, %i no response.\n', temp_hits, temp_misses, temp_false_alarms,  temp_correct_rejects, temp_no_responses);
    end
    
    function bin = timeBin(xx)
        timer = indices(xx) - indices(xx-1);
        bin = round((timer - basePoints) / binSize);
    end


    % Save new codes
    hist(hitArray);
    h = hitArray;
    figure()
    m = missArray;
    hist(missArray);
    fprintf('Saving file %s, %i usable blocks and %i codes\n', outputFile, good_blocks, length(newCodes));
    dlmwrite(outputFile, [oldCodes' newCodes'], '\t');
 
    return
end