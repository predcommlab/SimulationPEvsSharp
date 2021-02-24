function SE = se( inputVector )
% compute standart error
% SEM is usually estimated by the sample estimate of the population 
% standard deviation (sample standard deviation) divided by the square 
% root of the sample size (assuming statistical independence of the 
% values in the sample)

SE = std(inputVector)/sqrt(length(inputVector));

end

