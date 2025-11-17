#!/bin/bash

# Verificador de Configurações de VMs e Containers usando IA
# Versão: V003.R002
# Adicionado em: 2025-11-17 

# Arquivo onde a chave está armazenada
OPENAI_KEY_FILE="/root/.openai_key"

# Diretórios padrão do Proxmox
QEMU_DIR="/etc/pve/qemu-server"
LXC_DIR="/etc/pve/lxc"

# Função para verificar se a chave OpenAI existe
check_openai_key() {
	if [ ! -f "$OPENAI_KEY_FILE" ]; then
		echo -e "${COLOR_RED}  ✗ Chave OpenAI não encontrada!${COLOR_RESET}"
		echo -e "${COLOR_YELLOW}  Por favor, cadastre uma chave OpenAI primeiro (opção 1 do menu).${COLOR_RESET}"
		echo ""
		read -p "  Pressione ENTER para voltar..."
		return 1
	fi
	return 0
}

# Função para buscar arquivos de configuração
find_config_files() {
	local type=$1
	local dir=$2
	local files=()
	
	# Busca recursivamente arquivos .conf que seguem o padrão: número.conf
	while IFS= read -r file; do
		local basename=$(basename "$file")
		# Verifica se o nome do arquivo é número.conf (padrão Proxmox)
		if [[ $basename =~ ^[0-9]+\.conf$ ]]; then
			files+=("$file")
		fi
	done < <(find "$dir" -type f -name "*.conf" 2>/dev/null)
	
	echo "${files[@]}"
}

# Função para enviar para OpenAI API
analyze_with_openai() {
	local config_content="$1"
	local vm_type="$2"
	local vm_id="$3"
	
	OPENAI_KEY=$(cat "$OPENAI_KEY_FILE")
	
	# Prompt especializado para análise de configurações Proxmox
	local prompt="Você é um especialista em Proxmox VE. Analise a seguinte configuração de $vm_type (ID: $vm_id) e forneça:

1. ERROS CRÍTICOS: Identifique problemas que podem causar falhas
2. AVISOS: Configurações que podem causar problemas de performance
3. MELHORIAS SUGERIDAS: Otimizações recomendadas
4. BOAS PRÁTICAS: Se a configuração segue as melhores práticas

Configuração:
\`\`\`
$config_content
\`\`\`

Formato da resposta:
- Use emojis para destacar (🔴 erros, ⚠️ avisos, ✅ ok, 💡 sugestões)
- Seja objetivo e técnico
- Priorize os problemas mais importantes"

	# Escapa o JSON corretamente
	local json_prompt=$(echo "$prompt" | jq -Rs .)
	local json_content=$(echo "$config_content" | jq -Rs .)
	
	# Monta o JSON da requisição
	local json_data=$(cat <<EOF
{
  "model": "gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "Você é um especialista em Proxmox VE com profundo conhecimento de virtualização, containers LXC, e otimização de recursos."
    },
    {
      "role": "user",
      "content": $json_prompt
    }
  ],
  "temperature": 0.3,
  "max_tokens": 2000
}
EOF
)
	
	# Faz a requisição para a API
	local response=$(curl -s -w "\n%{http_code}" -X POST \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d "$json_data" \
		"https://api.openai.com/v1/chat/completions" 2>&1)
	
	local http_code=$(echo "$response" | tail -n1)
	local body=$(echo "$response" | head -n-1)
	
	if [ "$http_code" = "200" ]; then
		# Extrai a resposta do JSON
		local ai_response=$(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null)
		if [ -n "$ai_response" ] && [ "$ai_response" != "null" ]; then
			echo "$ai_response"
			return 0
		else
			echo "Erro ao processar resposta da API"
			return 1
		fi
	else
		echo "Erro na API (Código: $http_code)"
		if [ "$http_code" = "401" ]; then
			echo "Chave API inválida"
		elif [ "$http_code" = "429" ]; then
			echo "Limite de requisições atingido"
		fi
		return 1
	fi
}

vm_config_checker(){
	clear
	
	echo -e "${COLOR_CYAN}${COLOR_BOLD}"
	echo -e "╔═════════════════════════════════════════════════════════════════════╗"
	echo -e "║                                                                     ║"
	echo -e "║         🔍 Verificação de Configurações com IA                      ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	
	# Verifica se a chave OpenAI existe
	if ! check_openai_key; then
		return
	fi
	
	echo -e "${COLOR_YELLOW}  🔎 Buscando VMs e Containers...${COLOR_RESET}"
	echo ""
	
	# Busca arquivos de VMs
	local vm_files=()
	if [ -d "$QEMU_DIR" ]; then
		mapfile -t vm_files < <(find "$QEMU_DIR" -type f -name "*.conf" 2>/dev/null | grep -E '/[0-9]+\.conf$')
	fi
	
	# Busca arquivos de Containers
	local ct_files=()
	if [ -d "$LXC_DIR" ]; then
		mapfile -t ct_files < <(find "$LXC_DIR" -type f -name "*.conf" 2>/dev/null | grep -E '/[0-9]+\.conf$')
	fi
	
	local total_vms=${#vm_files[@]}
	local total_cts=${#ct_files[@]}
	local total=$((total_vms + total_cts))
	
	if [ $total -eq 0 ]; then
		echo -e "${COLOR_RED}  ✗ Nenhuma VM ou Container encontrado${COLOR_RESET}"
		echo ""
		read -p "  Pressione ENTER para voltar..."
		return
	fi
	
	echo -e "${COLOR_GREEN}  ✓ Encontrados:${COLOR_RESET}"
	echo -e "    ${COLOR_WHITE}VMs: ${COLOR_YELLOW}${total_vms}${COLOR_RESET}"
	echo -e "    ${COLOR_WHITE}Containers: ${COLOR_YELLOW}${total_cts}${COLOR_RESET}"
	echo ""
	
	# Lista as VMs encontradas
	if [ $total_vms -gt 0 ]; then
		echo -e "${COLOR_CYAN}  📦 VMs encontradas:${COLOR_RESET}"
		for vm_file in "${vm_files[@]}"; do
			local vm_id=$(basename "$vm_file" .conf)
			local vm_name=$(grep "^name:" "$vm_file" 2>/dev/null | cut -d' ' -f2)
			if [ -n "$vm_name" ]; then
				echo -e "    ${COLOR_GRAY}•${COLOR_RESET} VM ${COLOR_YELLOW}${vm_id}${COLOR_RESET} - ${COLOR_WHITE}${vm_name}${COLOR_RESET}"
			else
				echo -e "    ${COLOR_GRAY}•${COLOR_RESET} VM ${COLOR_YELLOW}${vm_id}${COLOR_RESET}"
			fi
		done
		echo ""
	fi
	
	# Lista os Containers encontrados
	if [ $total_cts -gt 0 ]; then
		echo -e "${COLOR_CYAN}  📦 Containers encontrados:${COLOR_RESET}"
		for ct_file in "${ct_files[@]}"; do
			local ct_id=$(basename "$ct_file" .conf)
			local ct_name=$(grep "^hostname:" "$ct_file" 2>/dev/null | cut -d' ' -f2)
			if [ -n "$ct_name" ]; then
				echo -e "    ${COLOR_GRAY}•${COLOR_RESET} CT ${COLOR_YELLOW}${ct_id}${COLOR_RESET} - ${COLOR_WHITE}${ct_name}${COLOR_RESET}"
			else
				echo -e "    ${COLOR_GRAY}•${COLOR_RESET} CT ${COLOR_YELLOW}${ct_id}${COLOR_RESET}"
			fi
		done
		echo ""
	fi
	
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verificar TODAS as VMs e Containers${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verificar uma VM/Container específico${COLOR_RESET}                  ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                                  ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}└───────────────────────────────────────────────────────────────┘${COLOR_RESET}"
	echo ""
	echo -e "${COLOR_YELLOW}  Digite sua opção: ${COLOR_RESET}"
	read -rsn1 opt
	
	case $opt in
		1)
			clear
			echo -e "${COLOR_CYAN}${COLOR_BOLD}"
			echo -e "╔═════════════════════════════════════════════════════════════════════╗"
			echo -e "║            🤖 Verificação Completa com IA                           ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			echo -e "${COLOR_YELLOW}  Analisando ${total} VMs/Containers...${COLOR_RESET}"
			echo ""
			
			local processed=0
			local errors=0
			
			# Processa VMs
			for vm_file in "${vm_files[@]}"; do
				processed=$((processed + 1))
				local vm_id=$(basename "$vm_file" .conf)
				local vm_name=$(grep "^name:" "$vm_file" 2>/dev/null | cut -d' ' -f2)
				
				echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
				echo -e "${COLOR_BOLD}  📦 VM ${vm_id}${COLOR_RESET}${vm_name:+ - $vm_name} ${COLOR_GRAY}[${processed}/${total}]${COLOR_RESET}"
				echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
				echo ""
				
				local config_content=$(cat "$vm_file")
				local analysis=$(analyze_with_openai "$config_content" "VM" "$vm_id")
				
				if [ $? -eq 0 ]; then
					echo -e "${COLOR_WHITE}${analysis}${COLOR_RESET}"
				else
					echo -e "${COLOR_RED}  ✗ Erro ao analisar: ${analysis}${COLOR_RESET}"
					errors=$((errors + 1))
				fi
				
				echo ""
				
				# Pausa entre requisições para evitar rate limit
				if [ $processed -lt $total ]; then
					sleep 2
				fi
			done
			
			# Processa Containers
			for ct_file in "${ct_files[@]}"; do
				processed=$((processed + 1))
				local ct_id=$(basename "$ct_file" .conf)
				local ct_name=$(grep "^hostname:" "$ct_file" 2>/dev/null | cut -d' ' -f2)
				
				echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
				echo -e "${COLOR_BOLD}  📦 Container ${ct_id}${COLOR_RESET}${ct_name:+ - $ct_name} ${COLOR_GRAY}[${processed}/${total}]${COLOR_RESET}"
				echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
				echo ""
				
				local config_content=$(cat "$ct_file")
				local analysis=$(analyze_with_openai "$config_content" "Container" "$ct_id")
				
				if [ $? -eq 0 ]; then
					echo -e "${COLOR_WHITE}${analysis}${COLOR_RESET}"
				else
					echo -e "${COLOR_RED}  ✗ Erro ao analisar: ${analysis}${COLOR_RESET}"
					errors=$((errors + 1))
				fi
				
				echo ""
				
				# Pausa entre requisições para evitar rate limit
				if [ $processed -lt $total ]; then
					sleep 2
				fi
			done
			
			echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
			echo -e "${COLOR_GREEN}  ✓ Verificação concluída!${COLOR_RESET}"
			echo -e "    ${COLOR_WHITE}Analisados: ${COLOR_YELLOW}${processed}${COLOR_RESET}"
			if [ $errors -gt 0 ]; then
				echo -e "    ${COLOR_RED}Erros: ${errors}${COLOR_RESET}"
			fi
			echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
			echo ""
			read -p "  Pressione ENTER para voltar..."
			vm_config_checker
			;;
		2)
			clear
			echo -e "${COLOR_CYAN}${COLOR_BOLD}"
			echo -e "╔═════════════════════════════════════════════════════════════════════╗"
			echo -e "║          🔍 Verificação Individual com IA                           ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			echo -e "${COLOR_WHITE}  Digite o ID da VM ou Container (ex: 100):${COLOR_RESET}"
			read -p "  ID: " target_id
			
			# Remove espaços e valida se é número
			target_id=$(echo "$target_id" | tr -d ' ')
			if ! [[ "$target_id" =~ ^[0-9]+$ ]]; then
				echo ""
				echo -e "${COLOR_RED}  ✗ ID inválido! Use apenas números.${COLOR_RESET}"
				sleep 2
				vm_config_checker
				return
			fi
			
			# Busca o arquivo
			local found=0
			local config_file=""
			local type=""
			
			# Verifica se é VM
			if [ -f "$QEMU_DIR/${target_id}.conf" ]; then
				config_file="$QEMU_DIR/${target_id}.conf"
				type="VM"
				found=1
			# Verifica em subpastas
			elif [ -n "$(find "$QEMU_DIR" -name "${target_id}.conf" 2>/dev/null)" ]; then
				config_file=$(find "$QEMU_DIR" -name "${target_id}.conf" 2>/dev/null | head -n1)
				type="VM"
				found=1
			# Verifica se é Container
			elif [ -f "$LXC_DIR/${target_id}.conf" ]; then
				config_file="$LXC_DIR/${target_id}.conf"
				type="Container"
				found=1
			# Verifica em subpastas
			elif [ -n "$(find "$LXC_DIR" -name "${target_id}.conf" 2>/dev/null)" ]; then
				config_file=$(find "$LXC_DIR" -name "${target_id}.conf" 2>/dev/null | head -n1)
				type="Container"
				found=1
			fi
			
			if [ $found -eq 0 ]; then
				echo ""
				echo -e "${COLOR_RED}  ✗ VM/Container ${target_id} não encontrado${COLOR_RESET}"
				sleep 2
				vm_config_checker
				return
			fi
			
			clear
			echo -e "${COLOR_CYAN}${COLOR_BOLD}"
			echo -e "╔═════════════════════════════════════════════════════════════════════╗"
			echo -e "║              🤖 Análise com IA em Progresso                         ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			echo -e "${COLOR_YELLOW}  Analisando ${type} ${target_id}...${COLOR_RESET}"
			echo ""
			
			local config_content=$(cat "$config_file")
			local analysis=$(analyze_with_openai "$config_content" "$type" "$target_id")
			
			clear
			echo -e "${COLOR_CYAN}${COLOR_BOLD}"
			echo -e "╔═════════════════════════════════════════════════════════════════════╗"
			echo -e "║            📊 Resultado da Análise - ${type} ${target_id}                           ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			
			if [ $? -eq 0 ]; then
				echo -e "${COLOR_WHITE}${analysis}${COLOR_RESET}"
			else
				echo -e "${COLOR_RED}  ✗ Erro ao analisar: ${analysis}${COLOR_RESET}"
			fi
			
			echo ""
			echo -e "${COLOR_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
			read -p "  Pressione ENTER para voltar..."
			vm_config_checker
			;;
		0)
			return
			;;
		*)
			vm_config_checker
			;;
	esac
}

