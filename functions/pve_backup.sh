#!/bin/bash

# Funções de backup do Proxmox VE

bkp_menu(){
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
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de NFS para receber o BACKUP em rede do PROXMOX ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Instala o PBS lado a lado com o PVE ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Agenda o BACKUP das configurações do PROXMOX ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura o BACKUP das configurações do PROXMOX ${NORMAL}"			
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
		1) clear
		echo "Qual IP do computador cliente? EX: 192.168.0.230?"
		read IPDOCLIENTENFS
		echo "Qual o Storage de Backup? EX: BACKUP_2HD?"
		read STORAGEBACKUP
		apt-get install nfs-kernel-server -y
		echo	"/mnt/$STORAGEBACKUP/ $IPDOCLIENTENFS(rw,async,no_subtree_check)"	>	/etc/exports
		service nfs-kernel-server restart
		exportfs -a
		chmod -R 777 /mnt/$STORAGEBACKUP/dump
		read -p "Pressione uma tecla para continuar..."
		clear
		bkp_menu
			;;
		2) clear	
		echo deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription >> /etc/apt/sources.list
		apt update
		apt update
		apt-get install proxmox-backup-server
		echo "PBS instalado!"
		read -p "Pressione uma tecla para continuar..."
		clear
		bkp_menu
			;;	
		3) clear	
		lsblk -o LABEL
		echo "Qual a unidade que vai manter uma copia dos arquivos de configuracao?"
		read CAMINHOBKP
		echo "Qual o e-mail que vai receber uma copia dos arquivos de configuracao?"
		read CAMINHOEMAILBKP
		mkdir /mnt/$CAMINHOBKP/BKP-PVE
		mkdir -p /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU
		echo "CAMINHOLOCAL=$CAMINHOBKP" > /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh						
		echo "PVENAME=$(hostname)" >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo "CAMINHOEMAIL=$CAMINHOEMAILBKP" >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/vzdump.cron' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/storage.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/user.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/datacenter.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/network/interfaces' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/resolv.conf' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /var/spool/cron/crontabs/root' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/hostname' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'cp -r /etc/pve/nodes/$PVENAME/qemu-server/*.conf /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/*.conf' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/hosts' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/fstab' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/jobs.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/postfix/' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'echo "Log de email do dia $(date +%d-%m-%Y)" > /TcTI/SCRIPTS/BKP-PVE/msg.txt' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'mutt -s "$(hostname -f) - Backup diário das configurações"  $CAMINHOEMAIL < /TcTI/SCRIPTS/BKP-PVE/msg.txt  -a /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		chmod +x /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		sed -i '/BKP-PVE/d' /var/spool/cron/crontabs/root
        echo "0 0 * * * /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh" >> /var/spool/cron/crontabs/root
		/TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		clear
		echo -e "\033[33m Backup dos arquivos do PVE agendado para todos os dias as \033[31m00:00\033[33m \033[0m"
		echo -e "\033[33m Armazenando no local \033[31m/mnt/$CAMINHOBKP/BKP-PVE\033[33m \033[0m"
        echo -e "\033[33m Envia por e-mail uma copia no endereço \033[31m$CAMINHOEMAILBKP\033[33m \033[0m"
		echo -e "\033[33m Revise as configurações acima, caso necessário refaça, utilizando o mesmo caminho no script\033[0m"
		echo -e "\033[33mPressione uma tecla para continuar...\033[0m"
		read -p  " "
		clear
		bkp_menu
			;;	
		4) clear	
		echo -e "\033[31mAtenção\033[33m! Essa opção vai recuperar o Backup selecionado \033[31mapagando\033[33m as configurações atuais.\033[0m"
		read -p  " "
		lsblk -o LABEL
		echo "Qual a unidade que estão os arquivos de configuracao?"
		read RECUPERABKP
		mkdir /mnt/RECUPERAPVE
		PVENAME=$(hostname)
		mount LABEL=$RECUPERABKP /mnt/RECUPERAPVE
		ls -t /mnt/RECUPERAPVE/BKP-PVE/ 
		echo "Qual o arquivo a ser recuperado, não precisa da extensão EX:20-02-2023?"
		read RESTAURABKP
		clear
		apt update
		apt install zip -y
		clear	
		unzip /mnt/RECUPERAPVE/BKP-PVE/$RESTAURABKP.zip -d /TcTI/SCRIPTS/TMP-RECUPERA
		if [ -f /etc/pve/nodes/$PVENAME/qemu-server/ ]; then
				echo -e "\033[33mDeseja restaurar a pasta \033[31m/etc/pve/nodes/$PVENAME/qemu-server/\033[33m (s/n) \033[0m"
					read -p "" QEMUSERVER
				if [ "$QEMUSERVER"  = "s" ]; then
			cp -r /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/qemu-server/ /etc/pve/nodes/$PVENAME/qemu-server/
		fi
		else
			cp -r /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/qemu-server/ /etc/pve/nodes/$PVENAME/qemu-server/
				echo -e "\033[33mA pasta \033[31m/etc/pve/nodes/$PVENAME/qemu-server/\033[33m não foi encontrada, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/fstab ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/fstab\033[33m (s/n) \033[0m"
					read -p "" FSTAB
				if [ "$FSTAB"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/fstab /etc/fstab
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/fstab /etc/fstab
				echo -e "\033[33mArquivo \033[31m/etc/fstab\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/pve/vzdump.cron ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/vzdump.cron\033[33m (s/n) \033[0m"
					read -p "" VZDUMPCRON
				if [ "$VZDUMPCRON"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/vzdump.cron /etc/pve/vzdump.cron
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/vzdump.cron /etc/pve/vzdump.cron
				echo -e "\033[33mArquivo \033[31m/etc/pve/vzdump.cron\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi

		if [ -f /etc/pve/storage.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/storage.cfg\033[33m (s/n) \033[0m"
					read -p "" STORAGECFG
				if [ "$STORAGECFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/storage.cfg /etc/pve/storage.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/storage.cfg /etc/pve/storage.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/storage.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/pve/user.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/user.cfg\033[33m (s/n) \033[0m"
					read -p "" USERCFG
				if [ "$USERCFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/user.cfg /etc/pve/user.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/user.cfg /etc/pve/user.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/user.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/pve/datacenter.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/datacenter.cfg\033[33m (s/n) \033[0m"
					read -p "" DATACENTERCFG
				if [ "$DATACENTERCFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/datacenter.cfg /etc/pve/datacenter.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/datacenter.cfg /etc/pve/datacenter.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/datacenter.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/network/interfaces ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/network/interfaces\033[33m (s/n) \033[0m"
					read -p "" INTERFACES
				if [ "$INTERFACES"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/network/interfaces /etc/network/interfaces
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/network/interfaces /etc/network/interfaces
				echo -e "\033[33mArquivo \033[31m/etc/network/interfaces\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/resolv.conf ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/resolv.conf\033[33m (s/n) \033[0m"
					read -p "" RESOLVCONF
				if [ "$RESOLVCONF"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/resolv.conf /etc/resolv.conf
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/resolv.conf /etc/resolv.conf
				echo -e "\033[33mArquivo \033[31m/etc/resolv.conf\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
				
		if [ -f /var/spool/cron/crontabs/root ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/var/spool/cron/crontabs/root\033[33m (s/n) \033[0m"
					read -p "" CRONTABROOT
				if [ "$CRONTABROOT"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/var/spool/cron/crontabs/root /var/spool/cron/crontabs/root
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/var/spool/cron/crontabs/root /var/spool/cron/crontabs/root
				echo -e "\033[33mArquivo \033[31m/var/spool/cron/crontabs/root\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		

		if [ -f /etc/hostname ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/hostname\033[33m (s/n) \033[0m"
					read -p "" HOSTNAME
				if [ "$HOSTNAME"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hostname /etc/hostname
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hostname /etc/hostname
				echo -e "\033[33mArquivo \033[31m/etc/hostname\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi

		if [ -f /etc/hosts ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/hosts\033[33m (s/n) \033[0m"
					read -p "" HOSTS
				if [ "$HOSTS"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hosts /etc/hosts
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hosts /etc/hosts
				echo -e "\033[33mArquivo \033[31m/etc/hosts\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/pve/jobs.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/jobs.cfg\033[33m (s/n) \033[0m"
					read -p "" JOBSCFG
				if [ "$JOBSCFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/jobs.cfg /etc/pve/jobs.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/jobs.cfg /etc/pve/jobs.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/jobs.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/postfix/ ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/postfix/\033[33m (s/n) \033[0m"
					read -p "" POSTFIX
				if [ "$POSTFIX"  = "s" ]; then
			cp -r /TcTI/SCRIPTS/TMP-RECUPERA/etc/postfix/ /etc/postfix/
		fi
		else
			cp -r /TcTI/SCRIPTS/TMP-RECUPERA/etc/postfix/ /etc/postfix/
				echo -e "\033[33mA pasta \033[31m/etc/postfix/\033[33m não foi encontrada, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		echo -e "\033[33m Arquivos recuperados, aperte \033[31mENTER\033[33m para reiniciar.\033[0m"
		read -p  " "
		umount /mnt/RECUPERAPVE/
		rmdir /mnt/RECUPERAPVE/
		read -p  " "
		reboot
		clear
		bkp_menu
			;;				
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

