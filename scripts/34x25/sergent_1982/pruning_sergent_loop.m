% This successfully run, under the below commit, for 850x1
% git checkout a0713561f421b56368ecbe77e476d75a4b1fc2bb
% and results are saved into
% 850x1.mat
%
clear all variables; clear all globals;
dbstop if error

% I want to test spatial frequency processing with different hu/hpl, sigma, and nconn setups

hu_hpl = [ 108 8; 108 4; 850 1; 425 2; 425 1];
sigmas = [ 2; 4; 6; 8; 12 ];
nconn  = [ 6; 10; 15; 20];
cfact  = [ 1.5 2 5];

for hi=1:length(hu_hpl)

  % Look for cached results on disk
  outfile = sprintf('pruning-h%dx%d.mat', hu_hpl(hi,:));
  if exist(outfile,'file'), continue; end;

  % Build a local cache
  trn = cell(length(sigmas),length(nconn),length(cfact)); tst = cell(size(trn));
  for si=1:length(sigmas), for ci=1:length(nconn), for fi=1:length(cfact)

    % Set up params
    nparams = prod(hu_hpl(hi, :)) * nconn(ci) * cfact(fi)/2;
    [args,opts]  = uber_sergent_args('parallel', true, 'out.caching', true, 'runs',25, ...
                                     'nHidden', prod(hu_hpl(hi, :)), 'hpl', hu_hpl(hi,2), ...
                                     'sigma', [1 1]*sigmas(si), 'nConns', nconn(ci), ...
                                     'ac.EtaInit', 5E-2 * (425*2*12/nparams), ...
                                     'plots',{},'stats', {'ipd','distns','ffts'});
    args         = pruning_args( args{:}, 'ac.ct.nConnPerHidden_Start', ceil(nconn(ci)*cfact(fi)) );

    % Create a "mini"-cache
    %mSets = de_GetUberArgs('p', 'uber/natimg', 'sergent_1982/de/sergent', opts, args);
    miniFile = '__dummy__'; %fullfile(de_GetOutPath(mSets, 'ac_p_base'), ...
                        %sprintf('pruning-h%dx%d-s%.1f-c%dx%.1f',hu_hpl(hi,:),sigmas(si),nconn(ci),cfact(fi)))
    clear('mSets');

    if exist(miniFile,'file')
        load(miniFile, 'junk');
        if ~isfield(junk,'trn'), fprintf('lasterr: %s\n', junk); keyboard; end;

    else
        % Get the result
        try
          [junk.trn, junk.tst] = de_SimulatorUber('uber/natimg', 'sergent_1982/de/sergent', opts, args);
          close all;
          junk.trn.models = []; junk.tst.models = [];
          %save(miniFile, 'junk');

        catch
          warning(lasterr);
          junk = lasterr;
          %save(miniFile, 'junk');
        end;
    end;

    trn{si,ci,fi} = junk.trn; 
    tst{si,ci,fi} = junk.tst;
    clear('junk');
  end; end; end;

  save(outfile,'trn','tst');
end;