function [B, b0] = getBeliefs(x, O, T, b0)
    if nargin < 4
        S = size(T,1); % number of states
        b = zeros(S,1); b(end) = 1; % initial belief state
        b0 = b;
    end
    B = nan(numel(x), size(T,2));
    for t = 1:length(x)
        b = b'*(T.*squeeze(O(:,:,x(t))));
        b = b'./sum(b);
        B(t,:) = b;
    end
end
