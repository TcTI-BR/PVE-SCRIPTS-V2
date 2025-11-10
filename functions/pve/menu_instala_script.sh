#!/bin/bash

# Menu para instalar/desinstalar script na inicialização

instala_script(){
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
	echo -e "║              🚀 Auto-Inicialização do Script                        ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instala script ao carregar o usuário${COLOR_RESET}              ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Desinstala script ao carregar o usuário${COLOR_RESET}           ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                              ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}└───────────────────────────────────────────────────────────────┘${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_YELLOW}  Digite sua opção ${COLOR_GRAY}(ou pressione ENTER para sair)${COLOR_YELLOW}: ${COLOR_RESET}"
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
			case $opt in
				1) clear;
				# Cria script para executar main.sh ao carregar o shell
				# Com atualização forçada do main.sh antes de executar
				cat > /etc/profile.d/tcti-proxmox-auto.sh << 'EOF'
#!/bin/bash

# Diretório do script
SCRIPT_DIR="$SCRIPT_DIR"
MAIN_SH="\$SCRIPT_DIR/main.sh"
BACKUP_SH="\$SCRIPT_DIR/main.sh.backup"

# URL com timestamp para forçar bypass do cache do GitHub CDN
TIMESTAMP=\$(date +%s%N)
GITHUB_URL="https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh?t=\${TIMESTAMP}"

# Cores para mensagens
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

echo -e "\${CYAN}🔄 Atualizando main.sh...${RESET}"

# Faz backup do main.sh atual
if [ -f "\$MAIN_SH" ]; then
    cp "\$MAIN_SH" "\$BACKUP_SH"
fi

# Remove o main.sh atual
rm -f "\$MAIN_SH"

# Baixa a versão mais recente (sem cache)
if curl -sL -H "Cache-Control: no-cache, no-store, must-revalidate" \\
        -H "Pragma: no-cache" \\
        -H "Expires: 0" \\
        -o "\$MAIN_SH" "\$GITHUB_URL" 2>/dev/null; then
    
    chmod +x "\$MAIN_SH"
    echo -e "\${GREEN}✓ main.sh atualizado com sucesso!\${RESET}"
    
    # Remove o backup se tudo deu certo
    rm -f "\$BACKUP_SH"
    
    # Executa o main.sh atualizado
    cd "\$SCRIPT_DIR"
    ./main.sh
else
    echo -e "\${YELLOW}⚠ Erro ao baixar main.sh, usando versão de backup...\${RESET}"
    
    # Restaura o backup se o download falhou
    if [ -f "\$BACKUP_SH" ]; then
        mv "\$BACKUP_SH" "\$MAIN_SH"
        chmod +x "\$MAIN_SH"
        cd "\$SCRIPT_DIR"
        ./main.sh
    else
        echo -e "\${YELLOW}✗ Nenhum backup disponível. Execute manualmente: cd $SCRIPT_DIR && ./main.sh\${RESET}"
    fi
fi
EOF
				# Substitui a variável SCRIPT_DIR no arquivo
				sed -i "s|\$SCRIPT_DIR|$SCRIPT_DIR|g" /etc/profile.d/tcti-proxmox-auto.sh
				chmod +x /etc/profile.d/tcti-proxmox-auto.sh
				echo ""
				echo "✓ Script instalado com atualização automática do main.sh!"
				echo ""
				echo "Agora, toda vez que abrir o terminal:"
				echo "  1. O main.sh será DELETADO"
				echo "  2. Baixará a versão mais recente do GitHub"
				echo "  3. Executará automaticamente"
				echo ""
				read -p "Pressione uma tecla para continuar..."
				clear	  
				instala_script
					;;
				2) clear;
				# Remove o script de inicialização
				rm -f /etc/profile.d/tcti-proxmox-auto.sh
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

