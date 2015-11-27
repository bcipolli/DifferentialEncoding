function [args,opts] = uber_sergent_args(varargin)
%
%  Final shared settings for 2YP runs
%   http://www.willamette.edu/~gorr/classes/cs449/classify.html

  % Get shared args
  script_dir = fileparts(which(mfilename));
  addpath(fullfile(script_dir, '..'));  

  [args,opts] = uber_args( ... %Network structure
                  'p.errorType', 2,... % cross-entropy
                  'p.XferFn', [6 4], ...  %sigmoid->sigmoid
                  'p.zscore', 0.15, ...
                  'p.EtaInit', 2E-3, ...
                  'p.TrainMode', 'resilient', 'p.Pow', 1, ...
                  'p.Acc', 1E-7, 'p.Dec', 0.25, ...
                  'p.dropout', 0.0, ...
                  'p.nHidden', 5, ...
                  'p.wlim', 2.0*[-1 1], ...
                  'p.MaxIterations', 50, ...
                  'p.lambda', 0.01, ...
                  'p.AvgError', 1E-3, 'p.rej.width', [NaN], 'p.rej.type', {'max'}, ...%'sample_std-normd'}, ...
                  varargin{:} ...
                 );
