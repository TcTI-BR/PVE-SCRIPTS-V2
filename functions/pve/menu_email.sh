#!/bin/bash

# Menu de configuração de email do Proxmox VE

email_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"`
    NUMBER=`echo "\033[33m"`
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
	echo -e "╔═════════════════════════════════════════════════════════════════════╗"
	echo -e "║                                                                     ║"
	echo -e "║                    📧 Configuração de Email                          ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Configura o serviço de e-mail${COLOR_RESET}                           ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Testa as configurações${COLOR_RESET}                                  ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verifica logs e tenta correção automática${COLOR_RESET}               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Restaura a configuração original${COLOR_RESET}                        ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                                  ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}└───────────────────────────────────────────────────────────────┘${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}  Digite sua opção ${COLOR_GRAY}(ou pressione ENTER para sair)${COLOR_YELLOW}: ${COLOR_RESET}"
    read -rsn1 opt
    while [ "$opt" != '' ] 
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
        echo "- Qual é a porta do servidor de e-mail? (Ex: 465 ou 587): "
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
        
        # [MODIFICAÇÃO] Removendo parâmetro antigo smtp_use_tls se existir para evitar conflitos
        postconf -X smtp_use_tls

        # Verificando as configurações de TLS
        echo "- Definindo as configurações de TLS corretas"
        if [ "$vartls" = "yes" ]; then
            postconf smtp_tls_security_level=encrypt
            # Se for a porta SSL implícita (465), liga automaticamente o wrappermode
            if [ "$varmailport" = "465" ]; then
                postconf smtp_tls_wrappermode=yes
                postconf smtp_tls_loglevel=1
            else
                postconf smtp_tls_wrappermode=no
            fi
        else
            postconf smtp_tls_security_level=none
            postconf smtp_tls_wrappermode=no
        fi

        # Verificando a entrada de hash da senha
        if grep "smtp_sasl_password_maps" /etc/postfix/main.cf
        then
        echo "- Hash da senha já configurado"
        else
        echo "- Adicionando entrada de hash da senha"
        postconf smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
        fi
        
        # [MODIFICAÇÃO] Removendo diretiva antiga que gera avisos nas versões novas do Debian
        postconf -X smtp_tls_CAfile
        
        # Adicionando opções de segurança sasl
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
        email_menu
            ;;
        2) clear;
        echo "- Qual é o endereço de e-mail do destinatário? :"
        read vardestaddress
        echo "- Um e-mail será enviado para: $vardestaddress"
        # [MODIFICAÇÃO] Corrigido variáveis $hostname e $date para puxar comandos nativos do sistema
        echo "Esse e-mail confirma que a configuração do seu PVE esta ok!" | mail -s "Teste de e-mail - $(hostname) - $(date +'%d/%m/%Y')" $vardestaddress
        echo "- O e-mail deveria ter sido enviado - Se nenhum for recebido, verifique se há erros no menu 3"
        read -p "Pressione uma tecla para continuar..."
        email_menu
            ;;
        3) clear;
        echo "- Verificando se ha erros nos logs"
        # [MODIFICAÇÃO] O arquivo correto de logs de email no Debian moderno (PVE 8+) é /var/log/mail.log ou via journalctl
        LOG_FILE="/var/log/mail.log"
        [ ! -f "$LOG_FILE" ] && LOG_FILE="/var/log/syslog"

        if grep -q "SMTPUTF8 is required" "$LOG_FILE"
        then
        echo "- Encontrado erros no log - SMTPUTF8 é requerido"
        if grep -q "smtputf8_enable = no" /etc/postfix/main.cf
        then
        echo "- Executado correção!"
        else
        echo " "
        echo "- Configuração smtputf8_enable=no para correta"
        postconf smtputf8_enable=no
        postfix reload
        fi 
        elif grep -q "Network is unreachable" "$LOG_FILE"; then
        read -p "- Você está no IPv4 e seu host pode resolver e acessar endereços públicos? s = sim / n = não: " -n 1 -r
        if [[ $REPLY =~ ^[Ss]$ ]]; then
        if grep -q "inet_protocols = ipv4" /etc/postfix/main.cf
        then
        echo "- Executado correção!"
        else
        echo " "
        echo "- Configuração inet_protocols = ipv4 para o correto"
        postconf inet_protocols=ipv4
        postfix reload
        fi
        fi
        elif grep -q "smtp_tls_security_level = encrypt" "$LOG_FILE"; then     
        echo "- Encontrado erros no log - smtp_tls_security_level = encrypt is required"
        if grep -q "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
        echo "- Executado correção!"
        else
        echo " "
        echo "- Setting smtp_tls_security_level = encrypt to correct"
        # [CORREÇÃO] Estava postconf inet_protocols=ipv4 por erro de digitação
        postconf smtp_tls_security_level=encrypt
        postfix reload
        fi
        elif grep -q "smtp_tls_wrappermode = yes" "$LOG_FILE"; then        
        echo "- Encontrado erros no log - smtp_tls_wrappermode = yes is required"
        if grep -q "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
        echo "- Executado correção!"
        else
        echo " "
        echo "- Configuração smtp_tls_wrappermode = yes para o correto"
        postconf smtp_tls_wrappermode=yes
        postfix reload
        fi
        else
        echo "- Não foram encontrados erros conhecidos nos logs básicos!"
        read -p "Pressione uma tecla para continuar..."
        fi
        email_menu  
            ;;
        4) clear;
        read -p "- Deseja restaurar as configurações? s = sim / n = não: " -n 1 -r
        if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo " "
        echo "- Restaurando as configurações originais"
        [ -f /etc/aliases.BCK ] && cp -rf /etc/aliases.BCK /etc/aliases
        [ -f /etc/postfix/main.cf.BCK ] && cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
        echo "- Reiniciando serviço "
        systemctl restart postfix
        echo "- Restauração executada!"
        fi
        read -p "Pressione uma tecla para continuar..."
        email_menu
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
