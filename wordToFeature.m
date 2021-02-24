function feature = wordToFeature(word, feature_mat_words)
PRINT_DIAGNOSTICS = 0;

if PRINT_DIAGNOSTICS
    word
end

% Matrix multiplication
feature = word * feature_mat_words;


if PRINT_DIAGNOSTICS
    feature 
end
end