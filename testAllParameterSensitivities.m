function testAllParameterSensitivities()
numParameters = 6;
figure;
for i = 1:numParameters
    subplot(numParameters,3,3*(i-1)+1);
    testParameterSensitivity(i,[1 0 0]);
    subplot(numParameters,3,3*(i-1)+2);
    testParameterSensitivity(i,[0 1 0]);
    subplot(numParameters,3,3*(i-1)+3);
    testParameterSensitivity(i,[0 0 1]);
end
end