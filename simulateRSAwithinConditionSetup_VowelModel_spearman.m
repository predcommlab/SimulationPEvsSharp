function [dist_4ch, dist_12ch, rs_4ch, ps_4ch, rs_12ch, ps_12ch] = ...
    simulateRSAwithinConditionSetup_VowelModel_spearman(experimental_setup, wordMatrix, conditionName, modelName, showFig)
% This function calculates the similarity and dissimilarity values
% for the 4 different combinations WITHIN conditions
% Neutral4, Match 4, Neutral 12, Match 12
% and the distance matrix with conditions in this order AVERAGED ACROSS RUNS:
% Neutral4, Match 4, Neutral 12, Match 12

% Input : experimental_setup, wordMatrix, conditionName, modelName, showFig
% Output: similarity and dissimiliarity matrices for the 4 conditions
% and the disctance matrix with the dimensions subjects x n items x n items

rep1 = experimental_setup.rep1;
rep2 = experimental_setup.rep2;
nPhonemes = experimental_setup.nPhonemes;

% size is 24 words x 2 clarity x 24 wordEvidences x n=rep repetitions
% reshape data so that new dimensions are
% 48 words (24 channel 4 + 24 channel 12) x 24 wordEvidences x n=rep repetitions
wordMAT_4ch = reshape(wordMatrix(:,1,:,:), nPhonemes, nPhonemes, rep1, rep2);
wordMAT_12ch = reshape(wordMatrix(:,2,:,:), nPhonemes, nPhonemes, rep1, rep2);

%VowelTripleNanDiag = [NaN 0 0; 0 NaN 0 ; 0 0 NaN ];
VowelTripleNanDiag = [0 0 0; 0 0 0 ; 0 0 0 ];
VowelCondNanDiag = [VowelTripleNanDiag, ones(3,21);...
    ones(3,3),  VowelTripleNanDiag, ones(3,18);...
    ones(3,6),  VowelTripleNanDiag, ones(3,15);...
    ones(3,9),  VowelTripleNanDiag, ones(3,12);...
    ones(3,12), VowelTripleNanDiag, ones(3,9);...
    ones(3,15), VowelTripleNanDiag, ones(3,6);...
    ones(3,18), VowelTripleNanDiag, ones(3,3);...
    ones(3,21), VowelTripleNanDiag];

% compute distance between word representations
for s = 1:rep1
    % compute similarity for each subject (s)
    % order of condition in the distance matrix:
    % 4ch all runs, 12 ch all runs
    
    % average across runs
    dist_4ch(s,:,:) = squareform(pdist(mean(wordMAT_4ch(:,:,s,:),4), 'correlation')); % #ok<AGROW>
    dist_12ch(s,:,:) = squareform(pdist(mean(wordMAT_12ch(:,:,s,:),4), 'correlation')); % #ok<AGROW>

    searchlightRDMs_4ch = squareform(squeeze(dist_4ch(s,:,:))');    
    % spearman correlation
    [rs_4ch(s), ps_4ch(s)] = corr(searchlightRDMs_4ch', squareform(VowelCondNanDiag)',...
        'type', 'Spearman', 'rows', 'pairwise');
    % [rs, ps] = corr(searchlightRDM', modelRDMs_ltv', 'type', 'Spearman', 'rows', 'pairwise');
    % Fisher transformation
    rs_4ch(s) = fisherTransform(rs_4ch(s));
    
    searchlightRDMs_12ch = squareform(squeeze(dist_12ch(s,:,:))');    
    % spearman correlation
    [rs_12ch(s), ps_12ch(s)] = corr(searchlightRDMs_12ch', squareform(VowelCondNanDiag)',...
        'type', 'Spearman', 'rows', 'pairwise');
    % [rs, ps] = corr(searchlightRDM', modelRDMs_ltv', 'type', 'Spearman', 'rows', 'pairwise');
    % Fisher transformation
    rs_12ch(s) = fisherTransform(rs_12ch(s));
end

%% plot average similarity across subjects
if showFig
    maxFig = max(max(max([dist; dist])));
    dist_meanSubj = squeeze(mean(dist,1));
    figure;
    imagesc(dist_meanSubj);
    caxis([0,maxFig]);
    colorbar;
    title([conditionName ' ' modelName]);
end