%Definimos los manejadores de las funciones.
function y = funciones()
    y.entrada = @entrada;
    y.calculo = @calculo;
    y.encoderConv = @encoderConv;
    y.ruido = @ruido;
    y.viterbi = @viterbi;
end

%Función que devuelve un vector de símbolos entre -1 y 1 de longitud igual a "cant".
function b = entrada(cant)
    b = 2*randi(2,1,cant)-3;
end

%{
Cálculo que realiza el encoder por cada símbolo b0, que produce una salida x1,x2.
La salida es un vector columna.
%}
function x = calculo(b0,b1,b2)
    x(1)=b0*b2;
    x(2)=b0*b1*b2;
    x=x';
end

%{
El vector mem guarda los valores de las memorias. Inicialmente se setean por defecto en [1,1].
temp es un vector que guarda las salidas temporalmente y luego se asignan a la matriz X, donde
se van guardan columna por columna. 
El primer valor de la columna es "x2j-1" y el segundo "x2j".
Los valores de la memoria son: mem(1) = bj-1 y mem(2) = bj-2.
%}
function x = encoderConv(b)
    mem = [1,1];
    for i=1:1:length(b)
        temp = calculo(b(i), mem(1), mem(2));
        x(1,i)=temp(1);
        x(2,i)=temp(2);
        mem(2) = mem(1);
        mem(1) = b(i);
    end
end

%{
Comentario
%}
function y = ruido(x, cant, SNR)
    temp=1/sqrt(2)*randn(1,cant*2);
    SNRv=10^(SNR/10)              
    No=1/SNRv                     
    temp=sqrt(No)*temp;                   
    n = [temp(1:cant);temp(cant+1:end)];
    y = x + n;
end

function y = viterbi()
    y = 1;
end
