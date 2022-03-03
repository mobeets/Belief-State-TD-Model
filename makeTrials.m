function trials = makeTrials(nTrials, pOmission, ITIhazard, ...
    ISIcdf, firstRewardIndex, minITI, omissionsHaveImaginaryISI)
    % Generate sequence of observations that corresponds to trials
    % Observations:
    %   Null --> 1
    %   Odor ON --> 2
    %   Reward --> 3
    if nargin < 6
        minITI = 0;
    end
    if nargin < 7
        omissionsHaveImaginaryISI = false;
    end
    
    if nTrials > 0 % training trials
        % Create distribution of ISI's - 10% unassigned are omission trials
        % Possible ISIs range from 5-13
        nOmission = floor(pOmission*nTrials);
        ISIs = nan(nTrials,1); % omission trials are 'nan'
        isOmission = true(nTrials,1);
        for i = 1:nTrials
            ISIs(i) = sum(ISIcdf < rand) + firstRewardIndex;
            if i <= (nTrials-nOmission) 
                isOmission(i) = false;
            end
        end
        
        % randomly permute
        [~,idx] = sort(rand(size(ISIs)));
        ISIs = ISIs(idx); isOmission = isOmission(idx);
        ITIs = minITI + geornd(ITIhazard, nTrials, 1);
    else
        % test trials - make one trial per condition
        nTrials = numel(ISIcdf) + 1;
        ISIs = [firstRewardIndex + (1:numel(ISIcdf))-1 firstRewardIndex];
        isOmission = false(size(ISIs)); isOmission(end) = true;
        ITIs = 10*ones(nTrials, 1);
    end
    if ~omissionsHaveImaginaryISI
        ISIs(isOmission) = 0;
    end
    
    trials.x = makeObservations(ITIs, ISIs, isOmission);
    trials.ISIs = ISIs;
    trials.ITIs = ITIs;
    trials.isOmission = isOmission;
end

function x = makeObservations(ITIs, ISIs, isOmission)
    x = [];
    for i = 1:numel(ITIs)
        ITI = ones(1,ITIs(i));
        ISI = ones(1,ISIs(i));
        if isOmission(i) % omission trial
            trial = [2; ISI'; ITI'];
        else % reward trial
            trial = [2; ISI'; 3; ITI'];
        end
        x = [x; trial];
    end
    x = [1; 1; 1; x]; % prepend an ITI
end

