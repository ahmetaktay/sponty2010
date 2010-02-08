function processSubjects(protocolID,subjects)
% function processSubjects(protocolID,subjects)
    if nargin < 2
        [101,103,104,105,106,107,109,110,111,112,113,115];
    end
    if nargin < 1
        protocolID=01;
    end
    add_eeglab;
    addpathsEEGLAB;
    for ii=1:length(subjects)
        fprintf('running protocol%02i on subject%03i',protocolID,subjects(ii));
        dataProcess(subjects(ii),protocolID,false);
    end
 
end

