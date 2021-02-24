function normOutput = normalizeFeatureGroup2Prob(inputVector, clarity_level)
% This function transforms the features from the input vector into a probability
% i.e. only values > 0 and sum = 1 
% This is done for each of the 13 feature categories separately.
% We have 37 features that group into: 
% 1. consonant = 6*place  + 3*manner + 2*nasal + 2*voice
% 2. vowel     = 5*height + 2*back   + 2*round + 2*dipthong
% 3. consonant = 6*place  + 3*manner + 2*nasal + 2*voice

% The current clarity level defines the amount of signal and "1- clarity 
% level defines the noise. This noise is randomly split into propotions.
% The number of proporions is defined by the number of members within each
% feature group. These noise proportions are randomly added to all possible
% members within the feature group.

% split the 37 into the 13 components
featureGroups = [ones(6,1); ones(3,1)*2; ones(2,1)*3; ones(2,1)*4;...
    ones(5,1)*5; ones(2,1)*6; ones(2,1)*7; ones(2,1)*8; ...
    ones(6,1)*9; ones(3,1)*10; ones(2,1)*11; ones(2,1)*12];

normOutput = NaN(1,length(featureGroups));
for i_featureGroups = 1:length(featureGroups)    
    % define number of members of the current feature group
    n_FeatMembers = length(featureGroups(featureGroups == i_featureGroups));
    % specify noise and define set of proportions
    noise_temp = rand(1,n_FeatMembers);
    noise = (1-clarity_level) * (noise_temp/sum(noise_temp)); % should sum to (1-clarity_level)

    % pre-specify signal in sensory input
    normOutput_tmp = inputVector(featureGroups == i_featureGroups)*clarity_level;

    % store sensory input as signal/noise-probabilty
    normOutput(featureGroups == i_featureGroups) = normOutput_tmp + noise;
    clear normOutput_tmp  noise_temp noise
end

