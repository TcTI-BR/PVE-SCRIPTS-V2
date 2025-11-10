#!/bin/bash

# Função de Live Migration sem Cluster do Proxmox VE

live_migration_menu(){
    # --- Variáveis de Configuração e Cores ---
    MIG_LOG_DIR="/tmp/vm_migrations"
    MIG_PID_LOG_FILE="$MIG_LOG_DIR/pids.log"
    MIG_TASK_LOG_DIR="$MIG_LOG_DIR/tasks"
    MIG_DEBUG_LOG_DIR="$MIG_LOG_DIR/debug_logs"

    MIG_GREEN='\033[1;32m'
    MIG_RED='\033[1;31m'
    MIG_YELLOW='\033[1;33m'
    MIG_BLUE_HEADER='\033[1;34m'
    MIG_BLUE_VM='\033[0;34m' # Nova cor para VMs desligadas
    MIG_NC='\033[0m'

    # --- Verificação de Dependências LOCAIS ---
    MIG_REQUIRED_CMDS=("sshpass" "jq" "bc")
    missing_cmds=()
    echo "Verificando dependências locais necessárias para o script..."
    for cmd in "${MIG_REQUIRED_CMDS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_cmds+=("$cmd")
        fi
    done

    if [ ${#missing_cmds[@]} -ne 0 ]; then
        echo -e "${MIG_YELLOW}Atenção: Os seguintes pacotes são necessários: ${MIG_RED}${missing_cmds[*]}${MIG_NC}"
        read -p "Deseja que o script tente instalá-los agora com 'apt install'? (s/n): " install_choice
        if [[ "$install_choice" == "s" || "$install_choice" == "S" ]]; then
            apt update && apt install -y "${missing_cmds[@]}"
            if [ $? -ne 0 ]; then
                echo -e "${MIG_RED}A instalação falhou. Instale manualmente e execute novamente.${MIG_NC}"; 
                read -p "Pressione uma tecla para continuar..."
                vm_operations_menu
                return
            fi
            echo -e "${MIG_GREEN}Dependências locais instaladas com sucesso!${MIG_NC}"
        else
            echo -e "${MIG_RED}Instalação cancelada. Instale os pacotes manualmente.${MIG_NC}"; 
            read -p "Pressione uma tecla para continuar..."
            vm_operations_menu
            return
        fi
    fi

    # --- Inicialização ---
    mkdir -p "$MIG_LOG_DIR" "$MIG_TASK_LOG_DIR" "$MIG_DEBUG_LOG_DIR"
    touch "$MIG_PID_LOG_FILE"

    # --- Funções ---

    # Função para exibir o status das migrações em andamento
    function display_migration_status() {
        echo -e "${MIG_BLUE_HEADER}--- STATUS DAS MIGRAÇÕES EM ANDAMENTO ---${MIG_NC}"
        if [ ! -s "$MIG_PID_LOG_FILE" ]; then
            echo "Nenhuma migração em andamento."; return; fi
        local temp_pid_file=$(mktemp)
        cp "$MIG_PID_LOG_FILE" "$temp_pid_file"
        local active_migrations=0
        while IFS= read -r line; do
            local VMID=$(echo "$line" | cut -d' ' -f1); local PID=$(echo "$line" | cut -d' ' -f2)
            local TASK_LOG=$(echo "$line" | cut -d' ' -f3); local TOKEN_ID=$(echo "$line" | cut -d' ' -f4)
            local DEST_IP=$(echo "$line" | cut -d' ' -f5); local DEST_USER=$(echo "$line" | cut -d' ' -f6)
            local DEST_PASS_B64=$(echo "$line" | cut -d' ' -f7)
            
            if [ -n "$PID" ] && ps -p "$PID" > /dev/null; then
                active_migrations=$((active_migrations + 1))
                local status_text="Migrando..."
                echo -e "VM ${MIG_YELLOW}$VMID${MIG_NC} (PID: $PID) - $status_text"
            else
                sleep 2 # Pausa estratégica para garantir que o log foi escrito
                if grep -qiE "TASK OK|migration finished successfully" "$TASK_LOG"; then
                     echo -e "VM ${MIG_YELLOW}$VMID${MIG_NC} - ${MIG_GREEN}Migração Concluída com Sucesso!${MIG_NC}"
                else
                    echo -e "VM ${MIG_YELLOW}$VMID${MIG_NC} - ${MIG_RED}Migração Falhou ou foi Interrompida.${MIG_NC}";
                fi
                local DEST_PASS=$(echo "$DEST_PASS_B64" | base64 -d)
                echo "Limpando token de API $TOKEN_ID em $DEST_IP..."
                sshpass -p "$DEST_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$DEST_USER@$DEST_IP" \
                    "pveum user token remove $DEST_USER@pam $TOKEN_ID" &> /dev/null
                sed -i "/ $PID /d" "$MIG_PID_LOG_FILE"
            fi
        done < "$temp_pid_file"
        rm "$temp_pid_file"
        if [ "$active_migrations" -eq 0 ]; then echo "Nenhuma migração em andamento."; fi
    }

    # Função principal para iniciar uma nova migração
    function start_new_migration() {
        echo -e "\n${MIG_BLUE_HEADER}--- CONFIGURAR NOVO DESTINO DE MIGRAÇÃO ---${MIG_NC}"
        read -p "Digite o IP do servidor de DESTINO: " DEST_IP
        read -p "Digite o USUÁRIO do servidor de DESTINO (Enter para 'root'): " DEST_USER
        if [ -z "$DEST_USER" ]; then
            DEST_USER="root"
            echo "Usuário definido como 'root'."
        fi
        read -sp "Digite a SENHA do servidor de DESTINO: " DEST_PASS; echo ""

        echo "Verificando dependências (jq, sshpass) no servidor de destino..."
        local CHECK_CMD="command -v jq &> /dev/null && command -v sshpass &> /dev/null"
        
        sshpass -p "$DEST_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$DEST_USER@$DEST_IP" "$CHECK_CMD" 2>&1
        if [ $? -ne 0 ]; then
            echo "Uma ou mais dependências não encontradas no destino. Tentando instalar..."
            local INSTALL_CMD="apt update && apt install -y jq sshpass"
            sshpass -p "$DEST_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=120 "$DEST_USER@$DEST_IP" "$INSTALL_CMD" 2>&1
            if [ $? -ne 0 ]; then echo -e "${MIG_RED}Falha ao instalar dependências no servidor de destino.${MIG_NC}"
            else echo -e "${MIG_GREEN}Dependências instaladas com sucesso no destino!${MIG_NC}"; fi
        else echo -e "${MIG_GREEN}Dependências já estão satisfeitas no servidor de destino.${MIG_NC}"; fi

        echo "Conectando em $DEST_IP para obter informações..."
        
        local CRED_CMD="openssl x509 -in /etc/pve/local/pve-ssl.pem -fingerprint -sha256 -noout"
        local CRED_OUTPUT=$(sshpass -p "$DEST_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$DEST_USER@$DEST_IP" "$CRED_CMD" 2>&1)
        local FINGERPRINT=$(echo "$CRED_OUTPUT" | grep 'Fingerprint=' | sed -E 's/.*fingerprint=//i')

        local STORAGE_CMD="pvesm status"
        local STORAGE_OUTPUT=$(sshpass -p "$DEST_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$DEST_USER@$DEST_IP" "$STORAGE_CMD" 2>&1)
        local DEST_STORAGES=$(echo "$STORAGE_OUTPUT" | tail -n +2 | grep ' active ' | awk '{print $1}')

        if [ -z "$FINGERPRINT" ] || [ -z "$DEST_STORAGES" ]; then
            echo -e "${MIG_RED}ERRO: Falha ao obter informações do servidor de destino.${MIG_NC}"
            read -p "Pressione Enter para continuar..."; return
        fi
        echo -e "${MIG_GREEN}Conexão com o destino estabelecida com sucesso!${MIG_NC}"

        while true; do
            local TOKEN_ID="migrascript-$(date +%s)"
            
            local TOKEN_CMD="pveum user token add $DEST_USER@pam $TOKEN_ID --privsep 0"
            local TOKEN_OUTPUT=$(sshpass -p "$DEST_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$DEST_USER@$DEST_IP" "$TOKEN_CMD" 2>&1)
            local TOKEN_SECRET=$(echo "$TOKEN_OUTPUT" | grep -oP '[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}')

            if [ -z "$TOKEN_SECRET" ]; then
                echo -e "${MIG_RED}ERRO: Falha ao gerar token de API para a migração.${MIG_NC}"
                break
            fi

            clear
            display_migration_status
            echo -e "\n${MIG_BLUE_HEADER}--- Migrando para $DEST_IP ---${MIG_NC}"
            
            local migrating_vms=$(awk '{print $1}' "$MIG_PID_LOG_FILE")
            echo -e "\n${MIG_BLUE_HEADER}VMs disponíveis neste servidor:${MIG_NC}"
            qm list | tail -n +2 | while read -r VMID NAME STATUS LOCK BOOT; do
                if [[ " ${migrating_vms[*]} " =~ " ${VMID} " ]]; then
                    echo -e "${MIG_RED}$VMID - $NAME (Status: $STATUS) - EM MIGRAÇÃO${MIG_NC}"
                elif [[ "$STATUS" == "stopped" ]]; then
                    echo -e "${MIG_BLUE_VM}$VMID - $NAME (Status: $STATUS)${MIG_NC}"
                else
                    echo -e "${MIG_GREEN}$VMID - $NAME (Status: $STATUS)${MIG_NC}"
                fi
            done
            read -p "Digite o ID da VM que deseja migrar (ou 'q' para voltar): " SOURCE_VMID
            
            if [[ "$SOURCE_VMID" == "q" || "$SOURCE_VMID" == "Q" ]]; then break; fi

            if [[ " ${migrating_vms[*]} " =~ " ${SOURCE_VMID} " ]]; then
                echo -e "${MIG_RED}Esta VM já está em processo de migração!${MIG_NC}"; sleep 2; continue; fi
            if ! qm status "$SOURCE_VMID" &>/dev/null; then
                echo -e "${MIG_RED}VM com ID $SOURCE_VMID não encontrada!${MIG_NC}"; sleep 2; continue; fi
            
            echo -e "\n${MIG_BLUE_HEADER}Storages disponíveis em $DEST_IP:${MIG_NC}"; echo "$DEST_STORAGES"
            read -p "Digite o nome do Storage de DESTINO: " DEST_STORAGE
            
            if ! echo "$DEST_STORAGES" | grep -wq "$DEST_STORAGE"; then
                echo -e "${MIG_RED}Storage '$DEST_STORAGE' não encontrado no destino!${MIG_NC}"; sleep 2; continue; fi
            
            read -p "Digite o ID da VM no destino (Enter para usar $SOURCE_VMID): " TARGET_VMID;
            [ -z "$TARGET_VMID" ] && TARGET_VMID=$SOURCE_VMID

            local API_TOKEN="PVEAPIToken=$DEST_USER@pam!$TOKEN_ID=$TOKEN_SECRET"
            local TARGET_ENDPOINT="apitoken=$API_TOKEN,host=$DEST_IP,fingerprint=$FINGERPRINT"
            local TASK_LOG_FILE="$MIG_TASK_LOG_DIR/vm-${SOURCE_VMID}-task.log"
            
            echo -e "\nIniciando a migração da VM ${MIG_YELLOW}$SOURCE_VMID${MIG_NC} para ${MIG_YELLOW}$DEST_IP${MIG_NC}..."
            
            qm remote-migrate "$SOURCE_VMID" "$TARGET_VMID" "$TARGET_ENDPOINT" --target-bridge vmbr0 --target-storage "$DEST_STORAGE" --online < /dev/null > "$TASK_LOG_FILE" 2>&1 &
            local MIGRATE_PID=$!

            local DEST_PASS_B64=$(echo -n "$DEST_PASS" | base64)
            echo "$SOURCE_VMID $MIGRATE_PID $TASK_LOG_FILE $TOKEN_ID $DEST_IP $DEST_USER $DEST_PASS_B64" >> "$MIG_PID_LOG_FILE"

            echo -e "${MIG_GREEN}Migração iniciada em segundo plano com PID $MIGRATE_PID.${MIG_NC}"; sleep 2

            read -p $'\n1. Migrar outra VM para o mesmo servidor?\n2. Voltar ao menu inicial.\nEscolha uma opção: ' migrate_another_choice
            if [[ "$migrate_another_choice" != "1" ]]; then
                break
            fi
        done
    }

    # --- Loop Principal do Menu ---
    while true; do
        clear
        display_migration_status
        echo -e "\n${MIG_BLUE_HEADER}-----------------------------------------${MIG_NC}"
        echo "1. Iniciar Nova Migração de VM"
        echo "2. Apenas Atualizar Status"
        echo "0. Voltar"
        echo -e "${MIG_BLUE_HEADER}-----------------------------------------${MIG_NC}"
        read -p "Escolha uma opção: " choice

        case $choice in
            1)
                start_new_migration
                ;;
            2)
                ;;
            0)
                vm_operations_menu
                return
                ;;
            *)
                echo -e "${MIG_RED}Opção inválida!${MIG_NC}"
                sleep 2
                ;;
        esac
    done
}

