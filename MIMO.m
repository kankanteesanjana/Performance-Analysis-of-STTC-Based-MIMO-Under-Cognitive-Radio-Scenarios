clc
clear all
close all
N = 10^6;
Eb_No = [0:20];
nTx = 2;
nRx = 2;

for ii = 1:length(Eb_No)
    %Transmitter
    Rands = rand(1,N)>0.5;
    S = 2*Rands-1;
    %Alamouti
    Stbc = 1/sqrt(2)*kron(reshape(S,2,N/2),ones(1,2));
    %channel
    Ray_ch = 1/sqrt(2)*[randn(nRx,N) + j*randn(nRx,N)];
    wh_gau = 1/sqrt(2)*[randn(nRx,N) + j*randn(nRx,N)];

    y=zeros(nRx,N);
    s_Rx = zeros(nRx*2,N);
    No_Ray = zeros(nRx*2,N);
    for kk =1:nRx

        No_Ray = kron(reshape(Ray_ch(kk,:),2,N/2),ones(1,2));
        temp = No_Ray;
        No_Ray(1,[2:2:end]) = conj(temp(2,[2:2:end]));
        No_Ray(2,[2:2:end]) =-conj(temp(1,[2:2:end]));

        %channel
        y(kk,:) = sum(No_Ray.*Stbc,1) + 10^(-Eb_No(ii)/20)*wh_gau(kk,:);

        %receiver
        s_Rx([2*kk-1:2*kk],:) = kron(reshape(y(kk,:),2,N/2),ones(1,2));

        %forming the equalization matrix
        Nos_Eq([2*kk-1:2*kk],:) = No_Ray;
        Nos_Eq(2*kk-1,[1:2:end]) = conj(Nos_Eq(2*kk-1,[1:2:end]));
        Nos_Eq(2*kk,  [2:2:end]) = conj(Nos_Eq(2*kk,  [2:2:end]));
    end

    %equalization
    Nos_Eqpower = sum(Nos_Eq.*conj(Nos_Eq),1);
    EQ_s = sum(Nos_Eq.*s_Rx,1)./Nos_Eqpower;
    EQ_s(2:2:end) = conj(EQ_s(2:2:end));

    %receiver
    S_EQ_s = real (EQ_s)>0;

    %count of error
    No_Err(ii) = size(find([Rands- S_EQ_s]),2);
end

sim_Ber = No_Err/N;
EbNo_1 = 10.^(Eb_No/10);
theoryBer_nRx1 = 0.5.*(1-1*(1+1./EbNo_1).^(-0.5));

p = 1/2 -1/2*(1+1./EbNo_1).^(-1/2);
theoryBerMrc_nRx2 = p.^2.*(1+2*(1-p));

pAlamouti = 1/2 - 1/2*(1+2./EbNo_1).^(-1/2);
theoryBerAlamouti_nTx2_nRx1 = pAlamouti.^2.*(1+2*(1-pAlamouti));

close all
figure
semilogy(Eb_No,theoryBer_nRx1,'bp-','LineWidth',2);
hold on
semilogy(Eb_No,theoryBerMrc_nRx2,'Kd-','LineWidth',2);
semilogy(Eb_No,theoryBerAlamouti_nTx2_nRx1,'c+-','Linewidth',2);
semilogy(Eb_No,sim_Ber,'mo-','Linewidth',2);
%axis([0 25 10^-5 0.5])
grid on
legend('(nTx=1,nRx=1)','(nTx=1, nRx=2)', '(nTx=2, nRx=1)', '(nTx=2, nRx=2)');
xlabel('Eb/No(dB)');
ylabel('bit error rate');
