% Script to create a large matrix of average ERPs for each participant
function save_subject_erps(protocolID, subjects)
    % Basics
    basedir='/mnt/nfs/psych1/sponty01';
    addpath /mnt/nfs/programs/user_scripts/;

    tmp_data = EEGReadFloat32(sprintf('%s/data/s%03i/protocol%02i/mipped.avg', ...
        basedir, subjects(1), protocolID));

    combined_data = tmp_data;
    combined_data.data = zeros([length(subjects) size(tmp_data.data)]);

    for ii = 1:length(subjects)
        tmp_data = EEGReadFloat32(sprintf('%s/data/s%03i/protocol%02i/mipped.avg', ...
            basedir, subjects(ii), protocolID));
        combined_data.data(ii,:,:,:) = tmp_data.data;
    end

    save(sprintf('%s/data/grand_average/mats/merge_subave_protocol%02i.mat', basedir, protocolID), ...
        'combined_data', '-V6');

    % Read in grand average and save for plotting
    grand_average = EEGReadFloat32(sprintf('%s/data/grand_average/protocol%02i.gav', ...
            basedir, protocolID));
    save(sprintf('%s/data/grand_average/mats/gav_protocol%02i.mat', basedir, protocolID), ...
        'grand_average', '-V6');

       