function figs = de_FigurizerCC(mSets, mss, stats)
%% Still needed:
% 1) Make the plots prettier. Currently plots have #s that overlap.
% 2) Implement code that generalizes based on the task (blob/dot vs paired
% squares etc)

    ds = 'test';

    left = stats.rej.cc.perf.(ds){1};
    right = stats.rej.cc.perf.(ds){end};
    rons = mSets.runs;

    figs = de_NewFig(mSets.data.taskType);

    n_trial_types = length(left);
    for ti=1:n_trial_types  % plot for each trial type
        subplot(1, n_trial_types, ti);

        left_mean = mean(left{ti}(:));
        right_mean = mean(right{ti}(:));

        % Average over trials to get a single score per network,
        % then find stderr over all networks.
        left_stderr = std(mean(left{ti}, 2)) / sqrt(size(left{ti}, 1));
        right_stderr = std(mean(right{ti}, 2)) / sqrt(size(right{ti}, 1));

        taskTitle = sprintf('%s (%s)', ...
                            guru_capitalizeStr(mSets.data.taskType), ...
                            guru_capitalizeStr(stats.rej.cc.anova.(ds).trial_types{ti}));

        de_CreateSlotnickFigure1([left_mean right_mean], ...
                                 [left_stderr right_stderr], ...
                                 taskTitle, mSets.data.stimSet, rons);
    end;
