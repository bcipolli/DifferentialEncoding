function [train, test] = de_StimCreate(stimSet, taskType, opts)

  [X_trn, opts] = guru_popopt(opts, 'X_trn');
%  [Y_trn, opts] = guru_popopt(opts, 'Y_trn');
  [X_tst, opts] = guru_popopt(opts, 'X_tst', X_trn);
%  [Y_tst, opts] = guru_popopt(opts, 'Y_tst', Y_trn);
  [nInput, opts] = guru_popopt(opts, 'nInput');

  train = struct('X', X_trn, 'XLAB', arrayfun(@(v) '', X_trn(:, 1), 'UniformOutput', false), ...
                 'nInput', nInput );
  test = struct('X', X_tst, 'XLAB', arrayfun(@(v) '', X_tst(:, 1), 'UniformOutput', false), ...
                 'nInput', nInput );


function [val, opts_out] = guru_popopt(opts, opt_name, default_val)
  if ~exist('default_val', 'var')
    val = guru_getopt(opts, opt_name);
  else
    val = guru_getopt(opts, opt_name, default_val);
  end;

  opts_out = guru_rmopt(opts, opt_name);


function opts_out = guru_rmopt(opts, optname)

  %[inopts, idx] = ismember(opts, optname);
  idx = [];
  opts_out = {}
  for ii=length(opts):-2:1
      if (~ischar(opts{ii}) || ~strcmp(opts{ii}, optname))
          opts_out{end+1} = opts{ii};
          opts_out{end+1} = opts{ii+1};
      end;
  end;
  
  