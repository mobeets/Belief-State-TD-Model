function plotRPEs(x, ISIdistributionMatrix, results)
    
    x = x(1:size(results.w,1));
    ISIdistributionMatrix = ISIdistributionMatrix(1:sum(x==3));
    
    RewardIndices=find(x==3);
    RewardIndices=RewardIndices(length(ISIdistributionMatrix)*0.4:end); % only look at trials after 2000 trials
    ISIsforplot=ISIdistributionMatrix(length(ISIdistributionMatrix)*0.4:end); % only look at trials after 2000 trials

    RewardRPE=results.rpe(RewardIndices);

    % Average RPEs (and standard error) for each ISI length
    for i=1:9
        averageRPE(i)=sum(RewardRPE(find(ISIsforplot==i+4)))/length(find(ISIsforplot==i+4));
        errorRPE(i)=std(RewardRPE(find(ISIsforplot==i+4)))/sqrt(length(find(ISIsforplot==i+4)));
    end

    % Plotting average RPE and standard error for each ISI
    for i=1:9
        errorbar(i, averageRPE(i), errorRPE(i),'k')
        hold on
        plot(i, averageRPE(i), '.','Color',[1-i*.1 i*.1 1],'markersize',25)
        hold on
    end

    xlabel('time of reward delivery','fontSize',20)
    ylabel('Average TD error','fontSize',20)
end