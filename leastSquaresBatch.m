function results = leastSquaresBatch(x, O, T, gamma, doSim, doTD)
% function [w, B, g] = leastSquaresBatch(x, O, T, gamma)
% - x     - observations
% - O     - observation distribution
% - T     - transition distribution
% - gamma - discount factor
% 
% learns weights using Least Squares TD or Monte Carlo
% 
    if nargin < 4
        gamma = 0.98;
    end
    if nargin < 5
        doSim = false;
    end
    if nargin < 6
        doTD = true;
    end
    
    % get belief
    if ~isempty(O) && ~isempty(T)
        [B, b0] = getBeliefs(x, O, T);
    else
        B = CSC(x, 15); b0 = zeros(size(B,2),1);
        warning('Using CSC instead of beliefs.');
    end

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
    
    % Least Square TD or Monte Carlo
    % (finds weights using linear regression)
    ix = sum(B) > 0;
    Bc = B(:,ix);
    Bprev = [b0'; Bc(1:end-1,:)];
    w = (Bprev'*Bprev)\(Bprev'*g);
    if doTD
        Btot = Bprev - gamma*Bc;
        w = (Bprev'*Btot + 0.0*eye(size(Bprev,2)))\(Bprev'*r);
    end
    wc = zeros(size(B,2),1); wc(ix) = w; w = wc;
    
    results.w = w; % weights
    results.b0 = b0; % initial belief
    results.B = B; % beliefs
    results.g = g; % returns
    results.gamma = gamma;
    if doSim
        [results.rpe, results.value] = FixedWeights(x, w, B, gamma, b0);
    end
end
