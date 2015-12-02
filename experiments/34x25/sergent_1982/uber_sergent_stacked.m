clear all variables; clear all globals;

stats = {'ffts', 'images', 'connectivity'};%'ipd', 'ffts', 'distns', 'pca', 'images'};
plts = {'ls-bars'};%'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('deType', 'de-stacked', ...
                                 'plots', plts, 'stats', stats, 'runs', 50, ...
                                 'p.MaxIterations', 25);
[args, opts] = de_SetupStackedArgs(args, opts);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('vanhateren/250', 'sergent_1982/de/sergent', opts, args);
