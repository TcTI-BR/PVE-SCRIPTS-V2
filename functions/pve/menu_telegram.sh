#!/bin/bash

# Menu de Gerenciamento do Bot Telegram
# Autor: TcTI-BR (Gerado via IA)

telegram_menu() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}"
    echo -e "╔═════════════════════════════════════════════════════════════════════╗"
    echo -e "║                    🤖 Gerenciamento via Telegram                    ║"
    echo -e "╚═════════════════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
    
    # Check if installed
    local is_installed=0
    if [ -f "/etc/systemd/system/pve-telegram-bot.service" ]; then
        is_installed=1
        status=$(systemctl is-active pve-telegram-bot 2>/dev/null)
        if [ "$status" == "active" ]; then
            echo -e "  ${COLOR_WHITE}Status: ${COLOR_GREEN}${SYMBOL_CHECK} Ativo e rodando${COLOR_RESET}"
        else
            echo -e "  ${COLOR_WHITE}Status: ${COLOR_RED}${SYMBOL_ERROR} Inativo ou com erro${COLOR_RESET}"
        fi
    else
        echo -e "  ${COLOR_WHITE}Status: ${COLOR_GRAY}Não instalado${COLOR_RESET}"
    fi
    echo ""
    
    echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    
    if [ $is_installed -eq 0 ]; then
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Instalar e Configurar Bot${COLOR_RESET}                               ${COLOR_CYAN}│${COLOR_RESET}"
    else
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Reconfigurar Bot${COLOR_RESET}                                        ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Desinstalar Bot${COLOR_RESET}                                         ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Reiniciar Serviço${COLOR_RESET}                                       ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Ver Logs do Bot${COLOR_RESET}                                         ${COLOR_CYAN}│${COLOR_RESET}"
    fi
    
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
    echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar ao menu anterior${COLOR_RESET}                                 ${COLOR_CYAN}│${COLOR_RESET}"
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
                1) install_telegram_bot ;;
                2) if [ $is_installed -eq 1 ]; then uninstall_telegram_bot; else pve_menu; fi ;;
                3) if [ $is_installed -eq 1 ]; then restart_telegram_bot; else pve_menu; fi ;;
                4) if [ $is_installed -eq 1 ]; then logs_telegram_bot; else pve_menu; fi ;;
                0) clear; pve_menu ;;
                *) clear; pve_menu ;;
            esac
        fi
    done
    telegram_menu
}

install_telegram_bot() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_CYAN}${COLOR_BOLD}║                Instalação do Bot Telegram                     ║${COLOR_RESET}"
    echo -e "${COLOR_CYAN}${COLOR_BOLD}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""
    
    echo -e "${COLOR_WHITE}Este script criará um bot seguro que responde apenas a você.${COLOR_RESET}"
    echo -e "${COLOR_GRAY}1. Crie o bot no @BotFather no Telegram para pegar o Token${COLOR_RESET}"
    echo -e "${COLOR_GRAY}2. Pegue seu ID de usuário (ex: no @userinfobot)${COLOR_RESET}"
    echo ""
    
    read -p "$(echo -e ${COLOR_YELLOW}"Qual o nome deste servidor? (Ex: SRV-SP-01): "${COLOR_RESET})" server_name
    read -p "$(echo -e ${COLOR_YELLOW}"Cole o Token do Bot: "${COLOR_RESET})" bot_token
    read -p "$(echo -e ${COLOR_YELLOW}"Cole o seu Chat ID: "${COLOR_RESET})" chat_id
    
    if [[ -z "$server_name" || -z "$bot_token" || -z "$chat_id" ]]; then
        echo -e "\n${COLOR_RED}${SYMBOL_ERROR} Todos os campos são obrigatórios! Cancelando.${COLOR_RESET}"
        sleep 2
        telegram_menu
        return
    fi
    
    echo -e "\n${COLOR_BLUE}${SYMBOL_LOADING} Configurando ambiente seguro...${COLOR_RESET}"
    mkdir -p /TcTI/SCRIPTS/telegram
    chmod 700 /TcTI/SCRIPTS/telegram
    
    # Criar JSON e Ofuscar em Base64
    json_data="{\"token\":\"$bot_token\",\"chat_id\":\"$chat_id\",\"server_name\":\"$server_name\"}"
    echo -n "$json_data" | base64 > /TcTI/SCRIPTS/telegram/.env
    chmod 600 /TcTI/SCRIPTS/telegram/.env
    
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Instalando serviço do backend Python...${COLOR_RESET}"
    
    # Cria o arquivo Python
    cat << 'EOF' > /usr/local/bin/pve-telegram-bot.py
#!/usr/bin/env python3
import urllib.request
import urllib.parse
import json
import subprocess
import time
import base64
import sys

CONFIG_FILE = "/TcTI/SCRIPTS/telegram/.env"

def load_config():
    try:
        with open(CONFIG_FILE, 'r') as f:
            encoded = f.read().strip()
            decoded = base64.b64decode(encoded).decode('utf-8')
            config = json.loads(decoded)
            return config['token'], str(config['chat_id']), config['server_name']
    except Exception as e:
        print(f"Erro carregando configuração: {e}")
        sys.exit(1)

TOKEN, ALLOWED_CHAT_ID, SERVER_NAME = load_config()
BASE_URL = f"https://api.telegram.org/bot{TOKEN}/"

def call_api(method, data=None):
    url = BASE_URL + method
    req = urllib.request.Request(url)
    req.add_header('Content-Type', 'application/json')
    try:
        if data:
            jsondata = json.dumps(data).encode('utf-8')
            response = urllib.request.urlopen(req, data=jsondata)
        else:
            response = urllib.request.urlopen(req)
        return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        print(f"API Error ({method}): {e}")
        return None

def get_vms():
    try:
        out = subprocess.check_output(['qm', 'list']).decode('utf-8').strip().split('\n')
        vms = []
        for line in out[1:]:
            parts = line.split()
            if len(parts) >= 3:
                vmid = parts[0]
                name = parts[1]
                status = parts[2]
                vms.append({'vmid': vmid, 'name': name, 'status': status})
        return vms
    except Exception as e:
        return []

def get_host_status():
    try:
        uptime = subprocess.check_output(['uptime', '-p']).decode('utf-8').strip()
        free_m = subprocess.check_output(['free', '-m']).decode('utf-8').split('\n')[1].split()
        total_ram = int(free_m[1])
        used_ram = int(free_m[2])
        return f"🖥️ *{SERVER_NAME}*\n⏱ Uptime: {uptime}\n💾 RAM: {used_ram}MB / {total_ram}MB"
    except:
        return "Erro ao obter status."

def build_main_menu():
    keyboard = [
        [{"text": "💻 Gerenciar VMs", "callback_data": "menu_vms"}],
        [{"text": "📊 Status do Host", "callback_data": "menu_status"}]
    ]
    return {"inline_keyboard": keyboard}

def build_vms_menu():
    vms = get_vms()
    keyboard = []
    for vm in vms:
        icon = "🟢" if vm['status'] == "running" else "🔴" if vm['status'] == "stopped" else "🟡"
        keyboard.append([{"text": f"{icon} {vm['vmid']} - {vm['name']}", "callback_data": f"vm_{vm['vmid']}"}])
    keyboard.append([{"text": "🔙 Voltar", "callback_data": "menu_main"}])
    return {"inline_keyboard": keyboard}

def build_vm_action_menu(vmid):
    keyboard = [
        [{"text": "⚡ Ligar", "callback_data": f"action_start_{vmid}"},
         {"text": "🛑 Desligar", "callback_data": f"action_shutdown_{vmid}"}],
        [{"text": "💀 Forçar", "callback_data": f"action_stop_{vmid}"},
         {"text": "🔄 Reiniciar", "callback_data": f"action_reboot_{vmid}"}],
        [{"text": "🔙 Voltar às VMs", "callback_data": "menu_vms"}]
    ]
    return {"inline_keyboard": keyboard}

def handle_message(msg):
    chat_id = str(msg.get('chat', {}).get('id'))
    if chat_id != ALLOWED_CHAT_ID:
        print(f"Acesso bloqueado: chat_id {chat_id} não autorizado.")
        return
    text = msg.get('text', '')
    if text.startswith('/'):
        call_api("sendMessage", {
            "chat_id": chat_id,
            "text": f"Bem-vindo ao servidor *{SERVER_NAME}*\nEscolha uma opção:",
            "parse_mode": "Markdown",
            "reply_markup": build_main_menu()
        })

def handle_callback(cb):
    chat_id = str(cb.get('message', {}).get('chat', {}).get('id'))
    if chat_id != ALLOWED_CHAT_ID:
        return
    
    cb_id = cb.get('id')
    data = cb.get('data')
    msg_id = cb.get('message', {}).get('message_id')
    
    if data == "menu_main":
        call_api("editMessageText", {
            "chat_id": chat_id, "message_id": msg_id,
            "text": f"Bem-vindo ao servidor *{SERVER_NAME}*\nEscolha uma opção:",
            "parse_mode": "Markdown", "reply_markup": build_main_menu()
        })
    elif data == "menu_vms":
        call_api("editMessageText", {
            "chat_id": chat_id, "message_id": msg_id,
            "text": f"*{SERVER_NAME}* > Selecione uma VM:",
            "parse_mode": "Markdown",
            "reply_markup": build_vms_menu()
        })
    elif data == "menu_status":
        status_text = get_host_status()
        call_api("editMessageText", {
            "chat_id": chat_id, "message_id": msg_id,
            "text": status_text, "parse_mode": "Markdown",
            "reply_markup": build_main_menu()
        })
    elif data.startswith("vm_"):
        vmid = data.split("_")[1]
        call_api("editMessageText", {
            "chat_id": chat_id, "message_id": msg_id,
            "text": f"*{SERVER_NAME}* > Ações para a VM {vmid}:",
            "parse_mode": "Markdown",
            "reply_markup": build_vm_action_menu(vmid)
        })
    elif data.startswith("action_"):
        parts = data.split("_")
        action = parts[1]
        vmid = parts[2]
        call_api("answerCallbackQuery", {"callback_query_id": cb_id, "text": f"Executando na VM {vmid}..."})
        try:
            subprocess.Popen(['qm', action, vmid])
            call_api("editMessageText", {
                "chat_id": chat_id, "message_id": msg_id,
                "text": f"*{SERVER_NAME}* > Comando '{action}' enviado para VM {vmid}.",
                "parse_mode": "Markdown",
                "reply_markup": build_vms_menu()
            })
        except Exception as e:
            print(f"Erro ao executar qm: {e}")
    
    try:
        call_api("answerCallbackQuery", {"callback_query_id": cb_id})
    except:
        pass

def main():
    offset = 0
    print(f"Iniciando bot Telegram para {SERVER_NAME}...")
    while True:
        try:
            res = call_api("getUpdates", {"offset": offset, "timeout": 30})
            if res and res.get("ok"):
                for update in res.get("result", []):
                    offset = update["update_id"] + 1
                    if "message" in update:
                        handle_message(update["message"])
                    elif "callback_query" in update:
                        handle_callback(update["callback_query"])
            time.sleep(1)
        except Exception as e:
            print(f"Erro no loop principal: {e}")
            time.sleep(5)

if __name__ == "__main__":
    main()
EOF

    chmod +x /usr/local/bin/pve-telegram-bot.py
    
    # Criar serviço do Systemd
    cat << 'EOF' > /etc/systemd/system/pve-telegram-bot.service
[Unit]
Description=Proxmox Telegram Bot Backend
After=network.target

[Service]
ExecStart=/usr/local/bin/pve-telegram-bot.py
Restart=always
RestartSec=5
User=root
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=pve-telegram-bot

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable pve-telegram-bot
    systemctl restart pve-telegram-bot
    
    echo -e "\n${COLOR_GREEN}${SYMBOL_CHECK} Bot Instalado com Sucesso!${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Abra o seu bot no Telegram e envie o comando ${COLOR_YELLOW}/start${COLOR_WHITE} ou ${COLOR_YELLOW}/menu${COLOR_RESET}"
    
    echo ""
    read -p "$(echo -e ${COLOR_YELLOW}"Pressione ENTER para voltar ao menu..."${COLOR_RESET})"
    telegram_menu
}

uninstall_telegram_bot() {
    clear
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}⚠️  Atenção! Você está prestes a desinstalar o Bot.${COLOR_RESET}"
    read -p "$(echo -e "Deseja continuar? [y/N]: ")" confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n${COLOR_BLUE}${SYMBOL_LOADING} Removendo serviço...${COLOR_RESET}"
        systemctl stop pve-telegram-bot 2>/dev/null
        systemctl disable pve-telegram-bot 2>/dev/null
        rm -f /etc/systemd/system/pve-telegram-bot.service
        systemctl daemon-reload
        
        echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Removendo arquivos...${COLOR_RESET}"
        rm -f /usr/local/bin/pve-telegram-bot.py
        rm -rf /TcTI/SCRIPTS/telegram
        
        echo -e "\n${COLOR_GREEN}${SYMBOL_CHECK} Desinstalação concluída!${COLOR_RESET}"
        sleep 2
    fi
    telegram_menu
}

restart_telegram_bot() {
    clear
    echo -e "${COLOR_BLUE}${SYMBOL_LOADING} Reiniciando serviço do Telegram...${COLOR_RESET}"
    systemctl restart pve-telegram-bot
    echo -e "\n${COLOR_GREEN}${SYMBOL_CHECK} Serviço reiniciado!${COLOR_RESET}"
    sleep 2
    telegram_menu
}

logs_telegram_bot() {
    clear
    echo -e "${COLOR_CYAN}${COLOR_BOLD}Últimas 20 linhas de log do Bot Telegram:${COLOR_RESET}"
    echo -e "----------------------------------------------------"
    journalctl -u pve-telegram-bot -n 20 --no-pager
    echo -e "----------------------------------------------------"
    echo ""
    read -p "$(echo -e ${COLOR_YELLOW}"Pressione ENTER para voltar ao menu..."${COLOR_RESET})"
    telegram_menu
}
