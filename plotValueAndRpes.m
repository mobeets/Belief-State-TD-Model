function plotValueAndRpes(w, info, gamma, O, T)
    if nargin < 4
        O = info.O;
    end
    if nargin < 5
        T = info.T;
    end
    xmx = 22;

    test_trials = makeTrials(0, info.pOmission, info.ITIhazard, ...
        info.ISIcdf, info.firstRewardIndex);
    [B, b0] = getBeliefs(test_trials.x, O, T);
    [rpe, value] = FixedWeights(test_trials.x, w, B, gamma, b0);

    trialStarts = find(test_trials.x == 2);
    rpes = nan(numel(trialStarts), max(diff(trialStarts)));
    values = rpes;
    for ii = 1:numel(trialStarts)
        t1 = trialStarts(ii) - 2; % pre stim
        t2 = t1 + find(test_trials.x((t1+1):end) == 3, 1) + 4; % post reward
        if isempty(t2)
            t2 = numel(rpe);
        end
        rc = rpe(t1:min(t2,numel(rpe)));
        vc = value(t1:min(t2,numel(rpe)));
        rpes(ii,1:numel(rc)) = rc;
        values(ii,1:numel(vc)) = vc;
    end

    c = 1; nrows = 1; ncols = 3;
    plot.subplot(nrows, ncols, c); c = c + 1;
    plot(values(end-1,:)');
    xlabel('time');
    ylabel('value');
    axis tight;
    xlim([0 xmx]);

    plot.subplot(nrows, ncols, c); c = c + 1;
    h = plot([w(end)*ones(3,1); w]);
    xlabel('time');
    ylabel('belief weight');
    axis tight;
    xlim([0 xmx]);

    plot.subplot(nrows, ncols, c); c = c + 1;
    plot(rpes', '.', 'Color', h.Color);
    xlabel('time');
    ylabel('rpe');
    axis tight;
    xlim([0 xmx]);

    plot.setPrintSize(gcf, struct('width', 10, 'height', 2.5));
end
