function [MSS_error, simulated_behavioural_results, MSS_error_univariate, ...
    MSS_error_behavioural, MSS_error_RSA, ...
    distanceMatMatch, distanceMatNeutral] = ...
    simulationModel_withPrecision(parameters, showBarFig, showImageFig, errorsToReturn)

% Simulation:
% This script simulates the process of 2 models 1. predictive coding (PC)
% and 2. Sharpening for perception of neutral and expected words and their
% corresponding features.
% The model simulates 3 outcomes:
% 1. behavioural outocme (same for PC and Sharpening)
% 2. univariate results (same for PC and Sharpening)
% 3. RSA resutls (DIFFERENT for PC and Sharpening ?)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% make specifications
type         = 'PC';
%type         = 'sharp';

if nargin == 4
    returnUnivariateError  = errorsToReturn(1);
    returnBehaviouralError = errorsToReturn(2);
    returnRSAError         = errorsToReturn(3);
elseif nargin == 3
    returnUnivariateError  = 0;
    returnBehaviouralError = 1;
    returnRSAError         = 0;
elseif nargin == 2
    showImageFig = 0;
    returnUnivariateError  = 0;
    returnBehaviouralError = 1;
    returnRSAError         = 0;
    
elseif nargin == 1    
    showBarFig   = 1;
    showImageFig = 0;    
    returnUnivariateError  = 0;
    returnBehaviouralError = 1;
    returnRSAError         = 0;
    
    %% end specifications
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if strcmp(type, 'PC')
    loopFunction = @predictiveCodingLoop_withPrecision;
    figureTitle  = 'Predictive Coding';
else
    loopFunction = @sharpeningLoop;
    figureTitle  = 'Sharpening';
end

% actual behavioural values
% order: Neutral 4, Match 4, Neutral 12, Match 12
behavioural_results = [0.4345, 0.7917, 0.8353, 0.8968]; % Units: percent correct (range: [0 .. 1])
univariate_results  = [17.3646, 15.1538,  16.0689, 12.0767]; % pSTS % Units: beta-values ( > 0 )
RSA_results  = [-0.0028, 0.0082, 0.0128, 0.0001]; % pSTS

%% parameters - these can be passed to the function
lowClarity      = parameters(1);     
highClarity     = parameters(2);     
prior_update_weight = parameters(3); % how much is the Prediction error weigted to update the prior?
STOPcriterion       = parameters(4); % when does the iteration loop stop? Different for PC and sharpening
temperature         = parameters(5); % inhibitory and excitatory influences to form the prior
behaviour_noise     = parameters(6); % how much noise to add to the responses?

rng('default');  % seed the random number generator so that results are replicable...

%% these words were used in the experiment
% wordlist = {'thing', 'sing', 'sit',...
%     'deep', 'peep', 'peak', ...
%     'bath', 'path', 'pass', ...
%     'pork', 'fork', 'fort', ...
%     'doom', 'tomb', 'tooth', ...
%     'take', 'shake', 'shape', ...
%     'kite', 'tight', 'type', ...
%     'zone', 'moan', 'mode'};
% these are the words corresponsing to the words used in the experiment
% $ was repalced with D
phonemelist = {'TIN', 'sIN', 'sIt', ...
    'dip', 'pip', 'pik', ...
    'b#T', 'p#T', 'p#s', ...
    'pDk', 'fDk', 'fDt', ...
    'dum', 'tum', 'tuT', ...
    't1k', 'S1k', 'S1p', ...
    'k2t', 't2t', 't2p', ...
    'z5n', 'm5n', 'm5d'};
nPhonemes = numel(phonemelist);

% transform words into features
feature_mat_words = word2phoneme(phonemelist);

%% 1. set priors
% neutral = all words equally probable
prior_neutral_word = ones(1,nPhonemes) * 1/nPhonemes;
% 288 match + 48 mismatch (for 24 words)
% weaken the prior because participants forget the written words
written_report     = 0.8214; % exact value foram mean behaviour is 0.8214
diagonal_value     = (288*written_report)/(288+48);
off_diagonal_value = (1-diagonal_value) / 23;
prior_match_word   = MatProb(nPhonemes, diagonal_value, off_diagonal_value);

for rep1 = 1:21 % loop through 21 subjects
    for rep2 = 1:6 % loop through 6 runs
        
        %% generate sensory input and noise
        %scale = 10;%1/3; % standard deviation of the noise
        % loop through different clarity levels:
        countClarity = 1;
        for clarity_level = [lowClarity highClarity]
            
            %% generation of normalized of sensory input as probabilites (sum = 1, [0;1]
            % loop through words to transform each word into prabability for its feature groups
            for w = 1:nPhonemes
                sensory_inputProb(w,:) = normalizeFeatureGroup2Prob(feature_mat_words(w,:),clarity_level);
            end
            
            %% START MODEL
            % dimensions = n(words) x n(clarity levels) x n(features)/n(words)
            nWords = nPhonemes;
            for v = 1:nWords
                
                % measurement noise for words, normally distributed
                noiseWord_match_m1   = randn(size(prior_match_word))*2;
                noiseWord_neutral_m1 = randn(size(prior_match_word))*2;
                
                %% neutral
                % Run Predictive Coding loop or Sharpening loop
                [...
                    IterationCounter(1, countClarity, v, rep1, rep2), ...
                    neutral_word_Accumulated(v, countClarity, :, rep1, rep2), ...
                    prior_neutral_word_Iterative] = ...
                    loopFunction(sensory_inputProb(v,:), prior_neutral_word, ...
                    feature_mat_words, prior_update_weight, STOPcriterion); %#ok<AGROW>
                
                % Prepare behavioural decoding
                % 1. transform to probability
                prior_neutral_word_Iterative = softmax(prior_neutral_word_Iterative, temperature);
                % 2. store posterior for all conditions/repetitions
                posterior_neutral(v, countClarity, :, rep1, rep2) = prior_neutral_word_Iterative'; %#ok<AGROW> % store final perceptual representation
                
                %% match
                % Run Predictive Coding loop or Sharpening loop
                [...
                    IterationCounter(2, countClarity, v, rep1, rep2), ...
                    match_word_Accumulated(v, countClarity, :, rep1, rep2), ...
                    posterior_match_word_Iterative] = ...
                    loopFunction(sensory_inputProb(v,:), prior_match_word(v,:), ...
                    feature_mat_words, prior_update_weight, STOPcriterion); %#ok<AGROW>
                
                % add measurement noise to "PC error signal"/"sharp signal"
                % for RSA analysis:
                match_word_Accumulated(v, countClarity, :, rep1, rep2) = ...
                    squeeze(match_word_Accumulated(v, countClarity, :, rep1, rep2)) + noiseWord_match_m1(v,:)';
                
                neutral_word_Accumulated(v, countClarity, :, rep1, rep2) = ...
                    squeeze(neutral_word_Accumulated(v, countClarity, :, rep1, rep2)) + noiseWord_neutral_m1(v,:)';
                
                % Prepare behavioural decoding
                % 1. transform to probability
                posterior_match_word_Iterative = softmax(posterior_match_word_Iterative, temperature);
                % 2. store posterior for all conditions/repetitions
                posterior_match(v, countClarity, :, rep1, rep2) = posterior_match_word_Iterative'; %#ok<AGROW> % store final perceptual representation
            end
            % increase clarity counter
            countClarity  = countClarity +1;
        end
    end
end

%% Compute univariate results
% 5 dimensions:
% 1. 2 conditions: Neutral/Match,
% 2. 2 x Clarity levels,
% 3. 24 words (v)
% 4. 21 subjects (rep1)
% 5. 6 runs (rep2)
% avegrage over runs, subjects and words
% to get number of iterations per noise level and condition
IterationCounterMean = mean(mean(mean(IterationCounter, 3), 4), 5);

%% Plot univariate results
if showBarFig
    
    IterationCounterMeanPerCondition = squeeze(mean(mean(IterationCounter, 3), 5));
    IterationCounterse = se(squeeze(...
        [IterationCounterMeanPerCondition(1,1,:)...
        IterationCounterMeanPerCondition(1,2,:)...
        IterationCounterMeanPerCondition(2,1,:)...
        IterationCounterMeanPerCondition(2,2,:)])');
    
    % 1. plot univariate results based on iterations
    figure;bar([IterationCounterMean(1,1), IterationCounterMean(2,1), ...
        IterationCounterMean(1,2), IterationCounterMean(2,2)]);
    hold on; errorbar([IterationCounterMean(1,1), IterationCounterMean(2,1), ...
        IterationCounterMean(1,2), IterationCounterMean(2,2)], ...
        [IterationCounterse(1,1), IterationCounterse(1,3), ...
        IterationCounterse(1,2), IterationCounterse(1,4)], '.');
    title(['Univariate: ' figureTitle ' - number of iterations']);
    set(gca, 'Xtick',1:4)
    set(gca, 'XTickLabel',{'neutral 4 channel', 'match 4 channel', ...
        'neutral 12 channel', 'match 12 channel'})
    ylabel('number of iterations')
    ylim([0 500])
end

%% Decode behavior

for r1 = 1:rep1
    %for r2 = 1:rep2
    behaviour_neutral_LowClarity(r1)  = decodeBehavior(squeeze(mean(posterior_neutral(:,1,:,r1),5)), behaviour_noise); %#ok<AGROW>
    behaviour_neutral_HighClarity(r1) = decodeBehavior(squeeze(mean(posterior_neutral(:,2,:,r1),5)), behaviour_noise); %#ok<AGROW>
    behaviour_match_LowClarity(r1)    = decodeBehavior(squeeze(mean(posterior_match(:,1,:,r1),5)), behaviour_noise); %#ok<AGROW>
    behaviour_match_HighClarity(r1)   = decodeBehavior(squeeze(mean(posterior_match(:,2,:,r1),5)), behaviour_noise); %#ok<AGROW>
end

%% Plot behavioural results
if showBarFig
    % SE after Loftus and Masson (1994) = the same for all conditions
    se4condition = se([behaviour_neutral_LowClarity', behaviour_match_LowClarity', ...
        behaviour_neutral_HighClarity', behaviour_match_HighClarity']);
    figure; bar([mean(behaviour_neutral_LowClarity), mean(behaviour_match_LowClarity),...
        mean(behaviour_neutral_HighClarity),mean(behaviour_match_HighClarity)]);
    hold on; errorbar([mean(behaviour_neutral_LowClarity), mean(behaviour_match_LowClarity), ...
        mean(behaviour_neutral_HighClarity), mean(behaviour_match_HighClarity)], ...
        [se4condition(1,1), se4condition(1,2), ...
        se4condition(1,3), se4condition(1,4)], '.');
    title(['Behavioural: ' figureTitle]);
    set(gca, 'Xtick',1:4)
    set(gca, 'XTickLabel',{'neutral 4 channel', 'match 4 channel', ...
        'neutral 12 channel', 'match 12 channel'})
    ylim([0 1.1])
    ylabel('% correct responses')
end

%% simulate RSA
experimental_setup.rep1 = rep1;
experimental_setup.rep2 = rep2;
experimental_setup.nPhonemes = nPhonemes;

results.match_word   = match_word_Accumulated;
results.neutral_word = neutral_word_Accumulated;
% within condition (i.e.: match-match and neutral-neutral)
% distance matrix with condition order: 4ch-run1, 12ch-run1, 4ch-run2, 12ch-run2
[simulated_RSA_results, distanceMatMatch_4ch, distanceMatMatch_12ch, ...
    distanceMatNeutral_4ch, distanceMatNeutral_12ch] = ...
    simulateRSAwithinConditionTest_spearman(experimental_setup, results, figureTitle, showBarFig, showImageFig);
distanceMatMatch   = [distanceMatMatch_4ch, distanceMatMatch_12ch];
distanceMatNeutral = [distanceMatNeutral_4ch, distanceMatNeutral_12ch];

%% compute goodness of fit
% initialize overall error to 0
MSS_error = 0;
fittedString = '';

% compute discrepancy between actual and simulated univariate
% 1. collect simulation data
simulated_univariate_results = [IterationCounterMean(1,1), IterationCounterMean(2,1), ...
    IterationCounterMean(1,2), IterationCounterMean(2,2)];
% 2. normalize simulation data & experimental data
% (normalize max to 1)
univariate_results = univariate_results ./ max(univariate_results);
simulated_univariate_results = simulated_univariate_results ./ 500;% max(simulated_univariate_results);

% 3. compute error (sum of squares)
MSS_error_univariate = sum((univariate_results - simulated_univariate_results).^2);
% 4. store error
if returnUnivariateError
    MSS_error = MSS_error + MSS_error_univariate;
    fittedString = [fittedString 'errUniv = ' num2str(MSS_error_univariate), '; '];
end

% compute discrepancy between actual and simulated behaviour
% 1. collect simulation data
simulated_behavioural_results = [mean(behaviour_neutral_LowClarity), mean(behaviour_match_LowClarity),...
    mean(behaviour_neutral_HighClarity),mean(behaviour_match_HighClarity)];
% 2. normalize simulation data & experimental data
% (normalization not necessary since both are already percentages)
% 3. compute error (sum of squares)
MSS_error_behavioural = sum((behavioural_results - simulated_behavioural_results).^2);
% 4. store error
if returnBehaviouralError
    MSS_error = MSS_error + MSS_error_behavioural;
    fittedString = [fittedString 'errBehav = ' num2str(MSS_error_behavioural), '; '];
end

% compute discrepancy between actual and simulated RSA
% 1. collect simulation data
% (already collected in simulated_RSA_results)
% 2. normalize simulation data & experimental data
% (normalize max to 1)
RSA_results = RSA_results ./ max(RSA_results);
simulated_RSA_results = simulated_RSA_results ./ max(simulated_RSA_results);
% 3. compute error (sum of squares)
MSS_error_RSA = sum((RSA_results - simulated_RSA_results).^2);
% 4. store error
if returnRSAError
    MSS_error = MSS_error + MSS_error_RSA;
    fittedString = [fittedString 'errRSA = ' num2str(MSS_error_RSA), '; '];
end

disp(['Ran ' type ' simulationModel. x = ' mat2str(parameters, 4) '; ' fittedString]);
