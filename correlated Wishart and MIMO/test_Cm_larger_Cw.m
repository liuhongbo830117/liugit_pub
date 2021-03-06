%{
Copyright (c) 2019, Yiliang Liu
Department of Electronics Information Engineering, Harbin Institute of Technology, China
All rights reserved.

This code is used to provide the test of C_m is much larger than C_w in [1].

[1] Artificial Noisy MIMO Systems under Correlated Scattering Rayleigh
Fading -- A Physical Layer Security Approach.

Please change SNR and s to get corresponding results in Fig. 2
Since the code is very time-consuming, I suggest you record results in
Excel or other texts.

Parameter:

    Nr: the number of receive antenna.
    Nt: the number of transmit antenna.
    Ne: the number of eavesdrop antenna.
    n: the freedom degree of a Whishart matrix HH'(H'H).
    m: the scatter of a Whishart matrix HH'(H'H).
    secrecy_rate_monte: the Monte Carlo results.
    secrecy_rate_numerical: the numerical results.
    s: the number of eigen-subchannels for messages.
    aoa: AoA.
    ras: RAS.
    dl: normaized antenna distance.


%}
clear all;
close all;

%% System parameter setting
syms x l k;
nsample = 1e+05;
s = 2;
snr = -10:1:0;
secrecy_rate_monte = zeros(1,length(snr));
secrecy_rate_numerical = zeros(1,length(snr));
secrecy_rate_real = zeros(1,length(snr));
sc = zeros(nsample,1);
sc_real = zeros(nsample,1);
ratio = zeros(1,length(snr));

%% Channel model
Nt = 6;
Nr = 6;
Ne = 4;
m = max(Nr,Nt);
n = min(Nr,Nt);
n1 = min(Ne,Nt-s);
n2 = min(Ne,Nt);
Hm = (randn(Nr,Nt,nsample)+j*randn(Nr,Nt,nsample))/sqrt(2); % main channel
He = (randn(Ne,Nt,nsample)+j*randn(Ne,Nt,nsample))/sqrt(2); % wiretap channel

%% Correlation parameter setting
raoa = 30/180*pi;
ras = 10/180*pi;
dl = 0.8;

%% Correlated matrix (must be equal to myeigenpdf.m)
for a = 1:Nr
    for b = 1:Nr
        R(a,b)=exp(-j*2*pi*(b-a)*dl*sin(raoa))*exp(-1/2*(2*pi*(b-a)*dl*cos(raoa)*ras)^2);
    end
end

for a = 1:Ne
    for b = 1:Ne
        Re(a,b)=exp(-j*2*pi*(b-a)*dl*sin(raoa))*exp(-1/2*(2*pi*(b-a)*dl*cos(raoa)*ras)^2);
    end
end
cnumber = 0;
number = 0; % Record the c_m<c_w
%% Simulation begin
for ii = 1:1:length(snr)
    for i = 1:1:nsample 
        P = 10.^(snr(ii)/10.); % Transmit power
        Hc = R^(1/2)*Hm(:,:,i);
        [u, d, v] = svd(Hc'*Hc); % SVD of main channel
        B = u(:,1:s); % Information precoding
        Z = u(:,(s+1):Nt); % AN signal precoding
        H1=Hc*B;
        H2=Re^(1/2)*He(:,:,i)*B;
        H3=Re^(1/2)*He(:,:,i)*Z;
        H4=[H2 H3];
        c1(i)=log2(det(eye(Ne)+(P/Nt)*(H4*H4')));
        c2(i)=log2(det(eye(Ne)+(P/Nt)*(H3*H3')));
        c3(i)=log2(det(eye(Nr)+(P/Nt)*(H1*H1')));
        sc(i)=c3(i)+c2(i)-c1(i);
        if sc(i)<0
            sc_real(i) = 0;
            number = number+1;
        else
            sc_real(i)= sc(i);
        end
    end
    secrecy_rate_monte(ii) = real(mean(sc));
    secrecy_rate_real(ii) = real(mean(sc_real));
    ratio(ii) =  secrecy_rate_monte(ii)/secrecy_rate_real(ii);
end

x = 1:1:10;
p1 = plot(x,ratio(x),'r-','Linewidth',2);
set(gca,'FontSize',14,'FontName','Times New Roman');






