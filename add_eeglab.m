function add_eeglab(loadeeglab)
    if nargin < 1
        loadeeglab = false;
    end
    
    addpath('/mnt/nfs/programs/eeglab/eeglab7_1_4_16b');
    
    if loadeeglab
        eeglab
    end
