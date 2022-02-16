function info = getExperiment(pOmission, ITIhazard, cue)
    if nargin < 1
        pOmission = 0.1;
    end
    if nargin < 2
        % Set hazard rate of transitioning OUT of the ITI
        ITIhazard = 1/65; % = 13/0.2 = ITI's lambda / bin size
    end
    if nargin < 3
        cue = 1;
    end

    % Gaussian probability distribution and cumulative probability distribution
    if cue == 1
        r_times = [1.2 1.4 1.6 1.8 2 2.2 2.4 2.6 2.8];
        ps = normpdf(r_times, 2, 0.5);
        ISIpdf = ps/sum(ps);        
        firstRewardIndex = 5;
    elseif cue == 2
        ISIpdf = 1;
        firstRewardIndex = 5;
    elseif cue == 2
        ISIpdf = 1;
        firstRewardIndex = 13;
    else
        error('Not implemented!');
    end
    ISIcdf = cumsum(ISIpdf);

    % Calculate hazard rate of receiving reward after substates 5-14 (ISIhazard);
    % Used later to create transition matrix
    ISIhazard = [];
    ISIhazard(1) = ISIpdf(1);
    for i = 2:length(ISIpdf)
        ISIhazard(i) = ISIpdf(i)/(1-ISIcdf(i-1));
    end
    
    info.pOmission = pOmission;
    info.ISIhazard = ISIhazard;
    info.ITIhazard = ITIhazard;
    info.ISIpdf = ISIpdf;
    info.ISIcdf = ISIcdf;
    info.firstRewardIndex = firstRewardIndex;
    info.O = getObservation(ITIhazard, pOmission);
    info.T = getTransition(firstRewardIndex, ISIhazard, ITIhazard, pOmission);
end

function O = getObservation(ITIhazard, pOmission)
    % states:
    % ISI = 1-14
    % ITI = 15
    
    %Fill out the observation matrix O
    % O(x,y,:) = [a b c]
    % a is the probability that observation 1 (null) was observed given that a
    % transition from sub-state x-->y just occurred
    % b is the probability that observation 2 (odor ON) was observed given that
    % a transition from sub-state x-->y just occurred
    % c is the probability that observation 2 (reward) was observed given that
    % a transition from sub-state x-->y just occurred

    O=zeros(15,15,3);

    %ISI
    O(1,2,:) = [1 0 0];
    O(2,3,:) = [1 0 0];
    O(3,4,:) = [1 0 0];
    O(4,5,:) = [1 0 0];
    O(5,6,:) = [1 0 0];
    O(6,7,:) = [1 0 0];
    O(7,8,:) = [1 0 0];
    O(8,9,:) = [1 0 0];
    O(9,10,:) = [1 0 0];
    O(10,11,:) = [1 0 0];
    O(11,12,:) = [1 0 0];
    O(12,13,:) = [1 0 0];
    O(13,14,:) = [1 0 0];

    %obtaining reward
    O(14,15,:) = [0 0 1];
    O(13,15,:) = [0 0 1];
    O(12,15,:) = [0 0 1];
    O(11,15,:) = [0 0 1];
    O(10,15,:) = [0 0 1];
    O(9,15,:) = [0 0 1];
    O(8,15,:) = [0 0 1];
    O(7,15,:) = [0 0 1];
    O(6,15,:) = [0 0 1];


    %stimulus onset
    O(15,1,:) = [0 1 0]; %rewarded trial
    O(15,15,2) = ITIhazard*pOmission; %omission trial

    %ITI
    O(15,15,1) = 1-(ITIhazard*pOmission);

end

function T = getTransition(firstRewardIndex, ISIhazard, ITIhazard, pOmission)
    %Fill out the transition matrix T
    %T(x,y) is the probability of transitioning from sub-state x-->y
    T=zeros(15,15);

    %odor ON from substates 1-6
    %no probability of transitioning out of ISI while odor ON
    T(1,2) = 1;
    T(2,3) = 1;
    T(3,4) = 1;
    T(4,5) = 1;
    T(5,6) = 1;

    %T(ISIsubstate_i+6-->ISIsubstate_i+7) = ISIhazard(i)
    %these substates span the variable ISI interval
    %if reward is received, then transition into the ITI
    for i = 1:length(ISIhazard)
         T(firstRewardIndex+i,firstRewardIndex+i+1) = 1-ISIhazard(i);
         T(firstRewardIndex+i,15) = ISIhazard(i);
    end
    T(14,15) = 1;

    % ITI length is drawn from exponential distribution in task
    % this is captured with single ITI substate with high self-transition
    % probability
    T(15,15) = 1 - (ITIhazard*(1-pOmission));
    T(15,1) = ITIhazard*(1-pOmission);
end
