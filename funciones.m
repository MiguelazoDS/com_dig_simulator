function y = funciones()
    y.entrada = @entrada;
    y.encoderConv = @encoderConv;
    y.ruido = @ruido;
end

function B = entrada(cant)
    %B = 2*randi(2,1,cant)-3;
    B = [1,-1,-1,1,1];
end

%{
Los valores de salida en la matriz "X" se van guardando por columna,
la primera son los dos valores del primer símbolo y así sucesivamente.
El primer valor de la columna es "x2j-1" y el segundo "x2j".
Los valores de la memoria son: mem(1) = bj-1 y mem(2) = bj-2.
%}
function X = encoderConv(B)
    mem = [1,1];
    for i=1:1:length(B)
        X(1,i)=B(i)*mem(2);
        X(2,i)=B(i)*mem(1)*mem(2);
        mem(2) = mem(1);
        mem(1) = B(i);
    end
end

%{
Comentario
%}
function N = ruido(cant, SNR)
    temp=1/sqrt(2)*randn(1,cant*2);
    SNRv=10^(SNR/10);               
    No=1/SNRv;                     
    temp=sqrt(No)*temp;                   
    N = [temp(1:cant);temp(cant+1:end)];
end
