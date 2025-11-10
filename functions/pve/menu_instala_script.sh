#!/bin/bash

# Menu para instalar/desinstalar script na inicialização

instala_script(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala verificação de scripts na inicialização ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Desinstala verificação de scripts na inicialização ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
		1) clear;
		funcao_instalar_na_inicializacao
			;;
		2) clear;
		# Remove qualquer cron job do script
		(crontab -l 2>/dev/null | grep -v "$SCRIPT_DIR/main.sh update" | crontab -)
		echo "Verificação de scripts na inicialização removida!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_script
			;;
		0) clear;
		tweaks_menu;
			;;
		*) clear
		tweaks_menu;
			;;			
      esac
    fi
  done
instala_script
}

