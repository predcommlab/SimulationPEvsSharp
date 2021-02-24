function word = featureToWord(feature, feature_mat_words)
PRINT_DIAGNOSTICS = 0;

if PRINT_DIAGNOSTICS
    feature
end

% Transpose multiplication / correlation without normalization
word = feature * feature_mat_words';

if PRINT_DIAGNOSTICS
    word 
end
end
