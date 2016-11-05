%
%
%

%
dbstop if warning;
dbstop if error;
addpath(genpath('../../code'));

outDir = fullfile(de_GetBaseDir(), 'results', 'crossover');
sizes = { ...
    [10, 10], ...
    [20, 20], ...
    [30, 30], ...
    [34, 25], ...
    [68, 50] ...
};
for sz=sizes
    sz = sz{1};
    args = {
        'sz', sz, ...
        'Sigmas', [1:6 8 10], ...
        'nSamps', 10, ...
        'nBatches', 5, ...
    };

    rawFile = sprintf('data-%dx%d.mat', sz);
    if exist(rawFile, 'file'), continue; end;

    fprintf('Processing spatial frequency preferences for sz = [%d, %d]\n', sz);
    [avg_mean, std_mean, std_std, wts_mean, p] = sigma_vs_crossover( ...
        'disp', [11], ...
        args{:} ...
    );

    % Save results
    if ~exist(outDir, 'dir'), mkdir(outDir); end;
    for pltName = {'raw', 'crossovers'}
        pltName = pltName{1};
        outFile = fullfile(outDir, sprintf('plt-%s-%dx%d.png', pltName, sz));
        export_fig(gcf, outFile);
        close(gcf);
    end;
end;

