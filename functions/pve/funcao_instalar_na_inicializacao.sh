#!/bin/bash

# Função para instalar script na inicialização

funcao_instalar_na_inicializacao() {
    echo "Configurando verificação de scripts na inicialização..."
    
    # O caminho será /TcTI/SCRIPTS/PROXMOX/main.sh
    MAIN_SCRIPT_PATH="$SCRIPT_DIR/main.sh"
    
    # Remove qualquer cron job antigo
    (crontab -l 2>/dev/null | grep -v "$MAIN_SCRIPT_PATH update" | crontab -)
    
    # Adiciona o novo cron job
    # Ele rodará o main.sh com o parâmetro 'update' na inicialização
    (crontab -l 2>/dev/null; echo "@reboot $MAIN_SCRIPT_PATH update > /var/log/tcti-pve-scripts-update.log 2>&1") | crontab -
    
    echo "Agendado com sucesso."
    echo "Log de atualização será salvo em /var/log/tcti-pve-scripts-update.log"
    read -p "Pressione uma tecla para continuar..."
    clear
    instala_script
}

