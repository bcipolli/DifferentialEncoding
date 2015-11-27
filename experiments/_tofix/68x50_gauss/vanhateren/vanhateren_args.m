function [args,sz] = uber_args(varargin)
%
%  Final shared settings for 2YP runs

  % Add absolute path to code
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));  

  [cargs, opts] = common_args();
  rmpath('..');
  
  
  sz = [68 50];
  
  args  = de_ArgsInit({ cargs{:}, ...
              'ac.randState', 600,  ...
              'distn', {'norme'}, 'mu',    0, 'sigma', [ 10 20 ], ...
              'nHidden', 1134, 'hpl', 1, 'nConns', 30, ...
              ...
              'ac.tol', 0, ...
              'ac.XferFn', 6, 'ac.useBias', 1, ...
              'ac.AvgError', 1E-11, 'ac.MaxIterations', 150, ...
              'ac.EtaInit',  1E-2,  'ac.Acc', 5E-5, 'ac.Dec', 0.25, ... %tanh#2, bias=1 resilient
              'ac.TrainMode','resilient', 'ac.Pow', 3, ...
              'ac.lambda', 1E-4, ...%[0.02 0.02 0.015 0.01 0.005] ...
              'ac.debug', 1:10,     ...
              'ac.rej.props', {'err'}, ...
              'ac.rej.type',  {'max'}, ...
              'ac.rej.width', [nan],   ...
              'ac.debug', 1:10, ...
              'out.data', {'info','mat'}, ...
              'out.plots', {'png'},  ...
              'plots', {'images','ffts','connectivity'}, ...
              'stats', {'images','ffts'}, ... 

         }, varargin{:} ); 
                            
