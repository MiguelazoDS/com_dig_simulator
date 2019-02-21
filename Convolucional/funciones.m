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


function Z = viterbi(Y)
    TRUNK = 20;                 
    N = 4;                      %Estados
    simbolos = length(Y);
    inf= 9e99;
    %DETECCION
    v_costos = inf*ones(N,2);
    v_costos(1,1)=0;
    m_path = inf*ones(N,N);
    m_state = inf*ones(N,1);
    k=0;
    for j = 1:1:simbolos

        %Calcular caminos
        m_path = calcularCaminos(v_costos, Y(:,j));

        [v_costos, v_state] = elegirCamino(v_costos, m_path);

        m_state =  [m_state, v_state];
        if j ==1
            m_state = m_state(:,2);
        end

        if length(m_state) >=TRUNK
            k=k+1;
            [Z(k), m_state]=tracebackSimple(m_state, v_costos(:,2));

        end

        v_costos = [v_costos(:,2) , inf*ones(N,1)];     %%Avanza en la matriz de costos
        m_path = inf*ones(N,N);
    end

    T = tracebackFull(m_state, v_costos(:,1));
    if isempty(Z)
        Z =  T;
    else
        Z = [Z T];
    end
end


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


function costo = costoRama(e,s,y)

    E = estado(e);
    c = calculo(s,E(1),E(2));
    costo = sum(y.*c);

end


function [v_costos, state] = elegirCamino(v_costos, path)
    inf=9e99;
    state = zeros(4,1);
    v_costos(:,2)= inf*ones(4,1);
    for e2 = 1:1:4
        maxCost=-inf;
        ePrev=0;
        for e1 = 1:1:4
            if path(e1,e2) <inf
                camino = v_costos(e1,1)+path(e1,e2);
                if(camino>maxCost)
                    maxCost=camino;
                    ePrev=e1;
                end
            end
        end
        v_costos(e2,2)=maxCost;
        state(e2)=ePrev;

    end
end


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
    m_state = m_state(:,2:end);   %Elimina la primer columna, simula desplazamiento de ventana

end


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
