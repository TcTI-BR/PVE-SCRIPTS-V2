#!/bin/bash

# Menu para instalar interface gráfica e Chromium

instala_x(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Inicia a interface grafico ${NORMAL}"
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
		apt-get update
		apt-get upgrade -y
		apt-get install xfce4 chromium lightdm -y
		clear	 
		mkdir /root/Desktop
		touch /root/Desktop/"Chromium Web Browser.desktop"
		echo [Desktop Entry] > /root/Desktop/"Chromium Web Browser.desktop"
		echo Version=1.0 >> /root/Desktop/"Chromium Web Browser.desktop"
		echo Type=Application	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Name=Chromium Web Browser	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Comment=Access the Internet	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Exec=/usr/bin/chromium %U --no-sandbox	  "https://127.0.0.1:8006" >> /root/Desktop/"Chromium Web Browser.desktop"
		echo Icon=chromium	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Path=	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Terminal=false	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo StartupNotify=true	>> /root/Desktop/"Chromium Web Browser.desktop"
		chmod +x /root/Desktop/"Chromium Web Browser.desktop"
		apt-get install dbus-x11
		systemctl disable display-manager
		clear	 
		echo "Interface grafica instalada!" 
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_x
			;;
		2) clear;
		startx
		clear	  
		instala_x
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
  instala_x
}

