% Loop over the # of hidden nodes and connections,
%   and match to performance

args = depp_1D_args('plots',   {'none'}, ...
                    'stats',   {'vs'}, ...
                    'nHidden', [], ...
                    'nConns',  [], ...
                    'ac.AvgError', 0.05);
                 
nHidden = [ 11 12 13 14 15 ];
nConns  = [  5  6  7  8  9 10];

allstats = loopmeHL(1, 'de', 'sergent', {}, ...
                    ...
                    { 'nConns' },  { nConns }, ...
                    { 'nHidden' }, { nHidden }, ...
                    ...
                    args{:} ...
                   );

  % Step 1: produce performance diff figure
  fig = de_PlotHLPerfDiff(allstats, nHidden, nConns);
  print(fig.handle, '-dpng', ['depp_1D_loop_hidden_' fig.name]);

  % Step 2: produce human fit figure
  fig = de_PlotHLHumanFit(allstats, nHidden, nConns);
  print(fig.handle, '-dpng', ['depp_1D_loop_hidden_' fig.name] );

  % Step 3: calculate correlation between perf difference and human fit
  [rho,pval] = de_StatsHLPerfDiffVsHumanFit(allstats)
  