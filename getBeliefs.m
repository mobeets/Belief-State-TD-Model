function [B, b0] = getBeliefs(x, O, T, b0)
    if nargin < 4
        S = size(T,1); % number of states
        b = zeros(S,1); b(end) = 1; % initial belief state
        b0 = b;
    end
    b = b0;
    B = nan(numel(x), size(T,2));
    impossibleEvents = 0;
    for t = 1:length(x)
        b = b'*(T.*squeeze(O(:,:,x(t))));
        b = b'./sum(b);
        if any(isnan(b))
            b = b0;
            b = ones(S,1)/S;
            impossibleEvents = impossibleEvents + 1;
        end
        B(t,:) = b;
    end
    if impossibleEvents
        warning(['Found ' num2str(impossibleEvents) ...
            ' impossible events (in terms of belief).']);
    end
end
