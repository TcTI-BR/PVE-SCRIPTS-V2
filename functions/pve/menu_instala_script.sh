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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala o script ao carregar o usuário ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Desinstala o script ao carregar o usuario ${NORMAL}"
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
		# Cria script para executar main.sh ao carregar o shell
		echo "#!/bin/bash" > /etc/profile.d/proxmox-ini.sh
		echo "cd $SCRIPT_DIR" >> /etc/profile.d/proxmox-ini.sh
		echo "./main.sh" >> /etc/profile.d/proxmox-ini.sh
		chmod +x /etc/profile.d/proxmox-ini.sh
		echo "Script instalado! O main.sh será executado automaticamente ao abrir o shell."
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_script
			;;
		2) clear;
		# Remove o script de inicialização
		rm -f /etc/profile.d/proxmox-ini.sh
		echo "Script removido! O main.sh não será mais executado automaticamente."
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

