echo "qual a placa?" ; read PLACA
ifconfig -a | cut -d ":" -f 1 | grep $PLACA # verifica se a placa existe
if [ $? -eq 0 ]; then # se existir executa isso
    echo "informe o IP" ; read IP
    IP1=`echo $IP | cut -d "." -f1` # separa o ip pra examinar
    IP2=`echo $IP | cut -d "." -f2`
    IP3=`echo $IP | cut -d "." -f3`
    IP4=`echo $IP | cut -d "." -f4`
    if [ $IP1 -ge 0 -a $IP1 -le 255 ]; then # verifica o ip pra saber se é válido
        if [ $IP2 -ge 0 -a $IP2 -le 255 ]; then
            if [ $IP3 -ge 0 -a $IP3 -le 255 ]; then
                if [ $IP4 -ge 0 -a $IP4 -le 255 ]; then
                    echo "qual a classe?" ; read CLASSE
                    if [ $CLASSE -eq 8 ]; then # verifica a classe para atribuir uma máscara
                        MASCARA=255.0.0.0
                    elif [ $CLASSE -eq 16 ]; then
                        MASCARA=255.255.0.0
                    elif [ $CLASSE -eq 24 ]; then
                        MASCARA=255.255.255.0
                    else
                        echo "classe errada"
                    fi
                    echo "placa principal?" ; read PRINCIPAL
                    if [ $PRINCIPAL == "sim" ]; then # se a placa for a principal pergunta o Default Gateway?
                        echo "Default Gateway?" ; read GW
                    else
                        GW=""
                    fi
                else # se algum campo ed ip estiver errado exibe o erro
                    echo "IP inválido 04"
                fi
            else
                echo "IP inválido 03"
            fi
        else
            echo "IP inválido 02"
        fi
    else
        echo "IP inválido 01"
    fi
else # se a placa não existitr exibe o erro
    echo "a placa não existe"
fi

# configura o ip em tempo real
ifconfig $PLACA $IP
ifconfig $PLACA down
ifconfig $PLACA up

# configura o ip para inicialização
echo -e "auto $PLACA\niface $PLACA inet static" >> /etc/network/interfaces
echo -e "	address $IP\n	netmask $MASCARA\n    gateway $GW" >> /etc/network/interfaces

#configura o GW caso tenha escolhido essa opção
if [ $GW != "" ]; then
    route del default
    route add default gw $IP
fi
