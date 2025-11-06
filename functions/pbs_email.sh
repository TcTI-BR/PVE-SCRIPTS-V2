#!/bin/bash

# Funções de configuração de email do Proxmox Backup Server

email_pbs_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de e-mail ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Testa as configurações ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica os logs para tentar executar a correção ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura a configuração original  ${NORMAL}"
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
	echo "- Endereço de e-mail do destinatário do administrador do sistema (conta@dominioexemplo.com) (root alias): "
		read 'varrootmail'
		echo "- Qual é o endereço do host do servidor de e-mail? (smtp.gmail.com): "
		read 'varmailserver'
		echo "- Qual é a porta do servidor de e-mail? (Normalmente 587 (sem tls)): "
		read 'varmailport'
		read -p  "- O servidor de e-mail requer TLS? s = sim / n = não: " -n 1 -r 
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		vartls=yes
		else
		vartls=no
		fi
		echo " "
		echo "- O nome do usuário de autenticação? (EX: email@dominioexemplo.com.br): "
		read 'varmailusername'
		echo "- Qual é a senha de autenticação?: "
		read 'varmailpassword'
		echo "- O endereço de e-mail que envia é o mesmo que o usuário de autenticação?"
		read -p " s para usar $varmailusername / Enter para não: " -n 1 -r 
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		varsenderaddress=$varmailusername
		else
		echo " "
		echo "- Qual é o endereço de e-mail do remetente?: "
		read 'varsenderaddress'
		fi
		echo " "
	echo "- Executando...!"
	echo " "
	echo "- Definindo aliases"
	if grep "root:" /etc/aliases
		then
		echo "- A entrada de alias foi encontrada: editando para $varrootmail"
		sed -i "s/^root:.*$/root: $varrootmail/" /etc/aliases
	else
		echo "- Nenhum alias do root encontrado: Adicionando"
		echo "root: $varrootmail" >> /etc/aliases
	fi
	
	#Configurando o arquivo canônico para o remetente - :
	echo "root $varsenderaddress" > /etc/postfix/canonical
	chmod 600 /etc/postfix/canonical
	
	# Preparando para o hash da senha
	echo [$varmailserver]:$varmailport $varmailusername:$varmailpassword > /etc/postfix/sasl_passwd
	chmod 600 /etc/postfix/sasl_passwd 
	
	# Adicionando o servidor de email no arquivo main.cf
	sed -i "/#/!s/\(relayhost[[:space:]]*=[[:space:]]*\)\(.*\)/\1"[$varmailserver]:"$varmailport""/"  /etc/postfix/main.cf
	
	# Verificando as configurações de TLS
	echo "- Definindo as configurações de TLS corretas: $vartls"
	postconf smtp_use_tls=$vartls
	
	# Verificando a entrada de hash da senha
		if grep "smtp_sasl_password_maps" /etc/postfix/main.cf
		then
		echo "- Hash da senha já configurado"
	else
		echo "- Adicionando entrada de hash da senha"
		postconf smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
	fi
	# Verificando o certificado
	if grep "smtp_tls_CAfile" /etc/postfix/main.cf
		then
		echo "- O arquivo TLS CA parece configurado"
		else
		postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
	fi
	# Adicionando opções de segurança sasl
	# eliminates default security options which are imcompatible with gmail
	if grep "smtp_sasl_security_options" /etc/postfix/main.cf
		then
		echo "- Configuração de smtp_sasl_security_options do Google"
		else
		postconf smtp_sasl_security_options=noanonymous
	fi
	if grep "smtp_sasl_auth_enable" /etc/postfix/main.cf
		then
		echo "- Autenticação já habilitada"
		else
		postconf smtp_sasl_auth_enable=yes
	fi 
	if grep "sender_canonical_maps" /etc/postfix/main.cf
		then
		echo "- Entrada canônica já existente"
		else
		postconf sender_canonical_maps=hash:/etc/postfix/canonical
	fi 
	
	echo "- Criptografia de senha e entrada canônica"
	postmap /etc/postfix/sasl_passwd
	postmap /etc/postfix/canonical
	apt update
	apt install libsasl2-modules -y
	echo "- Reiniciando o postfix e habilitando a inicialização automática"
	systemctl restart postfix && systemctl enable postfix
	echo "- Limpando o arquivo usado para gerar hash de senha"
	rm -rf "/etc/postfix/sasl_passwd"
	echo "- Removido arquivos"
	
	  email_pbs_menu
	;;
	2)	clear;
	echo "- Qual é o endereço de e-mail do destinatário? :"
	read vardestaddress
	echo "- Um e-mail será enviado para: $vardestaddress"
	echo "Esse e-mail confirma que a configuração do seu PBS esta ok!" | mail -s "Teste de e-mail - $hostname - $date" $vardestaddress
	echo "- O e-mail deveria ter sido enviado - Se nenhum for recebido, verifique se há erros no menu 3"
	read -p "Pressione uma tecla para continuar..."
  
  email_pbs_menu
	;;
	3)	clear;
	echo "- Verificando se a erros nos logs"
		if grep "SMTPUTF8 is required" "/var/log/mail.log"
		then
		echo "- Encontrado erros no log - SMTPUTF8 é requerido"
				if grep "smtputf8_enable = no" /etc/postfix/main.cf
					then
					echo "- Executado correção!"
				else
					echo " "
					echo "- Configuração "smtputf8_enable=no" para correta "SMTPUTF8 was required but not supported""
					postconf smtputf8_enable=no
					postfix reload
			 	 fi 

		elif grep "Network is unreachable" "/var/log/mail.log"; then
			read -p "- Você está no IPv4 e seu host pode resolver e acessar endereços públicos? s = sim / n = não: " -n 1 -r
			if [[ $REPLY =~ ^[Ss]$ ]]; then
				if grep "inet_protocols = ipv4" /etc/postfix/main.cf
				then
					echo "- Executado correção!"
				else
					echo " "
					echo "- Configuração "inet_protocols = ipv4 " para o correto ""Network is unreachable" caused by ipv6 resolution""
					postconf inet_protocols=ipv4
					postfix reload
				fi
			fi
		elif grep "smtp_tls_security_level = encrypt" "/var/log/mail.log"; then		
			echo "- Encontrado erros no log - smtp_tls_security_level = encrypt is required"
			if grep "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
				echo "- Executado correção!"
			else
				echo " "
				echo "- Setting "smtp_tls_security_level = encrypt" to correct"
				postconf inet_protocols=ipv4
				postfix reload
			fi
		elif grep "smtp_tls_wrappermode = yes" "/var/log/mail.log"; then		
			echo "- Encontrado erros no log - smtp_tls_wrappermode = yes is required"
			if grep "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
				echo "- Executado correção!"
			else
				echo " "
				echo "- Configuração "smtp_tls_wrappermode = yes" para o correto"
				postconf smtp_tls_wrappermode=yes
				postfix reload
			fi
	    else
		echo "- Não foram encontrados erros!"
		read -p "Pressione uma tecla para continuar..."
		fi
  email_pbs_menu	
	;;
	4)clear;
	read -p "- Deseja restarar as configurações? s = sim / n = não: " -n 1 -r
		if [[ $REPLY =~ ^[Ss]$ ]]; then
				echo " "
				echo "- Restaurando as configurações originais"
			        cp -rf /etc/aliases.BCK /etc/aliases
				cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
				echo "- Reiniciando serviço "
				systemctl restart postfix
				echo "- Restauração executada!"
		fi
		read -p "Pressione uma tecla para continuar..."
  email_pbs_menu
	;;
      0) clear;
      pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      pbs_menu;
      ;;
      esac
    fi
  done
}

