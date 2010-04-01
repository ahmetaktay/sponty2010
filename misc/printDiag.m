function printDiag(history)

    fprintf('\n');
    fprintf('--------\n');
    
    fprintf('\n');
    fprintf('TRIAL DIAGNOSTIC INFO\n');
    fprintf('Target: %i\n', history.trial.isTarget(end));
    fprintf('Intensity: %f\n', history.trial.intensity(end));
    fprintf('Response: %i\n', history.trial.response(end));
    fprintf('Reaction Time: %f\n', history.trial.rxntime(end));
    fprintf('Correct: %i\n', history.trial.isCorrect(end));
    
    fprintf('\n');
    fprintf('Stimulus Duration: %f\n', history.timing.stimulusDuration(end));
    fprintf('Trial Duration: %f\n', history.timing.trialDuration(end));
    fprintf('ITI: %f\n', history.timing.actualITI(end));
    
    fprintf('\n');
    fprintf('--------\n');
    
    return;
end