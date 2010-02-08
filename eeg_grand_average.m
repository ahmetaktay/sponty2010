function eeg_grand_average(protocolID, subjects, to_detrend)
% function eeg_grand_average(protocolID, subjects, to_detrend)

    if nargin < 3
        to_detrend = true;
    end
    if nargin < 2
        subjects=[101,103,104,105,106,107,109,110,111,112,113,115];
    end
    if nargin < 1
        protocolID=01;
    end
    output_file = sprintf('data/grand_average/protocol%02i.gav',protocolID);
    
    addpath /mnt/nfs/programs/user_scripts/;
    
    oldpath = cd('/mnt/nfs/psych1/sponty01');
    data = EEGReadFloat32(sprintf('data/s%03i/protocol%02i/mipped.avg', subjects(1), protocolID));
    avg = data.data;

    % Copy header file
    fprintf('Copying header file');
    copyfile(sprintf('data/s%03i/protocol%02i/mipped.hdr',subjects(1),protocolID), ...
        sprintf('data/grand_average/protocol%02i.hdr',protocolID));
    
    %size(avg)
    for ii=2:length(subjects)
        data = EEGReadFloat32(sprintf('data/s%03i/protocol%02i/mipped.avg',subjects(ii),protocolID));
        fprintf('size of subject %02i is ', subjects(ii));
        size(data.data)
        avg = avg + data.data;
    end
    
    avg = avg / length(subjects);

    % detrend
    % dim: conditions, channels, timepoints
    if to_detrend
        for ii=1:size(avg,1);
            avg(ii,:,:) = detrend(squeeze(avg(ii,:,:))')';
        end
    end
    
    fidAVG = fopen(output_file,'wb');

    for k = 1:data.nBins;
        for j = 1:data.nChannels
            fwrite(fidAVG,avg(k,j,:),'float32');
        end
    end

    fclose(fidAVG);

    diff_file = sprintf('data/grand_average/diff_protocol%02i.gav',protocolID);
    fidAVG = fopen(diff_file,'wb');

    diff = zeros(2,data.nChannels,data.nPoints);
    diff(1,:,:) = avg(1,:,:) - avg(2,:,:);
    diff(2,:,:) = avg(2,:,:) - avg(1,:,:);

    for k = 1:2;
        for j = 1:data.nChannels
        fwrite(fidAVG,diff(k,j,:),'float32');
        end
    end

    fclose(fidAVG);


    % fidHDR = fopen(output_hdr,'w');
    cd(oldpath)
