#!/bin/bash
#
## Script para ver o status da maquina. 
## Chamadas, processamento, memoria, processos rodando no momento
#
#date: 16/06/2015
#@by Samuel Dantas 

export LC_ALL=C
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

# Caminho para o diretorio de log
LOGDIR='/var/log/machineStats/'
# Nome do arquivo de log
LOG=$LOGDIR'machineStats.log'

# DECLARAR O INTERVALO EM QUE O SCRIPT IRA RODAR
INTERVAL=2 ; export INTERVAL

# Criando diretorio de log caso nao exista
if [ ! -d "$LOGDIR" ] ; then
	sudo mkdir $LOGDIR ; touch $LOG 
fi

# Permissao para arquivo de log
sudo chmod 777 -R $LOG

#
# - Definindo funcoes para cada cor que sera usada (cores com negrito)
#
## DO
## Black
makeBlack(){
	echo -e "\e[01;30m$1\e[00m"
}
## Red
makeRed(){
	echo -e "\e[01;31m$1\e[00m"
}
## Green
makeGreen(){
	echo -e "\e[01;32m$1\e[00m"
}
## Yellow
makeYellow(){
	echo -e "\e[01;33m$1\e[00m"
}
## Blue
makeBlue(){
	echo -e "\e[01;34m$1\e[00m"
}
## Magenta
makeMagenta(){
	echo -e "\e[01;35m$1\e[00m"
}
## Ciano
makeCiano(){
	echo -e "\e[01;36m$1\e[00m"
}
## White
makeWhite(){
	echo -e "\e[01;37m$1\e[00m"
}
## Sublinhado
makeSub(){
	echo -e "\e[04;37m$1\e[00m"
}

## DONE



# Variavel equivalente a seta (=>) colorida
SETA=`makeBlue "=>"`

#
# Funcao para escrever o relatorio/log dos status 
#
writeStats(){
echo -e "\e[00;42;37m                                                     [$1]                                                        \e[00m 
$1 - Cpu Load        $SETA `getCpuLoad` 
$1 - Mem Used/Free   $SETA `getMem`
$1 - Raiz Used/Free  $SETA `getRaiz`
$1 - Active Channels $SETA `getChannels`
$1 - Active Calls    $SETA `getCalls`
$1 - Top process MEM $SETA `getTopMem`
$1 - Top process CPU $SETA `getTopCpu`\n" >> $LOG
}

#
# Funcao para pegar o Load Average do CPU, e quantidade de cores que tem na maquina
#
getCpuLoad(){
	# Capturando os campos do load average que resultam do comando uptime
	CPU_LOAD=`uptime | awk '{print $10" "$11" "$12}'`	
	# O arquivo cpuinfo contem quantos nucleos a maquina tem, conto a saida dele usando wc
	QTD_CPU=`cat /proc/cpuinfo | egrep -e "processor" | wc -l`
	# Formatando o retorno com o load e a quantidade de cpus
	Info="$CPU_LOAD (Cpus: $QTD_CPU)"
	makeSub "$Info"	
}

#
# Funcao para pegar quanto tem de memoria livre e qual eh o total de memoria ram na maquina
# 
getMem(){
	# Capturando os campos que contem o total de ram usado e livre com o comando free
	MEM_LOAD=`free -h | grep "Mem" | ""egrep -e "[0-9]M" | awk '{print $3" / "$4}'`
	# Capturando o campo que contem a capacidade maxima de memoria ram
	MEM_TOTAL=`free -h | grep "Mem" | ""egrep -e "[0-9]M" | awk '{print $2}'`
	# Formatando o retorno com os dados used/free e a capacidade total
	Info="$MEM_LOAD (Cap: $MEM_TOTAL)"
	makeSub "$Info"	
}

#
# Funcao para capturar quanto tenho de espaco na particao raiz (/) e quanto tem de capacidade
#
getRaiz(){
	# Capturando os campos que comtem o da particao raiz  (/) usado e livre com o comando df
	RAIZ_LOAD=`df -h / | grep "/dev" | awk '{print $3" / "$4}'`
	# Captutando o campo que contem a capacidade maxima da particao raiz (/)
	RAIZ_TOTAL=`df -h / | grep "/dev" | awk '{print $2}'`
	# Formatando o retorno com os dados used/free e a capacidade total
	Info="$RAIZ_LOAD (Cap: $RAIZ_TOTAL)"
	makeSub "$Info"
}

#
# Funcao para verificar quantos canais eu tenho ativos no asterisk (pbx usado pelo servidor)
#
getChannels(){
	# Coletando a quantidades de canais ocupados no pbx com o comando do asterisk 'core show channels'
	ACTIVE_CHANNELS=`asterisk -rx "core show channels" | egrep -e "active channels" | awk '{print $1}'`
	makeSub $ACTIVE_CHANNELS
}

#
# Funcao para verificar quantas chamadas estao ativas, fora os canais ativos sao as chamadas estabelecidas
#
getCalls(){
	ACTIVE_CALLS=`asterisk -rx "core show channels" | egrep -e "active calls" | awk '{print $1}'`
	makeSub $ACTIVE_CALLS
}

#
# Funcao para ver os processo que estao consumindo mais memoria
#
getTopMem(){
	# Aqui pego com ps axo ordenando por memoria e exibindo apenas o comando que esta rodando, separo em uma linha por ponto e virgula e leio com o read separando assim pelo ";"
	TOP_MEM=`ps axo %mem,cmd | sort -nr | head -n 5 | awk '{print $2}' | sed ':a;N;s/\n/;/g;ta' | while IFS=";" read a b c d e; do  makeRed "$a"    ;  makeYellow "$b" ;  makeGreen "$c" ;  makeBlue "$d" ; makeCiano "$e" ; done | sed ':a;N;s/\n/  |  /g;ta'`
	echo -e "$TOP_MEM"	
}

getTopCpu(){
	TOP_CPU=`ps axo %cpu,cmd | sort -nr | head -n 5 | awk '{print $2}' | sed ':a;N;s/\n/;/g;ta' | while IFS=";" read a b c d e; do  makeRed "$a"    ;  makeYellow "$b" ;  makeGreen "$c" ;  makeBlue "$d" ; makeCiano "$e" ; done | sed ':a;N;s/\n/  |  /g;ta'`
	echo -e "$TOP_CPU"
}

#
# Main 
#
main(){
while :; do
	writeStats "`date +"%Y-%m-%d %H:%M:%S"`"
	sleep $INTERVAL
done
}

### Chamando a funcao main ###
main 
######
