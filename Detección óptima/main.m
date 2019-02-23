F = funciones();
cant_simb=80000;
it=5;
SNR = zeros(1,it);
BER = zeros(1,it);
for i=1:1:it
    SNR(i)=0.2*i;
    B = F.entrada(cant_simb); 
    X = F.detOpt(B);
    Y = F.ruido(X,cant_simb,SNR(i));
    Z = F.viterbi(Y);
    Norma = abs(B-Z);
    errores = 0.5*sum(Norma);
    BER(i)=(errores/cant_simb)
end
F.graficar(SNR,BER)
