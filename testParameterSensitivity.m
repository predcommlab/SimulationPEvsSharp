function testParameterSensitivity(parameterToVary, errorsToReturn)
 
bestX = [0.3559 0.5825 0.03414 0.407 1.327 0.00281] % final PC model
%bestX = [0.2456 0.4094 0.002022 2.198 2.556 0.01057] % final Sharpening Model

switch parameterToVary
    case 1
        testRange = 0.5;
        testStepSize = 0.1;
        maxValue = 1;
        minValue = 0;
    case 2
        testRange = 0.5;
        testStepSize = 0.1;
        maxValue = 1;
        minValue = 0;
    case 3
        testRange = 0.05;
        testStepSize = 0.01;
        maxValue = 0.1;
        minValue = 0;
    case 4
        testRange = 5;
        testStepSize = 0.5;
        maxValue = 5;
        minValue = 0;
    case 5
        testRange = 5;
        testStepSize = 0.5;
        maxValue = 10;
        minValue = 0;
    case 6
        testRange = 0.005;
        testStepSize = 0.001;
        maxValue = 1;
        minValue = 0;

end

startValue = bestX(parameterToVary);
parameterNames = { ...
    'lowClarity', ...
    'highClarity', ...
    'prior_update_weight', ...
    'STOPcriterion', ...
    'temperature', ...
    'behaviour_noise',...    
    };

testParameterValues = createTestParameterValues();
fitResults = zeros(size(testParameterValues));
for i = 1:numel(testParameterValues)
    x = createParameterVector(testParameterValues(i));
    fitResults(i) = simulationModel_withPrecision(x, false, false, errorsToReturn);
end

% plot
hold on;
plot(testParameterValues, fitResults);
plot(startValue, fitResults(find(testParameterValues == startValue)), 'rx'); %#ok<FNDSB>
title(['Sensitivity for ''' parameterNames{parameterToVary} ''' with ' createErrorNameString()]);

    function testParameterValues = createTestParameterValues()
        myRange = 0:testStepSize:testRange;
        myRange(1) = [];
        testParameterValues = [startValue - myRange, startValue, startValue + myRange];
        testParameterValues = sort(testParameterValues);
        outOfRange = testParameterValues > maxValue | testParameterValues < minValue;
        testParameterValues(outOfRange) = [];
    end

    function x = createParameterVector(testParameterValue)
        x = bestX;
        x(parameterToVary) = testParameterValue;
    end

    function string = createErrorNameString()
        if errorsToReturn(1)
            string = 'univariate Error';
        elseif errorsToReturn(2)
            string = 'behavioural Error';
        elseif errorsToReturn(3)
            string = 'RSA Error';
        else
            string = '';
        end
    end
end