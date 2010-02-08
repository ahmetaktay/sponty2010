function export_mat_to_eeglab(infile,eventname,varargin)

% Function to read mat file created by mipavg and convert to eeglab format

montage = 0; outname = 0;

% labels theta radius X Y Z sph_theta sph_phi sph_radius type
cap34 = {
    {'HEOG', -18, 0.768, 0.95, 0.309, -0.0349, 18, -2, 1,'EOG'},...
    {'VEOG', 18, 0.768, 0.95, -0.309, -0.0349, -18, -2, 1,'EOG'},...
    {'FPZ', 0, 0.511, 0.999, -0, -0.0349, -0, -2, 1, 'EEG'},...
    {'FZ', 0, 0.256, 0.719, -0, 0.695, -0, 44, 1, 'EEG'},...
    {'FCz', 0, 0.128, 0.391, -0, 0.921, -0, 67, 1, 'EEG'},...
    {'Cz', 90, 0, 3.75e-33,	-6.12e-17, 1, -90, 90, 1, 'EEG'},...
    {'CPZ', 180, 0.128, -0.391,	-4.79e-17, 0.921, -180, 67, 1, 'EEG'},...
    {'PZ', 180, 0.256, -0.719, -8.81e-17, 0.695, -180, 44, 1, 'EEG'},...
    {'FP1', -18, 0.511, 0.95, 0.309, -0.0349, 18, -2, 1, 'EEG'},...
    {'FP2', 18, 0.511, 0.95, -0.309, -0.0349, -18, -2, 1, 'EEG'},...
    {'F3', -39, 0.333, 0.673, 0.545, 0.5, 39, 30, 1, 'EEG'},...
    {'F4', 39, 0.333, 0.673, -0.545, 0.5, -39, 30, 1 ,'EEG'},...
    {'F7', -54, 0.511, 0.587, 0.809, -0.0349, 54, -2, 1,'EEG'},...
    {'F8', 54, 0.511, 0.587, -0.809, -0.0349, -54, -2, 1,'EEG'},...
    {'FC3', -62, 0.278, 0.36, 0.676, 0.643, 62, 40, 1,'EEG'},...
    {'FC4', 62, 0.278, 0.36, -0.676, 0.643, -62, 40, 1,'EEG'},...
    {'FT7', -72, 0.511, 0.309, 0.95, -0.0349, 72, -2, 1,'EEG'},...
    {'FT8', 72, 0.511, 0.309, -0.95, -0.0349, -72, -2, 1,'EEG'},...
    {'C3', -90, 0.256, 4.4e-17, 0.719, 0.695, 90, 44, 1,'EEG'},...
    {'C4', 90, 0.256, 4.4e-17, -0.719, 0.695, -90, 44, 1,'EEG'},...
    {'T7', -90, 0.511, 6.12e-17, 0.999, -0.0349, 90, -2, 1,'EEG'},...
    {'T8', 90, 0.511, 6.12e-17, -0.999, -0.0349, -90, -2, 1,'EEG'},...
    {'CP3', -118, 0.278, -0.36, 0.676, 0.643, 118, 40, 1, 'EEG'},...
    {'CP4', 118, 0.278, -0.36, -0.676, 0.643, -118, 40, 1, 'EEG'},...
    {'TP7', -108, 0.511, -0.309, 0.95, -0.0349,	108, -2, 1, 'EEG'},...
    {'TP8', 108, 0.511, -0.309, -0.95, -0.0349,	-108, -2, 1, 'EEG'},...
    {'P3', -141, 0.333, -0.673, 0.545, 0.5,	141, 30, 1, 'EEG'},...
    {'P4', 141, 0.333, -0.673, -0.545, 0.5,	-141, 30, 1, 'EEG'},...
    {'P7', -126, 0.511, -0.587, 0.809, -0.0349,	126, -2, 1, 'EEG'},...
    {'P8', 126, 0.511, -0.587, -0.809, -0.0349,	-126, -2, 1, 'EEG'},...
    {'O1', -162, 0.511, -0.95, 0.309, -0.0349,	162, -2, 1, 'EEG'},...
    {'Oz', 180, 0.511, -0.999, -1.22e-16, -0.0349, -180, -2, 1, 'EEG'},...
    {'O2', 162, 0.511, -0.95, -0.309, -0.0349, -162, -2, 1, 'EEG'},...
    {'Blank', 0, 0, 0, 0, 0, 0, 0, 0,'Blank'},...
    };

if ~nargin
    fprintf('\nNo input file specified - exiting\n');
    return
end

if ~fast_fileexists(infile)
    fprintf('\nFile does not exist or cannot be read - exiting\n');
    return
end

outfile = varargin{1};
if(length(varargin) > 1)
    montage = 1;
    monfile = varargin{2};
    if(strcmpi(monfile,'cap34'))
        fprintf('\nUsing default locations for the 34 channels scalp montage\n');
        montage = -1;
    elseif ~fast_fileexists(monfile)
        fprintf('\nMontage file does not exist - numbering channels\n');
        montage = 0;
    end
end

load(infile);

nchan = n_chan(1);
if(montage < 0) nchan = nchan - 1; end

if montage == 1
    fidMON = fopen(monfile);
    [montageLabels,count] = getstrs(fidMON);
    fclose(fidMON);
elseif montage == 0
    montageLabels = cell(1,nchan);
    for n = 1:nchan
        montageLabels{n} = ['chan',num2str(n)];
    end
end

chanloc = struct('theta',cell(1,nchan),'radius',cell(1,nchan),'labels',cell(1,nchan),...
    'sph_theta',cell(1,nchan),'sph_phi',cell(1,nchan),'sph_radius',cell(1,nchan),...
    'X',cell(1,nchan),'Y',cell(1,nchan),'Z',cell(1,nchan),'type',cell(1,nchan));

nrow = ceil(sqrt(nchan));
ncol = ceil(nchan/nrow);

if (montage >= 0)
    for n = 1:nchan
        chanloc(n).theta = 0;
        chanloc(n).radius = 0;
        chanloc(n).labels = char(montageLabels{n});
        chanloc(n).sph_theta = 0;
        chanloc(n).sph_phi = 0;
        chanloc(n).sph_radius = 0;
        nr = rem(n,nrow);
        if (nr == 0) nr = nrow; end
        chanloc(n).X = nr;
        nc = mod(ceil(n/nrow),ncol);
        if (nc == 0) nc = ncol; end
        chanloc(n).Y = nc;
        chanloc(n).Z = 0;
    end
else
    for n = 1:nchan
        chanloc(n).theta = cap34{n}{2};
        chanloc(n).radius = cap34{n}{3};
        chanloc(n).labels = char(cap34{n}{1});
        chanloc(n).sph_theta = cap34{n}{7};
        chanloc(n).sph_phi = cap34{n}{8};
        chanloc(n).sph_radius = cap34{n}{9};
        chanloc(n).X = cap34{n}{4};
        chanloc(n).Y = cap34{n}{5};
        chanloc(n).Z = cap34{n}{6};
        chanloc(n).type = char(cap34{n}{10});
    end
end


EEGOUT = pop_importdata('data',single_trial_residuals(1:nchan,:,:),'dataformat','array','srate',1/n_secpt,...
    'nbchan',nchan,'xmin',n_ms_epoch(1)/1000,'pnts',n_pts,'setname',outfile,...
    'chanlocs',chanloc);

ntrials = size(EEGOUT.data,3);
EEGOUT.event = struct('type',cell(1,ntrials),'epoch',cell(1,ntrials));
for n = 1:ntrials, EEGOUT.event(n).type = char(eventname); end
for n = 1:ntrials, EEGOUT.event(n).epoch = n; end

outpath = pwd;

pop_saveset(EEGOUT,'filepath',outpath,'filename',outfile,'savemode','onefile');

return
