function [x, fval] = fitParameters()
% specify options
x0 = [0.3559    0.5825    0.0341    0.4070    1.3270    0.0028] % PC model

% parametersToFit = logical([0 1 0 0 0 0 1]);
% specify which parameters are free (i.e. varied during fitting) and which
% are fixed during fitting.
% 1 = varied
% 0 = fixed
parametersToFit = logical([1 1 1 1 1 1]);
fitUnivariateError  = 1;
fitBehaviouralError = 1;
fitRSAError         = 0;

% some further default values 
xmin = [0 0 0 0 0 0];
xmax = [1 1 1 5 10 1];
parameterNames = { ...
    'lowClarity', ...
    'highClarity', ...
    'prior_update_weight', ...
    'STOPcriterion', ...
    'temperature', ...
    'behaviour_noise'}; %#ok<NASGU>

% some preparatory work
lowerBounds = createLowerBounds();
upperBounds = createUpperBounds();
errorsToFit = [fitUnivariateError, fitBehaviouralError, fitRSAError];

% do the fit!
[x, fval] = fminsearchcon(@objectiveFunction, x0, lowerBounds, upperBounds);

% helper functions
    function error = objectiveFunction(x)
        error = simulationModel_withPrecision(x, false, false, errorsToFit);
    end

    function lowerBounds = createLowerBounds()
        lowerBounds = x0;
        lowerBounds(parametersToFit) = xmin(parametersToFit);
    end

    function upperBounds = createUpperBounds()
        upperBounds = x0;
        upperBounds(parametersToFit) = xmax(parametersToFit);
    end
end