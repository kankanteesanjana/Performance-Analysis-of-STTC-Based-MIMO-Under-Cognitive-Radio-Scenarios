modulationOrders = [4, 16, 32, 64, 256];

for m = 1:length(modulationOrders)
    M = modulationOrders(m);
    k = log2(M);
    
    trellis = poly2trellis([5 4], [23 35 0; 0 5 13]);
    traceBack = 32;
    codeRate = 1/2;
    convEncoder = comm.ConvolutionalEncoder('TrellisStructure', trellis);
    vitDecoder = comm.ViterbiDecoder('TrellisStructure', trellis, ...
        'InputFormat', 'Hard', 'TracebackDepth', traceBack);
    chan = comm.RayleighChannel('SampleRate', 1e4, 'MaximumDopplerShift', 100);
    
    errorRate = comm.ErrorRate('ReceiveDelay', 2 * traceBack);
    
    ebnoVec = 0:2:20;
    errorStats = zeros(length(ebnoVec), 3);
    
    for n = 1:length(ebnoVec)
        snr = ebnoVec(n) + 10 * log10(k * codeRate);
        while errorStats(n, 2) <= 100 && errorStats(n, 3) <= 1e7
            dataIn = randi([0 1], 10000, 1);
            dataEnc = convEncoder(dataIn);
            txSig = qammod(dataEnc, M, ...
                'InputType', 'bit', 'UnitAveragePower', true);
            rxSig = awgn(txSig, snr);
            demodSig = qamdemod(rxSig, M, ...
                'OutputType', 'bit', 'UnitAveragePower', true);
            dataOut = vitDecoder(demodSig);
            errorStats(n, :) = errorRate(dataIn, dataOut);
        end
        reset(errorRate)
    end
    
    berUncoded = berawgn(ebnoVec', 'qam', M);
    semilogy(ebnoVec, errorStats(:, 1), 'o-');
    hold on;
end

grid on;
legend('4-QAM', '16-QAM', '32-QAM', '64-QAM', '256-QAM');
xlabel('Eb/No (dB)');
ylabel('Bit Error Rate');
axis([0 20 1e-5 1]);
title('Bit Error Rate Curves for Different QAM Modulation Orders');
