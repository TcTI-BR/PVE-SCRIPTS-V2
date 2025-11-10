#!/bin/bash

# ---
# Script de Gerenciamento Interativo para TacticalRMM
# Criado por Gemini, com base na solicitação do usuário.
# ---

# --- Configurações ---
# Diretório de instalação (baseado no seu script anterior)
INSTALL_DIR="/TcTI/TRMM"
# URL do script de instalação do RMM
SCRIPT_URL="https://raw.githubusercontent.com/netvolt/LinuxRMM-Script/main/rmmagent-linux.sh"
# Nome do script local
SCRIPT_NAME="rmmagent-linux.sh"
# Caminho completo do script
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# --- Funções Auxiliares ---

# Garante que as dependências e o script estejam prontos
preparar_ambiente() {
    echo "Preparando o ambiente..."
    
    # 1. Garante que as dependências (wget, unzip) estão instaladas
    echo "Verificando dependências (wget, unzip)..."
    if ! command -v wget &> /dev/null || ! command -v unzip &> /dev/null; then
        apt update
        apt install wget unzip -y
    fi
    
    # 2. Cria o diretório de instalação
    mkdir -p "$INSTALL_DIR"
    
    # 3. Baixa o script do RMM (se não existir ou se for forçado)
    if [ ! -f "$SCRIPT_PATH" ] || [ "$1" == "force" ]; then
        echo "Baixando o script 'rmmagent-linux.sh'..."
        wget -O "$SCRIPT_PATH" "$SCRIPT_URL"
        chmod +x "$SCRIPT_PATH"
    else
        echo "Script 'rmmagent-linux.sh' já existe."
        chmod +x "$SCRIPT_PATH" # Garante que é executável
    fi
    
    # Entra no diretório para execução
    cd "$INSTALL_DIR" || exit 1
}

# --- Funções Principais ---

# Função para INSTALAR o agente
instalar_agente() {
    echo "----------------------------------------"
    echo " Assistente de Instalação TacticalRMM"
    echo "----------------------------------------"
    echo "Por favor, insira as informações solicitadas (encontradas no seu painel RMM):"
    echo ""

    # Solicita cada parâmetro interativamente
    read -p "1. Insira a URL do 'Mesh agent' (com aspas simples): " MESH_URL
    read -p "2. Insira a 'API URL' (ex: https://api.example.com): " API_URL
    read -p "3. Insira o 'Client ID' (numérico): " CLIENT_ID
    read -p "4. Insira o 'Site ID' (numérico): " SITE_ID
    read -p "5. Insira a 'Auth Key' (chave longa): " AUTH_KEY
    read -p "6. Insira o 'Agent Type' (server/workstation) [Padrão: server]: " AGENT_TYPE

    # Define 'server' como padrão se nada for digitado
    AGENT_TYPE=${AGENT_TYPE:-server}

    echo ""
    echo "--- Revisão ---"
    echo "Mesh URL:   $MESH_URL"
    echo "API URL:    $API_URL"
    echo "Client ID:  $CLIENT_ID"
    echo "Site ID:    $SITE_ID"
    echo "Auth Key:   [oculto]"
    echo "Agent Type: $AGENT_TYPE"
    echo "---------------"
    
    read -p "As informações estão corretas? (s/n): " CONFIRM

    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo "Preparando o ambiente para instalação..."
        preparar_ambiente
        
        echo "Executando o script de instalação... (Isso pode demorar alguns minutos)"
        # Executa o comando de instalação com todas as variáveis entre aspas
        ./"$SCRIPT_NAME" install "$MESH_URL" "$API_URL" "$CLIENT_ID" "$SITE_ID" "$AUTH_KEY" "$AGENT_TYPE"
        
        echo "Instalação concluída."
    else
        echo "Instalação abortada."
    fi
}

# Função para DESINSTALAR o agente
desinstalar_agente() {
    echo "------------------------------------------"
    echo " Assistente de Desinstalação TacticalRMM"
    echo "------------------------------------------"
    echo "ATENÇÃO: Isso remove o agente da máquina, mas NÃO o remove"
    echo "do painel do RMM. Você terá que removê-lo manualmente."
    echo ""

    # Solicita os parâmetros de desinstalação
    read -p "1. Insira o 'Mesh FQDN' (ex: mesh.example.com): " MESH_FQDN
    read -p "2. Insira o 'Mesh ID' (a chave longa de 64 caracteres): " MESH_ID
    
    echo ""
    echo "--- Revisão ---"
    echo "Mesh FQDN: $MESH_FQDN"
    echo "Mesh ID:   $MESH_ID"
    echo "---------------"

    read -p "Confirmar desinstalação? (s/n): " CONFIRM

    if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
        echo "Preparando o ambiente para desinstalação..."
        preparar_ambiente
        
        echo "Executando o script de desinstalação..."
        # Executa o comando de desinstalação
        ./"$SCRIPT_NAME" uninstall "$MESH_FQDN" "$MESH_ID"
        
        echo "Desinstalação concluída."
    else
        echo "Desinstalação abortada."
    fi
}

# --- Menu Principal ---
clear
echo "==============================================="
echo "  Gerenciador de Agente TacticalRMM (Netvolt)"
echo "==============================================="
echo "Este script irá ajudá-lo a instalar ou desinstalar"
echo "o agente RMM de forma interativa."
echo ""
echo "O que você gostaria de fazer?"
echo ""
echo "   1) Instalar um novo agente"
echo "   2) Desinstalar um agente existente"
echo "   3) Sair"
echo ""
read -p "Escolha uma opção (1, 2 ou 3): " MENU_CHOICE

case $MENU_CHOICE in
    1)
        instalar_agente
        ;;
    2)
        desinstalar_agente
        ;;
    3)
        echo "Saindo."
        ;;
    *)
        echo "Opção inválida. Saindo."
        ;;
esac

exit 0