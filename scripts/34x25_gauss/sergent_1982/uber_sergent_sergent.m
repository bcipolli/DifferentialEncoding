clear all variables; clear all globals;

plts = {'ls-bars', 'images','ffts'};
stats = {'images','ffts'};
[args,opts]  = sergent_args('plots',plts,'stats',stats,'runs',2, 'ac.zscore', 0.025, 'ac.EtaInit', 2.1E-1, 'ac.AvgError', 1E-4, 'ac.MaxIterations', 100,  ...
                            'errorType', 1, ...
                            'p.errorType', 3,... % cross-entropy
                            'p.XferFn', [6 3], ...  %sigmoid->sigmoid
                            'p.zscore', 0.15, ...
                            'p.EtaInit', 2E-2, ...
                            'p.TrainMode', 'resilient', 'p.Acc', 1E-7, 'p.Dec', 0.25, ...
                            'p.dropout', 0.0, ...
                            'p.nHidden', 25, ...
                            'p.wlim', 2.0*[-1 1], ...
                            'p.MaxIterations', 50, ...
                            'p.AvgError', 7.5E-5, 'p.rej.width', [NaN], 'p.rej.type', {'max'} ...
                            );
% Run sergent task by training on all images
[trn, tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent',         opts, args);
