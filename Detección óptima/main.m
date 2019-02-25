F = funciones();
cant_simb=100000;
it=10;
SNR = zeros(1,it);
BER = zeros(1,it);
B = F.entrada(cant_simb);
X = F.detOpt(B);
for i=1:1:it
    SNR(i)=i;
    Y = F.ruido(X,cant_simb,SNR(i));
    Z = F.viterbi(Y, cant_simb, 4, 20);
    dif = abs(B-Z);
    errores = sum(dif)/2;
    BER(i)=(errores/cant_simb)
end
F.graficar(SNR,BER)