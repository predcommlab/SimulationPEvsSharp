function behaviour = decodeBehavior(wordPosteriors, behavioral_noise)
nWords = size(wordPosteriors, 1);
noisyWordPosteriors = wordPosteriors + (randn(nWords,nWords) .* behavioral_noise);

% pick the maximum item as the response for each row/word
binary_behaviour = noisyWordPosteriors == kron(ones(1,nWords),max(noisyWordPosteriors,[],2));
% calculate percentage of correct responses (i.e., words on the diagonal)
behaviour = sum(sum(binary_behaviour .* eye(nWords),2))/nWords;
