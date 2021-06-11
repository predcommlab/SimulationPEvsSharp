function compareModels_1D_AkaikeWeight
%% Load runs
% 1. load matrix with stored results: 10000x12
% 1:4 = behavioural resutls
% 5:8 = univariate results
% 13:16 = RSA results
path = './'

StoreSimulationIterationPC     = load([path 'StoreSimulationIterationPC_150506.mat']);
StoreSimulationIteration_sharp = load([path 'StoreSimulationIterationSharpening_150506.mat']);

%% Define experimental data
experimentalResultsB = [0.4345, 0.7917, 0.8353, 0.8968];      % Units: percent correct (range: [0 .. 1])
experimentalResultsU = [17.3646, 15.1538,  16.0689, 12.0767]; % pSTS % Units: beta-values ( > 0 )
experimentalResultsR = [-0.0038, 0.0124, 0.0137, -0.0032];    % pSTS Evans coordinate

% Normalize as in the simulationModel
experimentalResultsR = experimentalResultsR ./ max(experimentalResultsR);
experimentalResultsU = experimentalResultsU ./ max(experimentalResultsU);

%% Extract data per condition
runsPC_B = StoreSimulationIterationPC.StoreSimulationIteration(:,1:4);
runsPC_U = StoreSimulationIterationPC.StoreSimulationIteration(:,9:12);
runsPC_R = StoreSimulationIterationPC.StoreSimulationIteration(:,17:20);
runsSharp_B = StoreSimulationIteration_sharp.StoreSimulationIteration(:,1:4);
runsSharp_U = StoreSimulationIteration_sharp.StoreSimulationIteration(:,9:12);
runsSharp_R = StoreSimulationIteration_sharp.StoreSimulationIteration(:,17:20);

%% Define my_ksdensity
my_ksdensity = @(simulatedRuns, experimentalDataPoint) ksdensity(simulatedRuns, experimentalDataPoint, 'bandwidth', 0.1);

%% Compute LogLikelihood PC model
% get likelihood for each condition
[ProbPC_B_N4, ~, bwPC_B_N4] = my_ksdensity(runsPC_B(:,1), experimentalResultsB(1));
[ProbPC_B_M4, ~, bwPC_B_M4] = my_ksdensity(runsPC_B(:,2), experimentalResultsB(2));
[ProbPC_B_N12, ~, bwPC_B_N12] = my_ksdensity(runsPC_B(:,3), experimentalResultsB(3));
[ProbPC_B_M12, ~, bwPC_B_M12] = my_ksdensity(runsPC_B(:,4), experimentalResultsB(4));

LogLikelihoodB_PC = log(ProbPC_B_N4 * ProbPC_B_M4 * ProbPC_B_N12 * ProbPC_B_M12);

[ProbPC_U_N4, ~, bwPC_U_N4] = my_ksdensity(runsPC_U(:,1), experimentalResultsU(1));
[ProbPC_U_M4, ~, bwPC_U_M4] = my_ksdensity(runsPC_U(:,2), experimentalResultsU(2));
[ProbPC_U_N12, ~, bwPC_U_N12] = my_ksdensity(runsPC_U(:,3), experimentalResultsU(3));
[ProbPC_U_M12, ~, bwPC_U_M12] = my_ksdensity(runsPC_U(:,4), experimentalResultsU(4));

LogLikelihoodU_PC = log(ProbPC_U_N4 * ProbPC_U_M4 * ProbPC_U_N12 * ProbPC_U_M12);

[ProbPC_R_N4, ~, bwPC_R_N4] = my_ksdensity(runsPC_R(:,1), experimentalResultsR(1));
[ProbPC_R_M4, ~, bwPC_R_M4] = my_ksdensity(runsPC_R(:,2), experimentalResultsR(2));
[ProbPC_R_N12, ~, bwPC_R_N12] = my_ksdensity(runsPC_R(:,3), experimentalResultsR(3));
[ProbPC_R_M12, ~, bwPC_R_M12] = my_ksdensity(runsPC_R(:,4), experimentalResultsR(4));

LogLikelihoodR_PC = log(ProbPC_R_N4 * ProbPC_R_M4 * ProbPC_R_N12 * ProbPC_R_M12);

%% Compute LogLikelihood Sharpening model
% get likelihood for each condition
[ProbSharp_B_N4, ~, bwSharp_B_N4] = my_ksdensity(runsSharp_B(:,1), experimentalResultsB(1));
[ProbSharp_B_M4, ~, bwSharp_B_M4] = my_ksdensity(runsSharp_B(:,2), experimentalResultsB(2));
[ProbSharp_B_N12, ~, bwSharp_B_N12] = my_ksdensity(runsSharp_B(:,3), experimentalResultsB(3));
[ProbSharp_B_M12, ~, bwSharp_B_M12] = my_ksdensity(runsSharp_B(:,4), experimentalResultsB(4));

LogLikelihoodB_Sharp = log(ProbSharp_B_N4 * ProbSharp_B_M4 * ProbSharp_B_N12 * ProbSharp_B_M12);

[ProbSharp_U_N4, ~, bwSharp_U_N4] = my_ksdensity(runsSharp_U(:,1), experimentalResultsU(1));
[ProbSharp_U_M4, ~, bwSharp_U_M4] = my_ksdensity(runsSharp_U(:,2), experimentalResultsU(2));
[ProbSharp_U_N12, ~, bwSharp_U_N12] = my_ksdensity(runsSharp_U(:,3), experimentalResultsU(3));
[ProbSharp_U_M12, ~, bwSharp_U_M12] = my_ksdensity(runsSharp_U(:,4), experimentalResultsU(4));

LogLikelihoodU_Sharp = log(ProbSharp_U_N4 * ProbSharp_U_M4 * ProbSharp_U_N12 * ProbSharp_U_M12);

[ProbSharp_R_N4, ~, bwSharp_R_N4] = my_ksdensity(runsSharp_R(:,1), experimentalResultsR(1));
[ProbSharp_R_M4, ~, bwSharp_R_M4] = my_ksdensity(runsSharp_R(:,2), experimentalResultsR(2));
[ProbSharp_R_N12, ~, bwSharp_R_N12] = my_ksdensity(runsSharp_R(:,3), experimentalResultsR(3));
[ProbSharp_R_M12, ~, bwSharp_R_M12] = my_ksdensity(runsSharp_R(:,4), experimentalResultsR(4));

LogLikelihoodR_Sharp = log(ProbSharp_R_N4 * ProbSharp_R_M4 * ProbSharp_R_N12 * ProbSharp_R_M12);

%% compute Aikake weights
% get likelihoods for the two models
LikelihoodB_Sharp = (ProbSharp_B_N4 * ProbSharp_B_M4 * ProbSharp_B_N12 * ProbSharp_B_M12);
LikelihoodU_Sharp = (ProbSharp_U_N4 * ProbSharp_U_M4 * ProbSharp_U_N12 * ProbSharp_U_M12);
LikelihoodR_Sharp = (ProbSharp_R_N4 * ProbSharp_R_M4 * ProbSharp_R_N12 * ProbSharp_R_M12);

LikelihoodB_PC = (ProbPC_B_N4 * ProbPC_B_M4 * ProbPC_B_N12 * ProbPC_B_M12);
LikelihoodU_PC = (ProbPC_U_N4 * ProbPC_U_M4 * ProbPC_U_N12 * ProbPC_U_M12);
LikelihoodR_PC = (ProbPC_R_N4 * ProbPC_R_M4 * ProbPC_R_N12 * ProbPC_R_M12);

% compute evidence ratio of Akaike weights
AkaikeW_PCoverSharp_B = LikelihoodB_PC/LikelihoodB_Sharp
AkaikeW_PCoverSharp_U = LikelihoodU_PC/LikelihoodU_Sharp
AkaikeW_PCoverSharp_R = LikelihoodR_PC/LikelihoodR_Sharp

end