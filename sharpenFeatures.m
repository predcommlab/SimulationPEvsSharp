function sharp_feature = sharpenFeatures(sensory_inputProb, prior_features)
% sharpening model: features * multiplicative gain
sharp_feature_NoNorm = ...
    (sensory_inputProb .* (1 + prior_features));

sharp_feature = sharp_feature_NoNorm ./sum(sharp_feature_NoNorm) * 12;
end