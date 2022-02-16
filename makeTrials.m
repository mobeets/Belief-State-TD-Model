function trials = makeTrials(nTrials, pOmission, ITIhazard, ISIcdf, firstRewardIndex)
    % Generate sequence of observations that corresponds to trials
    % Observations:
    %   Null --> 1
    %   Odor ON --> 2
    %   Reward --> 3
    
    if nTrials > 0 % training trials
        % Create distribution of ISI's - 10% unassigned are omission trials
        % Possible ISIs range from 5-13
        nOmission = floor(pOmission*nTrials);
        ISIdistributionMatrix = nan(nTrials,1); % omission trials are 'nan'
        for i = 1:(nTrials-nOmission)
            ISIdistributionMatrix(i) = sum(ISIcdf < rand) + firstRewardIndex;
        end
        ISIdistributionMatrix = ISIdistributionMatrix(randperm(numel(ISIdistributionMatrix)));

        ITIdistributionMatrix = geornd(ITIhazard, nTrials, 1);
    else
        % test trials - make one trial per condition
        nTrials = numel(ISIcdf) + 1;
        ISIdistributionMatrix = [firstRewardIndex + (1:numel(ISIcdf))-1 nan];
        ITIdistributionMatrix = 20*ones(nTrials, 1);
    end
    
    trials.x = makeObservations(ITIdistributionMatrix, ISIdistributionMatrix);
    trials.ISIs = ISIdistributionMatrix;
    trials.ITIs = ITIdistributionMatrix;
end

function x = makeObservations(ITIdistributionMatrix, ISIdistributionMatrix)
    x = [];
    for i = 1:numel(ITIdistributionMatrix)
        ITI = ones(1,ITIdistributionMatrix(i));
        if ~isnan(ISIdistributionMatrix(i)) % reward delivery trial
            ISI = ones(1,ISIdistributionMatrix(i));
            trial = [2; ISI'; 3; ITI'];
        else % omission trial
            trial=[2; ITI'];
        end
        x = [x; trial];
    end
    x = [1; 1; 1; x]; % prepend an ITI
end

