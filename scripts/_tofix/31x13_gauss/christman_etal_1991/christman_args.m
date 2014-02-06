function [args,opts] = christman_args(varargin)
%
%  Final shared settings for 2YP runs
  addpath(genpath('../../../code'));

  %freqs = [0.06 0.12 0.18 0.24 0.32]
  freqs = 0.75*[0.03 0.06 0.12 0.24 0.48]
%  freqs = 0.24*[1 2 4 8 16]%[0.24 0.48 0.96 1.5 2.6]
%  freqs = [0.07 0.14 0.28 0.32 0.64]
  %freqs = [0.06 0.08 0.25 0.45 0.50]
  %0.06*1.45.^[0:4];
  %0.06*1.45.^[0:4];
  %0.10*1.25.^[0:4];
  %[0.02 0.04 0.08 0.16 0.32];
  %0.75*2*pi*[0.5 1 2 4 8];
  %1.88 2.54 3.28 4.18 5.05];
  
%   0.1261    0.1829    0.2652 @ 0.01 showed HSF adv, LSF inter
  
% 0.0400    0.0600    0.0861 showed lsf adv, hsf inter

  opts = {'freqs', freqs, 'sz', 'small'}
  
  % Christman paper:
  %   ntrials: 128 trials/condition * 8 subjects = 1024
  %   model:   1024 trials / 16 trials/model = 64 model instances

  args  = de_ArgsInit( ... %network structure
              'runs', 25, ...
              'distn', {'norme'}, ...%{'gamma'}, ... %{'gammae'}, ...
              'mu',    0, ...%[2.25  2], ...     %[1.5    1.75], ...
              'sigma', [ 3.0  18 ], ...%[5   2.5], ...   %[ 20    10 ], ...
              'nHidden', 850, 'hpl', 1, 'nConns', 8, ...
              'errorType', 2, ...
              ... %training
             ... % Training: ac
             'ac.tol',    0/403, ... %tolerance for disconnected pixels
             'ac.randState', 600, ...
             'ac.XferFn',   6,            'ac.useBias',  1, ...
             'ac.AvgError', 5E-3,        'ac.MaxIterations', 159, ...
             'ac.TrainMode','resilient',  'ac.Pow', 3, ... %gradient power (usually 1)
             'ac.EtaInit',  1E-4,         'ac.Acc', 5E-7, 'ac.Dec', 0.25, ... %tanh#2, bias=1 resilient
             'ac.lambda',   0.025,         ...% regularization
             'ac.wmax', inf, ...
             ...
             'p.XferFn', 4,               'p.useBias', 1, ...
                                          'p.nHidden', 15, ...
             'p.AvgError',  0,            'p.MaxIterations', 1000, ...
             'p.TrainMode','batch',       'p.Pow',  1, ...
             'p.EtaInit',   1E-2,         'p.Acc',  1.005,  'p.Dec',  1.25, ... %sig,bias=0
             'p.lambda',   0.025, ...
             'p.wmax', inf, ...
             ... %rejections
             'ac.rej.props', {'err'},   'p.rej.props', {'err'}, ...
             'ac.rej.type',  {'max'},   'p.rej.type',  {'sample_std-normd'}, ...
             'ac.rej.width', [nan],     'p.rej.width', [3], ...
             ... %output
             'out.data', {'info','mat'}, ...
             'out.plots', {'png'},  ...
             'plots', {}, ...
             'stats', {}, ...
             varargin{:} ); 
