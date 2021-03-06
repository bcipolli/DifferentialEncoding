function [args,c_freqs,k_freqs] = uber_args(varargin)
%
%  Final shared settings for 2YP runs
  addpath(genpath('../../../code'));
c_freqs = [0.06 0.12 0.18 0.24 0.32];
%c_freqs = [0.06 0.12 0.24 0.48 0.96];
%c_freqs = [0.06 0.08 0.25 0.45 0.50];
k_freqs = [0.05 0.15];

  args  = de_ArgsInit({ ...
              'runs', 68, 'ac.randState', 2,  ...
              'distn', {'norme'}, ...% {'gamma'}, ... %{'gammae'}, ...
              'mu',    0, ...%[2.25  2], ...     %[1.5    1.75], ...
              'sigma', [ 1.5  3.0  6.0  11.0  18.0 ], ...
              'nHidden', 180, 'hpl', 2, 'nConns', 15, ...
              ...
              'ac.zscore',false,...
              'ac.tol', 0/403, ...
              ...
              'ac.rej.props', {'err'}, ...
              'ac.rej.type',  {'max'}, ...
              'ac.rej.width', [nan],   ...
              ...
              'out.data', {'info','mat'}, ...
              'out.plots', {'png'},  ...
              'plots', {'images','ffts'}, ...
              'stats', {'ffts'}, ... 

         }, varargin{:} ); 
                            