function [model] = de_DE(model)
%function [model] = de_DE(model)
%
% Train differential encoder.
%
% Inputs:
% model      : see de_model for details
%
% Outputs:
% model     :
%   .LS     : final performance on the different trial types
%   .ac.err : series training error from the autoencoder
%   .p.err  : series training error from the perceptron

  nPixels = prod(model.nInput);

  %--------------------------------%
  % Create and train the autoencoder
  %--------------------------------%

  if (model.ac.cached)
    fprintf('| (cached)');

  else
    % Set up input/output pairs
    X = model.data.train.X;
    Y = model.data.train.X(1:end-1,:);

    % Create connectivity
    if (~model.ac.continue)
        [model.ac.Conn, model.ac.Weights]    = de_connector(model);
    end;

    % Train the model
    [model.ac] = guru_nnTrainAC(model.ac,X);
    clear('X', 'Y');

    % report results to screen
    fprintf('| e_AC(%5d): %6.5e',size(model.ac.err,1),model.ac.avgErr(end));
    mn = 0+min(min(model.ac.Weights(nPixels+[1:model.nHidden], 1:nPixels)));
    mx = 0+max(max(model.ac.Weights(nPixels+[1:model.nHidden], 1:nPixels)));
    fprintf(' wts=[%5.2f %5.2f]', mn,mx)

  end;

  % Even if it's cached, we need the output characteristics
  %   of the model.
  if (~isfield(model.ac,'hu'))
    
    try
      error('Can''t cache these properties, because it''s not about the autoencoder--also depends on the image set!'); % Get the prop from disk, then rename
      model = de_LoadProps(model, 'ac',{'hu','output'});
      %if size(  
    catch
      if ismember(10, model.debug), fprintf('failed to find hu output on disk; computing now.'); end;
      % Make sure the autoencoder's connectivity is set.
      model = de_LoadProps(model, 'ac', 'Weights');
      model.ac.Conn = (model.ac.Weights~=0);

      [model.ac.output.train,~,model.ac.hu.train] = guru_nnExec(model.ac, model.data.train.X, model.data.train.X(1:end-1,:));
      [model.ac.output.test, ~,model.ac.hu.test]  = guru_nnExec(model.ac, model.data.test.X,  model.data.test.X(1:end-1,:));
    end;
  end;


  %--------------------------------%
  % Create and train the perceptron
  %--------------------------------%
  if (isfield(model, 'p'))

      if (~model.p.cached)
        good_train = ~isnan(sum(model.data.train.T,1));
        nTrials    = sum(good_train); % count the # of trials with no NaN anywhere in them

        % Use hidden unit encodings as inputs
        X_train    = model.ac.hu.train;
        X_train    = X_train - repmat(mean(X_train), [size(X_train,1) 1]); %zero-mean the code
        if isfield(model.p, 'zscore') && model.p.zscore>0
          X_train    = model.p.zscore * X_train ./ repmat( std(X_train, 0, 1), [size(X_train,1), 1] ); %z-score the code
        end;

        % Add bias
        if (model.p.useBias)
            biasVal = mean(abs(X_train(:)));
            biasArray=biasVal*ones(1,nTrials);
            X_train     = [X_train;biasArray];  %bias is last input
            clear('biasArray');
        end;

        Y_train = model.data.train.T;


        % Set up connectivity matrix:
        % 1:size(X,1) : inputs units (& bias?) to p
        %      : bias unit
        % nHidden+2:end : output unit(s)
        pInputs         = size(X_train,1);
        pHidden         = model.p.nHidden;
        pOutputs        = size(model.data.train.T,1);
        pUnits          = pInputs + pHidden + pOutputs;

        if (~model.p.continue)
            model.p.Conn    = false( pUnits, pUnits );

            model.p.Conn(pInputs+[1:pHidden],          [1:pInputs])=true; %input->hidden
            model.p.Conn(pInputs+pHidden+[1:pOutputs], pInputs+[1:pHidden])=true; %hidden->output
            model.p.Conn((pInputs+1):pUnits, pInputs) = (model.p.useBias~=0); %bias=>all

            model.p.Weights = model.p.WeightInitScale*guru_nnInitWeights(model.p.Conn, ...
                                                                         model.p.WeightInitType);
        end;


        % Train
        [model.p] = guru_nnTrain(model.p, X_train(:,good_train), Y_train(:, good_train));
        avgErr = mean(model.p.err(end,:),2)/pOutputs; %perceptron only has one output node
        fprintf(' | e_p(%5d): %4.3e',size(model.p.err,1),avgErr);
        if (isfield(model.p, 'Weights'))
            fprintf(' wts=[%5.2f %5.2f]', full(min(model.p.Weights(:))), full(max(model.p.Weights(:))))
        end;
        model.p            = rmfield(model.p, 'err');

        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        model.p.output.train = guru_nnExec(model.p, X_train(:,good_train), Y_train(:,good_train) );
        
      
        % TEST
        p_test     = model.p;

        good_test  = ~isnan(sum(model.data.test.T,1));
        nTest      = sum(good_test); % count the # of trials with no NaN anywhere in them

        % Use hidden unit encodings as inputs
        X_test    = model.ac.hu.test;
        X_test    = X_test - repmat(mean(X_test), [size(X_test,1) 1]); %zero-mean the code
        if isfield(model.p, 'zscore') && model.p.zscore>0
          X_test    = model.p.zscore * X_test ./ repmat( std(X_test, 0, 1), [size(X_test,1), 1] ); %z-score the code
        end;
        
        % Add bias
        if (model.p.useBias)
            biasArray=biasVal*ones(1,nTrials);
            X_test     = [X_test;biasArray];  %bias is last input
            clear('biasArray');
        end;

        Y_test = model.data.test.T;


        % Save off OUTPUT, not error, so that we can show training curves for ANY error measure.
        model.p.output.test = guru_nnExec(model.p, X_test(:,good_test), Y_test(:,good_test) );
      end;
  end;


