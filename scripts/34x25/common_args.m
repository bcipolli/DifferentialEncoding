function [cargs, opts] = common_args(varargin)

  % Add absolute path to code
  if (exist('de_GetBaseDir')~=2)
    addpath(genpath(fullfile('..','..', 'code')));
    addpath(genpath(fullfile('..','..','..', 'code')));
    addpath(genpath(fullfile(de_GetBaseDir(),'code')));
    rmpath (genpath(fullfile('..','..','..', 'code')));
    rmpath (genpath(fullfile('..','..', 'code')));
  end;

  opts = {'small'};

  cargs = {  'parallel', false, 'debug', 1:10, 'ac.debug', 1:10, 'p.debug', 1:10, ...
             'ac.randState', 2,   'p.randState', 2, ...
             'distn',   {'norme'},    'mu',         0,    'sigma',       [ 4 10 ], ...
             'nHidden', 2*408,       'hpl',       2,    'nConns',      12, ...
             ...% Input
             'ac.tol',    0*34/25, ... %tolerance for disconnected pixels
             ... % Training
             'ac.errorType', 2, ...
             'ac.XferFn',   [6 1], ...
             'ac.useBias',  1, ...
             ...
             'ac.WeightInitScale', 0.01, ...
             'ac.WeightInitType', 'sprandn', ...
             'ac.wlim',            [-inf inf], ...
             'ac.dropout', 0.0, ...
             'ac.noise_input',     0.00, ...
             'ac.lambda',          0.00,         ...% regularization
             ...
             'p.useBias',  1, ...
             ...
             'p.WeightInitScale', 0.005, ...
             'p.wlim',            [-inf inf],         ...% regularization
             'p.dropout', 0.0, ...
             'p.noise_input',     0,         ...% regularization
             'p.lambda',          0.00,         ...% regularization
             ...
             'ac.rej.props', {'err'},                'p.rej.props', {'err'}, ... %err,max,nan
             'ac.rej.type',  {'max'},                'p.rej.type',  {'max'}, ...%'sample_std-normd'}, ...
             'ac.rej.width', [NaN],                  'p.rej.width', [NaN], ...%3] ...
             ... %output
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
              ...
             varargin{:}
           };
