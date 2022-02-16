function [rpes, value] = FixedWeights(x, w, B, gamma, b0)

    rpes = nan(numel(x),1);
    value = nan(numel(x),1);
    for t = 1:numel(x)
        b = B(t,:)';

        % TD update
        r = double(x(t)==3);        % reward
        rpe = r + w'*(gamma*b-b0);  % TD error        
        
        % store results
        rpes(t) = rpe;
        value(t) = w'*(b0); %estimated value
        b0 = b;
    end    
end
