%Definimos los manejadores de las funciones.
function y = funciones()
    y.entrada = @entrada;
    y.calculo = @calculo;
    y.detOpt = @detOpt;
    y.ruido = @ruido;
    y.viterbi = @viterbi;
    y.graficar = @graficar;
end

%Función que devuelve un vector de símbolos entre -1 y 1 de longitud igual a "cant".
function b = entrada(cant)
    b = 2*randi(2,1,cant)-3;
end

%{
Cálculo que realiza el encoder por cada símbolo b0, que produce una salida x.
%}
function x = calculo(b0,b1,b2)
    x = 0.2*b0+b1+0.3*b2;
end

%{
El vector mem guarda los valores de las memorias. Inicialmente se setean 
por defecto en [1,1].
Para cada entrada b corresponde un valor de salida x.
Los valores de la memoria son: mem(1) = bj-1 y mem(2) = bj-2.
%}
function x = detOpt(b)
    mem = [1,1];
    n = length(b);

    for i=1:1:n
        x(i) = calculo(b(i), mem(1), mem(2));
        mem(2) = mem(1);
        mem(1) = b(i);
    end
end

%{
Adición de ruido al vector de salida del detOpt.
%}
function y = ruido(x, cant, SNR)
    n=1/sqrt(2)*randn(1,cant);
    SNRv=10^(SNR/10);              
    No=1/SNRv;                   
    n=sqrt(No)*n;                   
    y = x + n;
end

%{
La salida del algoritmo pretende ser un vector igual al que ingreso al encoder.
En la primera iteración no hay estado previo, entonces limpia lo que sale de 
v_state.
Luego si la matriz m_state, donde se van guardando todos los estados previos,
Supera el tamaño de la ventana comienza a decodificar el primer valor, reduciendo
el tamaño de la matriz m_path.
Luego mueve la segunda columna de la matriz v_costo a la primera (esta columna
se va actualizando en la función elegirCamino) y limpia la matriz m_path.
Cuando la matriz m_state no supera el tamaño de la ventana se realiza el traceback
completo de toda esa matriz.
%}
function Z = viterbi(Y, cant_simb, cant_est, ventana)
    inf= 9e99;
    v_costos = inf*ones(cant_est,2);
    v_costos(1,1)=0;
    m_path = inf*ones(cant_est,cant_est);
    m_state = inf*ones(cant_est,1);
    k=0;

    for j = 1:1:cant_simb
        m_path = calcularCaminos(v_costos, Y(j));
        [v_costos, v_state] = elegirCamino(v_costos, m_path);
        m_state =  [m_state, v_state];

        if j ==1
            m_state = m_state(:,2);
        end

        if length(m_state) >=ventana
            k=k+1;
            [Z(k), m_state]=tracebackSimple(m_state, v_costos(:,2));
        end

        v_costos = [v_costos(:,2) , inf*ones(cant_est,1)];  
        m_path = inf*ones(cant_est,cant_est);
    end

    T = tracebackFull(m_state, v_costos(:,1));

    if isempty(Z)
        Z =  T;
    else
        Z = [Z T];
    end
end

%{
Observa en la primera columna de la matriz costos si algún valor es menor a inf 
(inicialmente el 1,1), para comenzar el proceso desde algún estado. 
Luego calcula el costo hacia los próximos estados partiendo del estado representado
por el índice e1.
El costo lo guarda en una matriz path donde representa con las filas el estado 
inicial y con las columnas el estado final.
%}
function path = calcularCaminos(costos, y)
    inf=9e99;
    path = inf*ones(4,4);
    for e1 = 1:1:4
        if costos(e1,1)<inf
            %Llega 1
            e2 = proximoEstado(e1,1);
            path(e1,e2) = costoRama(e1,1,y);

            %Llega -1
            e2 = proximoEstado(e1,-1);
            path(e1,e2) = costoRama(e1,-1,y);
        end
    end
end

%{
Recibe un índice y devuelve un estado.
%}
function E = estado(e)
    switch e
        case 1
            E = [1 1];
        case 2
            E = [-1 1];
        case 3
            E = [1 -1];
        case 4 
            E = [-1 -1];
        otherwise
            E = [999 999];
    end
end

%{
Recibe un índice y un valor de entrada. Devuelve un índice
correspondiente al estado de salida.
%}
function nextE = proximoEstado(e, s)
    if s== 1
        switch e
            case 1
                nextE = 1;
            case 2
                nextE = 3;
            case 3
                nextE = 1;
            case 4
                nextE = 3;
        end
    end

    if s == -1
        switch e
            case 1
                nextE = 2;
            case 2
                nextE = 4;
            case 3
                nextE = 2;
            case 4
                nextE = 4;
        end
    end
end

%{
Utiliza el concepto de mínima distancia para el cálculo de la métrica de 
rama.
%}
function costo = costoRama(e,s,y)
    E = estado(e);
    c = calculo(s,E(1),E(2));
    costo = abs(y-c);
end

%{
Va recorriendo por columna la matriz path recibida desde viterbi. Si el valor es 
menor que infinito, guarda en camino el costo en guardado en la primera 
columna de v_costos más el valor de la matriz path, actualiza la varable minCost 
y guarda el estado previo.
Antes de continuar con la siguiente columna guarda el menor costo y el estado previo 
en la segunda columna de la matriz v_costos.
%}
function [v_costos, state] = elegirCamino(v_costos, path)
    inf=9e99;
    state = zeros(4,1);
    v_costos(:,2)= inf*ones(4,1);
    
    for e2 = 1:1:4
        minCost=inf;
        ePrev=0;
        for e1 = 1:1:4
            if path(e1,e2) <inf
                camino = v_costos(e1,1)+path(e1,e2);
                if(camino<minCost)
                    minCost=camino;
                    ePrev=e1;
                end
            end
        end
        v_costos(e2,2)=minCost;
        state(e2)=ePrev;
    end
end

%{
Toma la matriz de costos y busca el valor mínimo, toma ese índice y se ubica 
en la última columna de la matriz de estados. Esto indica que desde e1 se llegó 
a e2.
Luego mediante un for realiza los mismos pasos yendo hacia el comienzo de la matriz,
Nuevamente indica que desde e1 se llegó a e2. El valor que entra para que de e1 se 
pase a e2 es el primer valor de e2. Es decir el que se guarda en S.
Luego se elimina la primer fila de m_state.
%}
function [S , m_state] = tracebackSimple(m_state, v_costos)
    L = length(m_state);
    [m, ind] = min(v_costos);
    e2= ind;
    e1= m_state(e2,L);

    for i = L-1:-1:1
        e2 = e1;
        e1= m_state(e2,i);
    end

    E = estado(e2);
    S = E(1);
    m_state = m_state(:,2:end);
end

%{
Muy similar al caso anterior, pero ahora se guardan todos los valores provocan se
pase de un estado al siguiente.
%}
function [S] = tracebackFull(m_state, v_costos)
    L = length(m_state);
    [m, ind] = min(v_costos);
    e2= ind;
    e1= m_state(e2,L);
    E = estado(e2);
    S = E(1);

    for i = L-1:-1:1
        e2 = e1;
        e1= m_state(e2,i);
        E = estado(e2);
        S = [E(1) , S];
    end
end

%{
Recibe dos vectores (SNR y BER) y grafica.
%}
function graficar(SNR, BER)
    figure
    semilogy(SNR,BER,'-o')
    grid on
    title('BER vs SNR')
    xlabel('SNR (dB)')
    ylabel('BER')
end
