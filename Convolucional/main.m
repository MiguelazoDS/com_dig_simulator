F = funciones();
cant_simb=8000;
it=5;
SNR = zeros(1,it);
BER = zeros(1,it);
for i=1:1:it
    SNR(i)=i;
    B = F.entrada(cant_simb); 
    X = F.encoderConv(B);
    Y = F.ruido(X,length(X),i);
end
