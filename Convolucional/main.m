F = funciones();
cant_simb=80000;
it=10;
SNR = zeros(1,it);
BER = zeros(1,it);
B = F.entrada(cant_simb); 
X = F.encoderConv(B);
for i=1:1:it
    SNR(i)=0.2*i;
    Y = F.ruido(X,cant_simb,SNR(i));
    Z = F.viterbi(Y, cant_simb, 4, 20);
    dif = abs(B-Z);
    errores = sum(dif)/2;
    BER(i)=(errores/cant_simb)
end
F.graficar(SNR,BER)