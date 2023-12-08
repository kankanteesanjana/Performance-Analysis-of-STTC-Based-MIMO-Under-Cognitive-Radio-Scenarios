% Parameters
nSample = 1000;             % Number of samples
snrRange = 0:2:20;          % SNR range

% Generate random information signal
infoSignal = randi([0 1], nSample, 1);

% QAM modulation
M = 4;                         
modSignal = qammod(infoSignal, M);

% Initialize arrays
pf = zeros(size(snrRange));
pd = zeros(size(snrRange));
threshold = zeros(size(snrRange));  % Threshold array
presenceCount = zeros(size(snrRange));   % Counter for PU presence
absenceCount = zeros(size(snrRange));    % Counter for PU absence

% Perform cognitive radio operations for each SNR value
for i = 1:length(snrRange)
    % Add AWGN noise to the modulated signal
    snr = snrRange(i);
    noisySignal = awgn(modSignal, snr, 'measured');
    
    % QAM demodulation
    demodSignal = qamdemod(noisySignal, M);
    
    % Calculate PF and PD
    pf(i) = sum(demodSignal ~= 0 & infoSignal == 0) / sum(infoSignal == 0);  % False alarm
    pd(i) = sum(demodSignal ~= 0 & infoSignal == 1) / sum(infoSignal == 1);  % Detection
    
    % Calculate the noise power
    noisePower = var(noisySignal);
    
    % Calculate the threshold using energy detection
    threshold(i) = noisePower * chi2inv(0.99, 2);
    
    % Perform presence/absence detection
    numIterations = 10000;      % Number of Monte Carlo iterations
    
    for j = 1:numIterations
        % Add AWGN noise to the modulated signal
        noisySignal = awgn(modSignal, snr, 'measured');
        
        % Energy detection
        energy = abs(noisySignal).^2;
        
        % Check if energy is above threshold
        if max(energy) > threshold(i)
            presenceCount(i) = presenceCount(i) + 1;  % PU presence
        else
            absenceCount(i) = absenceCount(i) + 1;    % PU absence
        end
    end
end

% Calculate probabilities of PU presence and absence
pPresence = presenceCount / numIterations;
pAbsence = absenceCount / numIterations;

% Plot SNR vs PD
figure;
grid
plot(snrRange, pd, 'b-o');
xlabel('SNR (dB)');
ylabel('Probability of Detection (PD)');
title('SNR vs PD');

% Plot SNR vs PF
figure;
grid
plot(snrRange, pf, 'r-o');
xlabel('SNR (dB)');
ylabel('Probability of False Alarm (PF)');
title('SNR vs PF');

% Plot PD vs PF
figure;
plot(pf, pd, 'g-o');
xlabel('Probability of False Alarm (PF)');
ylabel('Probability of Detection (PD)');
title('PD vs PF');
set(gca,'XDir','reverse'); % Reverse the x-axis

% Plot Threshold vs SNR
figure;
grid
plot(snrRange, threshold, 'm-o');
xlabel('SNR (dB)');
ylabel('Threshold');
title('Threshold vs SNR');

% Plot SNR vs Probability of PU Presence
figure;
grid
plot(snrRange, pPresence, 'b-o');
xlabel('SNR (dB)');
ylabel('Probability of Primary User (PU) Presence');
title('SNR vs Probability of PU Presence');

% Plot SNR vs Probability of PU Absence
figure;
grid
plot(snrRange, pAbsence, 'r-o');
xlabel('SNR (dB)');
ylabel('Probability of Primary User (PU) Absence');
title('SNR vs Probability of PU Absence');
