function [countLoopPE, PE_word_Accumulated, posterior_word_Iterative] = ...
    predictiveCodingLoop_withPrecision(sensory_inputProb, prior_word_Iterative, feature_mat_words, ...
    prior_update_weight, STOPcriterion)

% initialize values for iterative loop
nWords      = size(feature_mat_words, 1);
countLoopPE = 0;
sumPE       = 10;
PE_word_Accumulated = zeros(1,nWords);

prior_features_Iterative = wordToFeature(prior_word_Iterative, feature_mat_words);

% estimate precisions of prior and sensory input
precision_word_prior = std(prior_word_Iterative/sum(prior_word_Iterative));
precision_sensory    = std(sensory_inputProb/sum(sensory_inputProb));

while sumPE > STOPcriterion
    
    % compute prediction error for features (here 37 dimensions for full set)
    PE_feature = sensory_inputProb - prior_features_Iterative;
    
    % compute predicion error for words (here 24 dimensions for full set)
    PE_word = featureToWord(PE_feature, feature_mat_words);
    
    % compute precition of the Prediction Error
    % Precision of PE depends on the precisions of its constituents:
    % precision_sensory = low + precision_word_prior = low
    %     => precision PE = low
    % precision_sensory = high + precision_word_prior = low (or reverse)
    %     => precision PE = medium
    % precision_sensory = high + precision_word_prior = high
    %     => precision PE = high
    precision_PE = precision_sensory + precision_word_prior;
    
    % compute updated word representation
    % = word prior + (word PE * weight * precision)
    updated_word_prior = prior_word_Iterative + ...
        (prior_update_weight * precision_PE * PE_word);
    prior_word_Iterative     = updated_word_prior;
    
    % transform word prior from word to feature level
    prior_features_Iterative = wordToFeature(prior_word_Iterative, feature_mat_words);
    
    % get prediction error on word level from first iteration
    if countLoopPE < 1
        PE_word_Accumulated = PE_word_Accumulated + abs(PE_word);
    end
    
    % check stop criterion for iteration
    sumPE = sum(abs(PE_word));
    countLoopPE = countLoopPE + 1;
    % store_sumPE(countLoopPE) = sumPE;
    % stop loop, after x iterations
    if countLoopPE >= 500
        break
    end
end
posterior_word_Iterative = prior_word_Iterative;
end
