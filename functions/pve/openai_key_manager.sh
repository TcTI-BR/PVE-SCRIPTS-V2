#!/bin/bash

# Gerenciador de Chave OpenAI
# Versão: V003.R002
# Adicionado em: 2025-11-17

# Arquivo onde a chave será armazenada
OPENAI_KEY_FILE="/root/.openai_key"

# Função para exibir a chave parcialmente (segurança)
show_masked_key() {
	local key=$1
	local key_length=${#key}
	
	if [ $key_length -gt 12 ]; then
		# Mostra os primeiros 4 e últimos 4 caracteres
		local prefix="${key:0:4}"
		local suffix="${key: -4}"
		echo "${prefix}...${suffix}"
	else
		echo "***"
	fi
}

openai_key_manager(){
	clear
	
	echo -e "${COLOR_CYAN}${COLOR_BOLD}"
	echo -e "╔═════════════════════════════════════════════════════════════════════╗"
	echo -e "║                                                                     ║"
	echo -e "║                🔑 Gerenciar Chave OpenAI                             ║"
	echo -e "║                                                                     ║"
	echo -e "╚═════════════════════════════════════════════════════════════════════╝"
	echo -e "${COLOR_RESET}"
	echo ""
	
	# Verifica se a chave existe
	if [ -f "$OPENAI_KEY_FILE" ]; then
		CURRENT_KEY=$(cat "$OPENAI_KEY_FILE")
		MASKED_KEY=$(show_masked_key "$CURRENT_KEY")
		
		echo -e "${COLOR_GREEN}  ✓ Chave OpenAI cadastrada${COLOR_RESET}"
		echo -e "${COLOR_WHITE}  Chave atual: ${COLOR_YELLOW}${MASKED_KEY}${COLOR_RESET}"
		echo ""
	else
		echo -e "${COLOR_RED}  ✗ Nenhuma chave OpenAI cadastrada${COLOR_RESET}"
		echo -e "${COLOR_YELLOW}  Por favor, cadastre uma chave para utilizar os recursos de IA${COLOR_RESET}"
		echo ""
	fi
	
	echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
	echo ""
	echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Cadastrar/Atualizar chave${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Deletar chave${COLOR_RESET}                                          ${COLOR_CYAN}│${COLOR_RESET}"
	echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Testar chave${COLOR_RESET}                                           ${COLOR_CYAN}│${COLOR_RESET}"
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
			echo -e "║                 Cadastrar/Atualizar Chave OpenAI                    ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			echo -e "${COLOR_WHITE}  Digite sua chave API da OpenAI:${COLOR_RESET}"
			echo -e "${COLOR_GRAY}  (A chave geralmente começa com 'sk-')${COLOR_RESET}"
			echo ""
			read -p "  Chave: " new_key
			
			if [ -z "$new_key" ]; then
				echo ""
				echo -e "${COLOR_RED}  ✗ Erro: A chave não pode estar vazia${COLOR_RESET}"
				sleep 2
				openai_key_manager
				return
			fi
			
			# Salva a chave no arquivo
			echo "$new_key" > "$OPENAI_KEY_FILE"
			chmod 600 "$OPENAI_KEY_FILE"  # Permissões restritas para segurança
			
			echo ""
			echo -e "${COLOR_GREEN}  ✓ Chave cadastrada com sucesso!${COLOR_RESET}"
			sleep 2
			openai_key_manager
			;;
		2)
			if [ ! -f "$OPENAI_KEY_FILE" ]; then
				clear
				echo -e "${COLOR_RED}  ✗ Nenhuma chave cadastrada para deletar${COLOR_RESET}"
				sleep 2
				openai_key_manager
				return
			fi
			
			clear
			echo -e "${COLOR_RED}${COLOR_BOLD}"
			echo -e "╔═════════════════════════════════════════════════════════════════════╗"
			echo -e "║                      Deletar Chave OpenAI                           ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			echo -e "${COLOR_YELLOW}  ATENÇÃO: Esta ação não pode ser desfeita!${COLOR_RESET}"
			echo ""
			read -p "  Tem certeza que deseja deletar a chave? (s/N): " confirm
			
			if [[ $confirm =~ ^[Ss]$ ]]; then
				rm -f "$OPENAI_KEY_FILE"
				echo ""
				echo -e "${COLOR_GREEN}  ✓ Chave deletada com sucesso!${COLOR_RESET}"
				sleep 2
			else
				echo ""
				echo -e "${COLOR_YELLOW}  ✗ Operação cancelada${COLOR_RESET}"
				sleep 2
			fi
			openai_key_manager
			;;
		3)
			if [ ! -f "$OPENAI_KEY_FILE" ]; then
				clear
				echo -e "${COLOR_RED}  ✗ Nenhuma chave cadastrada para testar${COLOR_RESET}"
				sleep 2
				openai_key_manager
				return
			fi
			
			clear
			echo -e "${COLOR_CYAN}${COLOR_BOLD}"
			echo -e "╔═════════════════════════════════════════════════════════════════════╗"
			echo -e "║                     Testar Chave OpenAI                             ║"
			echo -e "╚═════════════════════════════════════════════════════════════════════╝"
			echo -e "${COLOR_RESET}"
			echo ""
			echo -e "${COLOR_YELLOW}  Testando conexão com a API da OpenAI...${COLOR_RESET}"
			echo ""
			
			CURRENT_KEY=$(cat "$OPENAI_KEY_FILE")
			
			# Testa a chave fazendo uma requisição simples à API
			response=$(curl -s -w "\n%{http_code}" -X GET \
				-H "Authorization: Bearer $CURRENT_KEY" \
				"https://api.openai.com/v1/models" 2>&1)
			
			http_code=$(echo "$response" | tail -n1)
			body=$(echo "$response" | head -n-1)
			
			if [ "$http_code" = "200" ]; then
				echo -e "${COLOR_GREEN}  ✓ Chave válida! Conexão estabelecida com sucesso.${COLOR_RESET}"
			elif [ "$http_code" = "401" ]; then
				echo -e "${COLOR_RED}  ✗ Chave inválida! Verifique sua chave API.${COLOR_RESET}"
			elif [ "$http_code" = "429" ]; then
				echo -e "${COLOR_YELLOW}  ⚠ Limite de requisições atingido. A chave é válida mas está temporariamente bloqueada.${COLOR_RESET}"
			else
				echo -e "${COLOR_RED}  ✗ Erro ao testar a chave (Código: $http_code)${COLOR_RESET}"
				echo -e "${COLOR_GRAY}  Verifique sua conexão com a internet.${COLOR_RESET}"
			fi
			
			echo ""
			read -p "  Pressione ENTER para continuar..."
			openai_key_manager
			;;
		0)
			return
			;;
		*)
			openai_key_manager
			;;
	esac
}

