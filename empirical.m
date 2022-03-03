%% make experiment

nTrials = 1000;
pOmission = 0.1;
% ITIhazard = 1/(13 / 0.2);
ITIhazard = 1/4;
minITI = 3;
omissionsHaveImaginaryISI = true;
info = getExperiment(pOmission, ITIhazard);
trials = makeTrials(nTrials, info.pOmission, info.ITIhazard, ...
    info.ISIcdf, info.firstRewardIndex, minITI, omissionsHaveImaginaryISI);

%% visualize T and O

% info = getExperiment(0.1);
% info.T = randn(size(info.T)).^2; info.T = bsxfun(@times, info.T, 1./sum(info.T,2));

names = {'$P(i \to j \mid null)$', '$P(i \to j \mid stim)$', ...
    '$P(i \to j \mid reward)$', '$P(i \to j)$'};
plot.init;
for c = 1:4
    plot.subplot(2,2,c); axis tight;
    if c < 4
        Oc = info.O(:,:,c);
        Oc = info.T .* Oc;
        Oc = Oc/max(Oc(:));
        Oc(Oc > 0) = 1;
        imshow(Oc);
    else
        imshow(info.T);
    end
    title(names{c}, 'interpreter', 'latex');
end
plot.setPrintSize(gcf, struct('width', 5, 'height', 4.7));

%% TD learning

x = trials.x; O = info.O; T = info.T;
results_td = TD(x, O, T);

%% Monte Carlo

gamma = 0.98;
% info = getExperiment(0.1);
% info.T = randn(size(info.T)).^2; info.T = bsxfun(@times, info.T, 1./sum(info.T,2));
% info.O = rand(size(info.O)); info.O = bsxfun(@times, info.O, 1./sum(info.O,3));
% ix = find(info.O > 0); info.O(ix) = rand(numel(ix),1);% info.O = bsxfun(@times, info.O, 1./sum(info.O,3));
% info.O(ix(:)) = rand(sum(ix(:)));
% info.O(:,:,1) = rand(size(info.O(:,:,1)));
% for c = 1:3
%     ix = find(info.T == 0);
%     Oc = info.O(:,:,c);
%     Oc(ix) = rand(size(ix));
%     info.O(:,:,c) = Oc;
% end

% info.T = []; info.O = []; % do CSC instead of beliefs

x = trials.x; O = info.O; T = info.T;
results_mc = leastSquaresBatch(x, O, T, gamma, true, true);
results_mc.info = info;

%% plot value and rpes

% results = results_base; nm = 'Monte Carlo';
results = results_mc; nm = 'TD-LS';

info = results.info;
gamma = results.gamma;

w = results.w;

plot.init;
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
results_mc = leastSquaresBatch(x, O, T, gamma, true);
results_mc.info = info;
results_mc_1 = results_mc;

% learn using other Task's beliefs
info = getExperiment(pOmissionOpposite);
x = trials.x; O = info.O; T = info.T;
results_mc = leastSquaresBatch(x, O, T, gamma, true);
results_mc.info = info;
results_mc_2 = results_mc;

plot.init;
info = getExperiment(pOmissionTask);
plotValueAndRpes(results_mc_1.w, info, gamma, results_mc_1.info.O, results_mc_1.info.T);
plotValueAndRpes(results_mc_2.w, info, gamma, results_mc_2.info.O, results_mc_2.info.T);
title(nm);

%% visualize different beliefs

% info = results_base.info;
% test_trials = makeTrials(0, info.pOmission, info.ITIhazard, ...
%     info.ISIcdf, info.firstRewardIndex);
% B1 = getBeliefs(test_trials.x, info.O, info.T);
% B2 = getBeliefs(test_trials.x, results_mc.info.O, results_mc.info.T);

mu = mean(B1);
[COEFF, SCORE, LATENT, TSQUARED, EXPLAINED] = pca(bsxfun(@minus, B1, mu), 'Centered', false);
z1 = bsxfun(@minus, B1, mu)*COEFF;
z2 = bsxfun(@minus, B2, mu)*COEFF;

% plot.init;
% plot3(z1(:,1), z1(:,2), z1(:,3), '.-', 'LineWidth', 2);
% plot3(z2(:,1), z2(:,2), z2(:,3), '.-', 'MarkerSize', 20);

plot.init; plot(z1(:,1:3)); axis tight; yl = ylim;
plot.setPrintSize(gcf, struct('width', 9, 'height', 1.5));
plot.init; plot(z2(:,1:3)); axis tight; ylim(yl);
plot.setPrintSize(gcf, struct('width', 9, 'height', 1.5));

%% explore similarity of beliefs

info = getExperiment(0.0);
test_trials = makeTrials(0, info.pOmission, info.ITIhazard, ...
    info.ISIcdf, info.firstRewardIndex);
B1 = getBeliefs(test_trials.x, info.O, info.T);

info = getExperiment(0.1);
info.T = rand(size(info.T)); info.T = bsxfun(@times, info.T, 1./sum(info.T,2));
% ix = find(info.T == 0);
% for c = 1:3    
%     Oc = info.O(:,:,c);
%     Oc(ix) = rand(size(ix));
%     info.O(:,:,c) = Oc;
% end
B2 = getBeliefs(test_trials.x, info.O, info.T);

assert(all(find(B1(:) > 0) == find(B2(:) > 0)));

ixc = (size(B1,1)-37):(size(B1,1)-20);
plot.init;
plot(B1(ixc,:));
plot(B2(ixc,:), '-');
axis tight;

