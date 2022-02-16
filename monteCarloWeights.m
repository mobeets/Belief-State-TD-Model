function results = monteCarloWeights(x, O, T, gamma, doSim)
% function [w, B, g] = monteCarloWeights(x, O, T, gamma)
% - x     - observations
% - O     - observation distribution
% - T     - transition distribution
% - gamma - discount factor
% 
    if nargin < 4
        gamma = 0.98;
    end
    if nargin < 5
        doSim = false;
    end
    
    % get belief
    [B, b0] = getBeliefs(x, O, T);

    % get discounted return
    r = (x == 3);
    g = 0*r;
    rinds = find(r==1);
    times = 1:numel(r);
    for t = 1:numel(rinds)
        rt = rinds(t);
        ix = times <= rt;
        g(ix) = g(ix) + (gamma.^(rt - times(ix)))';
    end
    
    % find weights using linear regression,
    %   aka every-visit monte carlo when beliefs are one-hot
    ix = sum(B) > 0;
    Bc = B(:,ix);
    w = (Bc'*Bc)\(Bc'*g);
    
    results.w = w; % weights
    results.b0 = b0; % initial belief
    results.B = B; % beliefs
    results.g = g; % returns
    results.gamma = gamma;
    if doSim
        [results.rpe, results.value] = FixedWeights(x, w, B, gamma, b0);
    end
end
