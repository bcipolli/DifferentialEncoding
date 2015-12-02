function [cargs, opts] = common_args(varargin)
%

  % Add path to the base_args_and_setup function.
  script_dir = fileparts(which(mfilename));
  base_fn_dir = fullfile(script_dir, '..');
  addpath(base_fn_dir);

  opts = {'medium'};

  cargs = base_args_and_setup( ...
    'debug', 1:10, 'ac.debug', 1:10, 'p.debug', 1:10, ...
    'ac.randState', 2,   'p.randState', 2, ...
    'distn',   {'normem2'},    'mu',         0, ...
    'sigma', [4.0 15.0], ...
    'nHidden', 1*3400,        'hpl',       1,    'nConns',      12, ...
    ...% Input
    'ac.tol',    0*34/25, ... %tolerance for disconnected pixels
    ... % Training
    'ac.errorType', 2, ...
    'ac.XferFn',   [6 1], ...
    ...
    'ac.WeightInitScale', 0.01, ...
    'ac.WeightInitType', 'sprandn', ...
    'ac.TrainMode','resilient', ...
    'ac.Pow', 1, ...
    'ac.wlim',            0.5 * [-1 1], ...
    'ac.dropout', 0.0, ...
    'ac.noise_input',     0.00, ...
    'ac.lambda',          0.025,         ...% regularization
    ...
    'errorType', 3, ...
    'p.errorType', 3, ...
    'p.XferFn', [6, 7], ...
    ...
    'p.WeightInitScale', 10, ...
    'p.WeightInitType', 'sprandn', ...
    'p.Pow', 1, ...
    'p.wlim',            [-inf inf],         ...% regularization
    'p.dropout', 0.0, ...
    'p.noise_input',     0,         ...% regularization
    'p.lambda',          0.00,         ...% regularization
    ...
    'ac.rej.props', {'err'},                'p.rej.props', {'err'}, ... %err,max,nan
    'ac.rej.type',  {'max'},                'p.rej.type',  {'sample_std-normd'}, ...
    'ac.rej.width', [NaN],                  'p.rej.width', [3], ...
    ... %output
    'out.data', {'info','mat'}, ...
    'out.plots', {'png'},  ...
    'out.titles', {'LH (wide)', 'RH (narrow)'},  ...
    ...
    varargin{:} ...
  );
