clear all variables; clear all globals;

stats = {'ipd', 'connectivity', 'images', 'ffts', 'distns'};
plts = {'ls-bars', stats{:}};

[args,opts]  = uber_sergent_args('parallel', true, 'plots',plts,'stats',stats,'runs',25,'distn',{'ipd'}, 'mu', [1.5 2], 'sigma', [5 5], 'nConns', 10, 'nHidden', 850*2, 'hpl', 2);

% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent',         opts, args);
