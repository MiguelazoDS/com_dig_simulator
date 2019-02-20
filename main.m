F = funciones();
simbolos=10;
iteraciones=5;
for i=1:1:iteraciones
    B = F.entrada(simbolos); 
    X = F.encoderConv(B);
    N = F.ruido(length(X),1);
    Y = X + N;
    disp(X);
end
