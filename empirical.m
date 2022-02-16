%% make experiment

nTrials = 1000;
pOmission = 0.1;
info = getExperiment(pOmission);
trials = makeTrials(nTrials, info.pOmission, info.ITIhazard, ...
    info.ISIcdf, info.firstRewardIndex);

%% TD learning

x = trials.x;
O = info.O;
T = info.T;
results_td = TD(x, O, T);

%% Monte Carlo

gamma = 0.98;
x = trials.x;
O = info.O;
T = info.T;
results_mc = monteCarloWeights(x, O, T, gamma, true);

%% plot value and rpes

% w = results_td.w(end,:)';
% w = results_mc.w;

test_trials = makeTrials(0, info.pOmission, info.ITIhazard, ...
    info.ISIcdf, info.firstRewardIndex);
[B, b0] = getBeliefs(test_trials.x, info.O, info.T);
[rpe, value] = FixedWeights(test_trials.x, w, B, gamma, b0);

trialStarts = find(test_trials.x == 2);
rpes = nan(numel(trialStarts), max(diff(trialStarts)));
values = rpes;
for ii = 1:numel(trialStarts)
    t1 = trialStarts(ii)-2;
    t2 = t1 + find(test_trials.x((t1+1):end) == 3, 1) + 4;
    if isempty(t2)
        t2 = numel(rpe);
    end
    rc = rpe(t1:min(t2,numel(rpe)));
    vc = value(t1:min(t2,numel(rpe)));
    rpes(ii,1:numel(rc)) = rc;
    values(ii,1:numel(vc)) = vc;
end

plot.init;
plot.subplot(1,2,1);
plot(values');
% plot(Vnext);
xlabel('time');
ylabel('value');
axis tight;

plot.subplot(1,2,2);
plot(rpes', '.-');
xlabel('time');
ylabel('rpe');
axis tight;

plot.setPrintSize(gcf, struct('width', 7, 'height', 2.7));
