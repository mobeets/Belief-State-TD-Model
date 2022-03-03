function X = CSC(x, K)
    X = zeros(numel(x), K);
    I = eye(K);
    for t = 1:numel(x)
        if x(t) == 2
            inds = t:min([size(X,1), (t+K-1)]);
            X(inds,:) = I(inds - t + 1,:);
%             X(inds,:) = X(inds,:) + I(inds - t + 1,:);
        end
    end
end
