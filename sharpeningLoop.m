function [countLoopSharp, sharp_word_Accumulated, posterior_word_Iterative] = ...
    sharpeningLoop(input_features, posterior_word_Iterative, feature_mat_words, ...
    sharp_update_weight, STOPcriterion_parameter)

% specify whether you want to see the figure during the loop
showFig = 0;

% initialize values for iterative loop
nWords         = size(feature_mat_words, 1);
countLoopSharp = 0;
stopCriterion  = 0;
sharp_word_Accumulated = zeros(1,nWords);

%sharp_update_weight = 0.01;

while stopCriterion < STOPcriterion_parameter %0.5
    % sharpening model: features
    prior_features_Iterative = wordToFeature(posterior_word_Iterative, feature_mat_words);
    
    sharp_feature = sharpenFeatures(input_features, prior_features_Iterative);
    
    if showFig
        figure;
        subplot(3,1,1);
        bar(input_features);
        title('(Updated) input features');
        subplot(3,1,2);
        bar(prior_features_Iterative);
        title('Prior features');
        subplot(3,1,3);
        bar(sharp_feature);
        title('Sharpened features');
    end
    
    % sharpening model: words
    sharp_word = featureToWord(sharp_feature, feature_mat_words);
    
    % compute tuning update: mixture of previous incoming information and
    % sharpened sensory input
    new_sharp_features = input_features + (sharp_update_weight * sharp_feature); %(1-prior_update_weight) * posterior_word_Iterative
    % norm so that sum = 12
    new_sharp_features = new_sharp_features ./ sum(new_sharp_features) * sum(input_features);
    
    input_features = new_sharp_features;
    % stop criterion: when there is a clear winner in the sharpened sensory input
    % How much does the maximum deviate from the mean of the other values?
    stopCriterion = max(sharp_word) - ((mean(sharp_word) +  std(sharp_word)));
    
    if countLoopSharp < 1;%00;%0
        % store accumulated sharpened representation across the iterations
        sharp_word_Accumulated = sharp_word_Accumulated + sharp_word - mean(sharp_word);   
    end
        
    countLoopSharp = countLoopSharp + 1;
    % stop loop, after x iterations
    if countLoopSharp  > 500
        break
    end
end
% save final prior after the iterations for the current condition
posterior_word_Iterative = featureToWord(input_features, feature_mat_words);
end