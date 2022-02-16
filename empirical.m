%% make experiment

nTrials = 1000;
pOmission = 0.0;
info = getExperiment(pOmission);
trials = makeTrials(nTrials, info.pOmission, info.ITIhazard, ...
    info.ISIcdf, info.firstRewardIndex);

%% TD learning

x = trials.x; O = info.O; T = info.T;
results_td = TD(x, O, T);

%% Monte Carlo

gamma = 0.98;
info = getExperiment(0.1);
% info.T = randn(size(info.T)).^2; info.T = bsxfun(@times, info.T, 1./sum(info.T,2));
% info.O = rand(size(info.O));
ix = find(info.O > 0);
info.O(ix) = rand(numel(ix),1);
% info.O(ix(:)) = rand(sum(ix(:)));

x = trials.x; O = info.O; T = info.T;
results_mc = monteCarloWeights(x, O, T, gamma, true);
results_mc.info = info;

%% plot value and rpes

results = results_mc; nm = 'Monte Carlo';
info = results.info;
gamma = results.gamma;

w = results.w;

% plot.init;
plotValueAndRpes(w, info, gamma);
title(nm);

%% test whether network trained with wrong dynamics still looks the same

pOmissionTask = 0.0; pOmissionOpposite = 0.1;

% Task trials
nTrials = 1000;
info = getExperiment(pOmissionTask);
trials = makeTrials(nTrials, info.pOmission, info.ITIhazard, ...
    info.ISIcdf, info.firstRewardIndex);

gamma = 0.98;

% learn using correct Task beliefs
info = getExperiment(pOmissionTask);
x = trials.x; O = info.O; T = info.T;
results_mc = monteCarloWeights(x, O, T, gamma, true);
results_mc.info = info;
results_mc_1 = results_mc;

% learn using other Task's beliefs
info = getExperiment(pOmissionOpposite);
x = trials.x; O = info.O; T = info.T;
results_mc = monteCarloWeights(x, O, T, gamma, true);
results_mc.info = info;
results_mc_2 = results_mc;

plot.init;
info = getExperiment(pOmissionTask);
plotValueAndRpes(results_mc_1.w, info, gamma, results_mc_1.info.O, results_mc_1.info.T);
plotValueAndRpes(results_mc_2.w, info, gamma, results_mc_2.info.O, results_mc_2.info.T);
title(nm);
