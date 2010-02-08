disp(['Adding path to all EEGLAB functions']);
add_eeglab();
p = which('eeglab.m');
p = p(1:findstr(p,'eeglab.m')-1);
allseps = find( p == filesep );
p_parent = p(1:allseps(end-min(1,length(allseps))));
eeglabpath = p(allseps(end-min(1,length(allseps)))+1:end);
% Add external functions
dircontent  = dir([ p 'external' ]);
dircontent  = { dircontent.name };
for index = 1:length(dircontent)
    if dircontent{index}(1) ~= '.'
        if exist([p 'external' filesep dircontent{index}]) == 7
            addpath([p 'external' filesep dircontent{index}]);
            disp(['Adding path to ' eeglabpath 'external' filesep dircontent{index}]);
        end;
        if ~isempty(findstr('fieldtrip', lower(dircontent{index})))
            addpath([p 'external' filesep dircontent{index} filesep 'fileio' ]);
            disp(['Adding path to ' eeglabpath 'external' filesep dircontent{index} filesep 'fileio' ]);
        end;
    end;
end;
% Add all function directies
dircontent  = dir([ p 'functions' ]);
dircontent  = { dircontent.name };
for index = 1:length(dircontent)
    if dircontent{index}(1) ~= '.'
        if exist([p 'functions' filesep dircontent{index}]) == 7
            addpath([p 'functions' filesep dircontent{index}]);
            disp(['Adding path to ' eeglabpath 'functions' filesep dircontent{index}]);
        end;
    end;
end;
