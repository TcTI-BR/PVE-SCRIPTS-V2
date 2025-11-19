#!/bin/bash

# Menu de Ceph Utils - Gerenciamento completo de cluster Ceph
# Versão: 1.0.0

# Função para limpar recursos temporários em caso de interrupção
cleanup_benchmark() {
    local pool_name=$1
    local image_name=$2
    if [ -n "$pool_name" ] && [ -n "$image_name" ]; then
        rbd rm "$pool_name/$image_name" 2>/dev/null
    fi
}

# Função para verificar se o Ceph está disponível
check_ceph_available() {
    if ! command -v ceph &> /dev/null; then
        echo -e "${COLOR_RED}${COLOR_BOLD}✗ ERRO: Ceph não está instalado ou não está no PATH${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Pressione uma tecla para continuar...${COLOR_RESET}"
        read -n 1
        return 1
    fi
    
    if ! ceph -s &> /dev/null; then
        echo -e "${COLOR_RED}${COLOR_BOLD}✗ ERRO: Não foi possível conectar ao cluster Ceph${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Verifique se o cluster está rodando e se você tem permissões adequadas.${COLOR_RESET}"
        echo -e "${COLOR_YELLOW}Pressione uma tecla para continuar...${COLOR_RESET}"
        read -n 1
        return 1
    fi
    return 0
}

# Função para selecionar pool da lista
select_pool() {
    local pools=($(ceph osd pool ls 2>/dev/null))
    
    if [ ${#pools[@]} -eq 0 ]; then
        echo -e "${COLOR_RED}Nenhum pool encontrado no cluster.${COLOR_RESET}"
        return 1
    fi
    
    echo -e "${COLOR_CYAN}${COLOR_BOLD}Pools disponíveis:${COLOR_RESET}"
    echo ""
    local i=1
    for pool in "${pools[@]}"; do
        echo -e "  ${COLOR_YELLOW}$i${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET} ${COLOR_WHITE}$pool${COLOR_RESET}"
        i=$((i+1))
    done
    echo ""
    echo -e "${COLOR_YELLOW}Selecione o número do pool: ${COLOR_RESET}"
    read -r pool_num
    
    if ! [[ "$pool_num" =~ ^[0-9]+$ ]] || [ "$pool_num" -lt 1 ] || [ "$pool_num" -gt ${#pools[@]} ]; then
        echo -e "${COLOR_RED}Seleção inválida.${COLOR_RESET}"
        return 1
    fi
    
    local selected_pool="${pools[$((pool_num-1))]}"
    echo "$selected_pool"
}

# Função para selecionar regra CRUSH da lista
select_crush_rule() {
    local rules=($(ceph osd crush rule ls 2>/dev/null))
    
    if [ ${#rules[@]} -eq 0 ]; then
        echo -e "${COLOR_RED}Nenhuma regra CRUSH encontrada.${COLOR_RESET}"
        return 1
    fi
    
    echo -e "${COLOR_CYAN}${COLOR_BOLD}Regras CRUSH disponíveis:${COLOR_RESET}"
    echo ""
    local i=1
    for rule in "${rules[@]}"; do
        echo -e "  ${COLOR_YELLOW}$i${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET} ${COLOR_WHITE}$rule${COLOR_RESET}"
        i=$((i+1))
    done
    echo ""
    echo -e "${COLOR_YELLOW}Selecione o número da regra: ${COLOR_RESET}"
    read -r rule_num
    
    if ! [[ "$rule_num" =~ ^[0-9]+$ ]] || [ "$rule_num" -lt 1 ] || [ "$rule_num" -gt ${#rules[@]} ]; then
        echo -e "${COLOR_RED}Seleção inválida.${COLOR_RESET}"
        return 1
    fi
    
    local selected_rule="${rules[$((rule_num-1))]}"
    echo "$selected_rule"
}

# Menu 1: Diagnóstico e Saúde (Read-Only)
diagnostico_menu() {
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                                                                     ║"
        echo -e "║              🔍 Diagnóstico e Saúde do Cluster Ceph                ║"
        echo -e "║                                                                     ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Status Rápido (ceph -s)${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Capacidade de Storage (ceph df)${COLOR_RESET}                      ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Mapa de Árvore OSD (ceph osd tree)${COLOR_RESET}                   ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Top 5 OSDs com Maior Latência${COLOR_RESET}                       ${COLOR_CYAN}│${COLOR_RESET}"
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
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Status do Cluster Ceph:${COLOR_RESET}"
                echo ""
                local status_output=$(ceph -s 2>&1)
                if echo "$status_output" | grep -q "HEALTH_OK"; then
                    echo -e "${COLOR_GREEN}$status_output${COLOR_RESET}"
                elif echo "$status_output" | grep -qE "HEALTH_WARN|HEALTH_ERR"; then
                    echo -e "${COLOR_RED}$status_output${COLOR_RESET}"
                else
                    echo "$status_output"
                fi
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            2)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Capacidade de Storage:${COLOR_RESET}"
                echo ""
                ceph df
                echo ""
                
                # Verificar pools com uso acima de 75%
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Verificando alertas de capacidade:${COLOR_RESET}"
                echo ""
                local alert_found=0
                
                # Usar ceph df para obter informações dos pools
                local pools=($(ceph osd pool ls 2>/dev/null))
                for pool in "${pools[@]}"; do
                    # Obter estatísticas do pool usando ceph df
                    local pool_stats=$(ceph df detail 2>/dev/null | grep -A 1 "^POOLS" | grep "$pool" 2>/dev/null)
                    if [ -n "$pool_stats" ]; then
                        # Tentar extrair valores (formato pode variar)
                        local used_kb=$(echo "$pool_stats" | awk '{print $2}' 2>/dev/null | sed 's/[^0-9]//g')
                        local total_kb=$(echo "$pool_stats" | awk '{print $4}' 2>/dev/null | sed 's/[^0-9]//g')
                        
                        if [ -n "$used_kb" ] && [ -n "$total_kb" ] && [ "$total_kb" -gt 0 ] 2>/dev/null; then
                            local percent=$((used_kb * 100 / total_kb))
                            if [ $percent -gt 75 ]; then
                                alert_found=1
                                if [ $percent -gt 90 ]; then
                                    echo -e "${COLOR_RED}⚠️  ALERTA CRÍTICO: Pool '$pool' está com ${percent}% de uso!${COLOR_RESET}"
                                else
                                    echo -e "${COLOR_YELLOW}⚠️  ALERTA: Pool '$pool' está com ${percent}% de uso${COLOR_RESET}"
                                fi
                            fi
                        fi
                    fi
                done
                
                # Alternativa: usar formato JSON se disponível
                if [ $alert_found -eq 0 ] && command -v jq &> /dev/null; then
                    local df_json=$(ceph df --format json 2>/dev/null)
                    if [ -n "$df_json" ]; then
                        echo "$df_json" | jq -r '.pools[] | select(.percent_used > 75) | "\(if .percent_used > 90 then "⚠️  ALERTA CRÍTICO" else "⚠️  ALERTA" end): Pool '\''\(.name)'\'' está com \(.percent_used)% de uso!"' 2>/dev/null | while read -r alert; do
                            if [ -n "$alert" ]; then
                                alert_found=1
                                if echo "$alert" | grep -q "CRÍTICO"; then
                                    echo -e "${COLOR_RED}$alert${COLOR_RESET}"
                                else
                                    echo -e "${COLOR_YELLOW}$alert${COLOR_RESET}"
                                fi
                            fi
                        done
                    fi
                fi
                
                if [ $alert_found -eq 0 ]; then
                    echo -e "${COLOR_GREEN}✓ Todos os pools estão com uso abaixo de 75%${COLOR_RESET}"
                fi
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            3)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Mapa de Árvore OSD:${COLOR_RESET}"
                echo ""
                ceph osd tree
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            4)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Top 5 OSDs com Maior Latência:${COLOR_RESET}"
                echo ""
                local perf_output=$(ceph osd perf 2>/dev/null)
                if [ -z "$perf_output" ]; then
                    echo -e "${COLOR_RED}Erro ao obter dados de performance${COLOR_RESET}"
                else
                    # Ordenar por commit_latency (coluna 3) e mostrar top 5
                    echo -e "${COLOR_WHITE}OSD ID | Latência de Commit (ms)${COLOR_RESET}"
                    echo -e "${COLOR_CYAN}────────────────────────────────────${COLOR_RESET}"
                    echo "$perf_output" | awk 'NR>1 {print $1, $3}' | sort -k2 -rn | head -5 | while read osd_id latency; do
                        if [ -n "$osd_id" ] && [ -n "$latency" ]; then
                            echo -e "${COLOR_YELLOW}OSD $osd_id${COLOR_RESET} | ${COLOR_RED}${latency} ms${COLOR_RESET}"
                        fi
                    done
                fi
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

# Menu 2: Benchmark (Teste de Performance)
benchmark_menu() {
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                                                                     ║"
        echo -e "║              ⚡ Benchmark e Teste de Performance Ceph                ║"
        echo -e "║                                                                     ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Teste de Escrita Sequencial (Throughput)${COLOR_RESET}            ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Teste de IOPS (Random)${COLOR_RESET}                              ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Teste de OSD Individual (Hardware)${COLOR_RESET}                  ${COLOR_CYAN}│${COLOR_RESET}"
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
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Teste de Escrita Sequencial (Throughput)${COLOR_RESET}"
                echo ""
                local pool=$(select_pool)
                if [ -z "$pool" ]; then
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                local image_name="bench_script_tmp_$$"
                local cleanup_done=0
                
                # Trap para garantir limpeza mesmo em caso de Ctrl+C
                trap 'if [ $cleanup_done -eq 0 ]; then cleanup_benchmark "$pool" "$image_name"; cleanup_done=1; fi' EXIT INT TERM
                
                echo -e "${COLOR_YELLOW}Criando imagem temporária...${COLOR_RESET}"
                if ! rbd create "$pool/$image_name" --size 1G 2>/dev/null; then
                    echo -e "${COLOR_RED}Erro ao criar imagem temporária${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo -e "${COLOR_GREEN}Executando teste de escrita sequencial...${COLOR_RESET}"
                echo -e "${COLOR_GRAY}(Pressione Ctrl+C para cancelar)${COLOR_RESET}"
                echo ""
                
                rbd bench-write "$pool/$image_name" --io-size 4194304 --io-threads 16 --io-total 1073741824 --io-pattern seq
                
                # Limpar imagem
                cleanup_benchmark "$pool" "$image_name"
                cleanup_done=1
                trap - EXIT INT TERM
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            2)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Teste de IOPS (Random)${COLOR_RESET}"
                echo ""
                local pool=$(select_pool)
                if [ -z "$pool" ]; then
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                local image_name="bench_script_tmp_$$"
                local cleanup_done=0
                
                trap 'if [ $cleanup_done -eq 0 ]; then cleanup_benchmark "$pool" "$image_name"; cleanup_done=1; fi' EXIT INT TERM
                
                echo -e "${COLOR_YELLOW}Criando imagem temporária...${COLOR_RESET}"
                if ! rbd create "$pool/$image_name" --size 1G 2>/dev/null; then
                    echo -e "${COLOR_RED}Erro ao criar imagem temporária${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo -e "${COLOR_GREEN}Executando teste de IOPS aleatório...${COLOR_RESET}"
                echo -e "${COLOR_GRAY}(Pressione Ctrl+C para cancelar)${COLOR_RESET}"
                echo ""
                
                rbd bench-write "$pool/$image_name" --io-size 4194304 --io-threads 16 --io-total 1073741824 --io-pattern rand
                
                cleanup_benchmark "$pool" "$image_name"
                cleanup_done=1
                trap - EXIT INT TERM
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            3)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Teste de OSD Individual (Hardware)${COLOR_RESET}"
                echo ""
                echo -e "${COLOR_YELLOW}OSDs ativos:${COLOR_RESET}"
                ceph osd ls
                echo ""
                echo -e "${COLOR_YELLOW}Digite o ID do OSD a ser testado: ${COLOR_RESET}"
                read -r osd_id
                
                if ! [[ "$osd_id" =~ ^[0-9]+$ ]]; then
                    echo -e "${COLOR_RED}ID inválido${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo -e "${COLOR_GREEN}Executando benchmark no OSD $osd_id...${COLOR_RESET}"
                echo ""
                ceph tell "osd.$osd_id" bench
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

# Menu 3: Gerenciamento de Pools
pools_menu() {
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                                                                     ║"
        echo -e "║              🗄️  Gerenciamento de Pools Ceph                          ║"
        echo -e "║                                                                     ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Listar Detalhes dos Pools${COLOR_RESET}                           ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Criar Novo Pool${COLOR_RESET}                                    ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Alterar Regra CRUSH de Pool${COLOR_RESET}                         ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_RED}Deletar Pool${COLOR_RED}${COLOR_RESET}${COLOR_WHITE} (DESTRUTIVO)${COLOR_RESET}                        ${COLOR_CYAN}│${COLOR_RESET}"
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
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Detalhes dos Pools:${COLOR_RESET}"
                echo ""
                
                # Usar ceph osd pool ls detail para obter informações mais precisas
                local pools=($(ceph osd pool ls 2>/dev/null))
                
                if [ ${#pools[@]} -eq 0 ]; then
                    echo -e "${COLOR_YELLOW}Nenhum pool encontrado.${COLOR_RESET}"
                else
                    printf "${COLOR_WHITE}%-20s${COLOR_RESET} | ${COLOR_YELLOW}%6s${COLOR_RESET} | ${COLOR_YELLOW}%8s${COLOR_RESET} | ${COLOR_CYAN}%s${COLOR_RESET}\n" "Nome do Pool" "Size" "Min_Size" "Regra CRUSH"
                    echo -e "${COLOR_CYAN}────────────────────────────────────────────────────────────────────${COLOR_RESET}"
                    
                    for pool in "${pools[@]}"; do
                        local pool_info=$(ceph osd pool get "$pool" all 2>/dev/null)
                        local size=$(echo "$pool_info" | grep -oP 'size:\s+\K[0-9]+' | head -1)
                        local min_size=$(echo "$pool_info" | grep -oP 'min_size:\s+\K[0-9]+' | head -1)
                        local rule_id=$(echo "$pool_info" | grep -oP 'crush_rule:\s+\K[0-9]+' | head -1)
                        
                        # Obter nome da regra
                        local rule_name="N/A"
                        if [ -n "$rule_id" ]; then
                            rule_name=$(ceph osd crush rule dump "$rule_id" 2>/dev/null | grep -oP '"rule_name"\s*:\s*"\K[^"]+' | head -1)
                            if [ -z "$rule_name" ]; then
                                rule_name="rule-$rule_id"
                            fi
                        fi
                        
                        size=${size:-"N/A"}
                        min_size=${min_size:-"N/A"}
                        
                        printf "${COLOR_WHITE}%-20s${COLOR_RESET} | ${COLOR_YELLOW}%6s${COLOR_RESET} | ${COLOR_YELLOW}%8s${COLOR_RESET} | ${COLOR_CYAN}%s${COLOR_RESET}\n" "$pool" "$size" "$min_size" "$rule_name"
                    done
                fi
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            2)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Criar Novo Pool${COLOR_RESET}"
                echo ""
                echo -e "${COLOR_YELLOW}Nome do pool: ${COLOR_RESET}"
                read -r pool_name
                
                if [ -z "$pool_name" ]; then
                    echo -e "${COLOR_RED}Nome do pool não pode ser vazio${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo -e "${COLOR_YELLOW}Número de Placement Groups (pg_num) [padrão: 32]: ${COLOR_RESET}"
                read -r pg_num
                pg_num=${pg_num:-32}
                
                if ! [[ "$pg_num" =~ ^[0-9]+$ ]]; then
                    echo -e "${COLOR_RED}pg_num deve ser um número${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                local rule=$(select_crush_rule)
                if [ -z "$rule" ]; then
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                echo -e "${COLOR_YELLOW}Criando pool '$pool_name' com pg_num=$pg_num e regra CRUSH '$rule'...${COLOR_RESET}"
                
                if ceph osd pool create "$pool_name" "$pg_num" "$pg_num" 2>/dev/null; then
                    if ceph osd pool set "$pool_name" crush_rule "$rule" 2>/dev/null; then
                        echo -e "${COLOR_GREEN}✓ Pool criado com sucesso!${COLOR_RESET}"
                    else
                        echo -e "${COLOR_YELLOW}⚠ Pool criado, mas falhou ao definir regra CRUSH${COLOR_RESET}"
                    fi
                else
                    echo -e "${COLOR_RED}✗ Erro ao criar pool${COLOR_RESET}"
                fi
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            3)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Alterar Regra CRUSH de Pool${COLOR_RESET}"
                echo ""
                local pool=$(select_pool)
                if [ -z "$pool" ]; then
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                local new_rule=$(select_crush_rule)
                if [ -z "$new_rule" ]; then
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                echo -e "${COLOR_YELLOW}Alterando regra CRUSH do pool '$pool' para '$new_rule'...${COLOR_RESET}"
                echo -e "${COLOR_RED}ATENÇÃO: Esta operação pode causar migração de dados!${COLOR_RESET}"
                echo -e "${COLOR_YELLOW}Deseja continuar? (s/N): ${COLOR_RESET}"
                read -r confirm
                
                if [[ "$confirm" =~ ^[Ss]$ ]]; then
                    if ceph osd pool set "$pool" crush_rule "$new_rule" 2>/dev/null; then
                        echo -e "${COLOR_GREEN}✓ Regra CRUSH alterada com sucesso!${COLOR_RESET}"
                        echo -e "${COLOR_YELLOW}A migração de dados será iniciada automaticamente.${COLOR_RESET}"
                    else
                        echo -e "${COLOR_RED}✗ Erro ao alterar regra CRUSH${COLOR_RESET}"
                    fi
                else
                    echo -e "${COLOR_YELLOW}Operação cancelada.${COLOR_RESET}"
                fi
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            4)
                clear
                echo -e "${COLOR_RED}${COLOR_BOLD}⚠️  ATENÇÃO: OPERAÇÃO DESTRUTIVA ⚠️${COLOR_RESET}"
                echo ""
                echo -e "${COLOR_RED}Deletar um pool irá remover TODOS os dados armazenados nele!${COLOR_RESET}"
                echo ""
                local pool=$(select_pool)
                if [ -z "$pool" ]; then
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                echo -e "${COLOR_RED}${COLOR_BOLD}Você está prestes a DELETAR o pool: ${COLOR_WHITE}$pool${COLOR_RESET}"
                echo ""
                echo -e "${COLOR_YELLOW}Digite o nome do pool para confirmar: ${COLOR_RESET}"
                read -r confirm_name
                
                if [ "$confirm_name" != "$pool" ]; then
                    echo -e "${COLOR_RED}Nome não confere. Operação cancelada.${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                echo -e "${COLOR_RED}Digite 'SIM' (em maiúsculas) para confirmar a exclusão: ${COLOR_RESET}"
                read -r final_confirm
                
                if [ "$final_confirm" != "SIM" ]; then
                    echo -e "${COLOR_YELLOW}Operação cancelada.${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                echo -e "${COLOR_RED}Deletando pool '$pool'...${COLOR_RESET}"
                if ceph osd pool delete "$pool" "$pool" --yes-i-really-really-mean-it 2>/dev/null; then
                    echo -e "${COLOR_GREEN}✓ Pool deletado com sucesso${COLOR_RESET}"
                else
                    echo -e "${COLOR_RED}✗ Erro ao deletar pool${COLOR_RESET}"
                fi
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

# Menu 4: Otimização e Tuning (Hardware Check)
otimizacao_menu() {
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                                                                     ║"
        echo -e "║              ⚙️  Otimização e Tuning de Hardware                    ║"
        echo -e "║                                                                     ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verificar Governor CPU${COLOR_RESET}                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verificar Cache de Disco NVMe${COLOR_RESET}                        ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Verificar Configuração de Rede (MTU)${COLOR_RESET}                ${COLOR_CYAN}│${COLOR_RESET}"
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
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Verificação de Governor CPU:${COLOR_RESET}"
                echo ""
                local cores=$(nproc)
                local issues=0
                
                for ((cpu=0; cpu<cores; cpu++)); do
                    if [ -f "/sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor" ]; then
                        local governor=$(cat "/sys/devices/system/cpu/cpu${cpu}/cpufreq/scaling_governor" 2>/dev/null)
                        if [ "$governor" != "performance" ]; then
                            echo -e "${COLOR_RED}⚠️  CPU $cpu: $governor (recomendado: performance)${COLOR_RESET}"
                            issues=$((issues+1))
                        else
                            echo -e "${COLOR_GREEN}✓ CPU $cpu: $governor${COLOR_RESET}"
                        fi
                    fi
                done
                
                if [ $issues -eq 0 ]; then
                    echo ""
                    echo -e "${COLOR_GREEN}✓ Todos os núcleos estão configurados para 'performance'${COLOR_RESET}"
                else
                    echo ""
                    echo -e "${COLOR_YELLOW}⚠️  $issues núcleo(s) não estão em modo 'performance'${COLOR_RESET}"
                    echo -e "${COLOR_GRAY}Para corrigir, execute:${COLOR_RESET}"
                    echo -e "${COLOR_GRAY}for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance | sudo tee \$cpu; done${COLOR_RESET}"
                fi
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            2)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Verificação de Cache de Disco NVMe:${COLOR_RESET}"
                echo ""
                local nvme_devices=($(ls /dev/nvme* 2>/dev/null | grep -E '^/dev/nvme[0-9]+$'))
                
                if [ ${#nvme_devices[@]} -eq 0 ]; then
                    echo -e "${COLOR_YELLOW}Nenhum dispositivo NVMe encontrado${COLOR_RESET}"
                else
                    for device in "${nvme_devices[@]}"; do
                        local device_name=$(basename "$device")
                        echo -e "${COLOR_WHITE}Dispositivo: $device_name${COLOR_RESET}"
                        
                        # Verificar feature 0x06 (Volatile Write Cache)
                        local cache_status=$(nvme id-ctrl "$device" 2>/dev/null | grep -i "vwc" | head -1)
                        if [ -n "$cache_status" ]; then
                            if echo "$cache_status" | grep -qi "enabled\|on\|1"; then
                                echo -e "  ${COLOR_GREEN}✓ Volatile Write Cache: ON${COLOR_RESET}"
                            else
                                echo -e "  ${COLOR_YELLOW}⚠ Volatile Write Cache: OFF${COLOR_RESET}"
                            fi
                        else
                            echo -e "  ${COLOR_GRAY}  Informação de cache não disponível${COLOR_RESET}"
                        fi
                        echo ""
                    done
                fi
                read -p "Pressione uma tecla para continuar..."
                ;;
            3)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Verificação de Configuração de Rede (MTU):${COLOR_RESET}"
                echo ""
                local interfaces=($(ip link show | grep -E "^[0-9]+:" | awk -F': ' '{print $2}' | grep -v "lo"))
                local issues=0
                
                for iface in "${interfaces[@]}"; do
                    # Verificar se é interface física (não virtual)
                    if [ -d "/sys/class/net/$iface" ] && [ ! -L "/sys/class/net/$iface/device" ] || [ -L "/sys/class/net/$iface/device" ]; then
                        local mtu=$(ip link show "$iface" 2>/dev/null | grep -oP 'mtu \K[0-9]+')
                        if [ -n "$mtu" ]; then
                            if [ "$mtu" -eq 1500 ]; then
                                echo -e "${COLOR_RED}⚠️  $iface: MTU=$mtu (recomendado: 9000 para storage)${COLOR_RESET}"
                                issues=$((issues+1))
                            else
                                echo -e "${COLOR_GREEN}✓ $iface: MTU=$mtu${COLOR_RESET}"
                            fi
                        fi
                    fi
                done
                
                if [ $issues -eq 0 ]; then
                    echo ""
                    echo -e "${COLOR_GREEN}✓ Todas as interfaces físicas têm MTU adequado${COLOR_RESET}"
                else
                    echo ""
                    echo -e "${COLOR_YELLOW}⚠️  $issues interface(s) com MTU=1500 (considere 9000 para redes storage)${COLOR_RESET}"
                fi
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

# Menu 5: Utilitários de OSD
osd_menu() {
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                                                                     ║"
        echo -e "║              🔧 Utilitários de OSD (Device Classes)                  ║"
        echo -e "║                                                                     ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Alterar Classe de OSD${COLOR_RESET}                                ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Reiniciar OSD Local${COLOR_RESET}                                   ${COLOR_CYAN}│${COLOR_RESET}"
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
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Alterar Classe de OSD${COLOR_RESET}"
                echo ""
                echo -e "${COLOR_YELLOW}OSDs e suas classes atuais:${COLOR_RESET}"
                echo ""
                local osd_tree=$(ceph osd tree 2>/dev/null)
                if [ -n "$osd_tree" ]; then
                    echo "$osd_tree" | grep -E "osd\.[0-9]+" | while read -r line; do
                        local osd_id=$(echo "$line" | grep -oP 'osd\.\K[0-9]+' | head -1)
                        if [ -n "$osd_id" ]; then
                            # Tentar extrair classe de diferentes formatos
                            local class=$(echo "$line" | grep -oP 'class\s+\K[^\s,]+' || echo "nenhuma")
                            if [ "$class" = "nenhuma" ]; then
                                # Tentar outro formato
                                class=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if($i=="class") print $(i+1)}' || echo "nenhuma")
                            fi
                            echo -e "  ${COLOR_WHITE}OSD $osd_id${COLOR_RESET}: ${COLOR_CYAN}$class${COLOR_RESET}"
                        fi
                    done
                else
                    echo -e "${COLOR_RED}Erro ao obter informações dos OSDs${COLOR_RESET}"
                fi
                echo ""
                echo -e "${COLOR_YELLOW}Digite o ID do OSD: ${COLOR_RESET}"
                read -r osd_id
                
                if ! [[ "$osd_id" =~ ^[0-9]+$ ]]; then
                    echo -e "${COLOR_RED}ID inválido${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo -e "${COLOR_YELLOW}Digite o nome da nova classe (ex: ssd, nvme, nvme-backup, hdd): ${COLOR_RESET}"
                read -r new_class
                
                if [ -z "$new_class" ]; then
                    echo -e "${COLOR_RED}Nome da classe não pode ser vazio${COLOR_RESET}"
                    read -p "Pressione uma tecla para continuar..."
                    continue
                fi
                
                echo ""
                echo -e "${COLOR_YELLOW}Alterando classe do OSD $osd_id para '$new_class'...${COLOR_RESET}"
                
                # Remover classe antiga e definir nova
                if ceph osd crush rm-device-class "osd.$osd_id" 2>/dev/null; then
                    echo -e "${COLOR_GRAY}Classe antiga removida${COLOR_RESET}"
                fi
                
                if ceph osd crush set-device-class "$new_class" "osd.$osd_id" 2>/dev/null; then
                    echo -e "${COLOR_GREEN}✓ Classe alterada com sucesso!${COLOR_RESET}"
                else
                    echo -e "${COLOR_RED}✗ Erro ao alterar classe${COLOR_RESET}"
                fi
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            2)
                clear
                echo -e "${COLOR_CYAN}${COLOR_BOLD}Reiniciar OSD Local${COLOR_RESET}"
                echo ""
                echo -e "${COLOR_YELLOW}Detectando OSDs presentes nesta máquina...${COLOR_RESET}"
                echo ""
                
                # Detectar OSDs locais verificando /var/lib/ceph/osd/
                local local_osds=()
                if [ -d "/var/lib/ceph/osd" ]; then
                    for osd_dir in /var/lib/ceph/osd/ceph-*; do
                        if [ -d "$osd_dir" ]; then
                            local osd_id=$(basename "$osd_dir" | sed 's/ceph-//')
                            if [[ "$osd_id" =~ ^[0-9]+$ ]]; then
                                # Verificar se o serviço existe
                                if systemctl list-units --full -all 2>/dev/null | grep -q "ceph-osd@$osd_id"; then
                                    local_osds+=("$osd_id")
                                fi
                            fi
                        fi
                    done
                fi
                
                if [ ${#local_osds[@]} -eq 0 ]; then
                    echo -e "${COLOR_YELLOW}Nenhum OSD local encontrado${COLOR_RESET}"
                else
                    echo -e "${COLOR_WHITE}OSDs encontrados nesta máquina:${COLOR_RESET}"
                    local i=1
                    for osd_id in "${local_osds[@]}"; do
                        local status=$(systemctl is-active ceph-osd@$osd_id 2>/dev/null || echo "unknown")
                        if [ "$status" = "active" ]; then
                            echo -e "  ${COLOR_YELLOW}$i${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET} ${COLOR_WHITE}OSD $osd_id${COLOR_RESET} ${COLOR_GREEN}(ativo)${COLOR_RESET}"
                        else
                            echo -e "  ${COLOR_YELLOW}$i${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET} ${COLOR_WHITE}OSD $osd_id${COLOR_RESET} ${COLOR_RED}($status)${COLOR_RESET}"
                        fi
                        i=$((i+1))
                    done
                    echo ""
                    echo -e "${COLOR_YELLOW}Selecione o número do OSD para reiniciar: ${COLOR_RESET}"
                    read -r osd_num
                    
                    if [[ "$osd_num" =~ ^[0-9]+$ ]] && [ "$osd_num" -ge 1 ] && [ "$osd_num" -le ${#local_osds[@]} ]; then
                        local selected_osd="${local_osds[$((osd_num-1))]}"
                        echo ""
                        echo -e "${COLOR_YELLOW}Reiniciando OSD $selected_osd...${COLOR_RESET}"
                        if systemctl restart "ceph-osd@$selected_osd" 2>/dev/null; then
                            sleep 2
                            local status=$(systemctl is-active "ceph-osd@$selected_osd" 2>/dev/null)
                            if [ "$status" = "active" ]; then
                                echo -e "${COLOR_GREEN}✓ OSD $selected_osd reiniciado com sucesso!${COLOR_RESET}"
                            else
                                echo -e "${COLOR_YELLOW}⚠ OSD $selected_osd reiniciado, mas status atual: $status${COLOR_RESET}"
                            fi
                        else
                            echo -e "${COLOR_RED}✗ Erro ao reiniciar OSD $selected_osd${COLOR_RESET}"
                        fi
                    else
                        echo -e "${COLOR_RED}Seleção inválida${COLOR_RESET}"
                    fi
                fi
                
                echo ""
                read -p "Pressione uma tecla para continuar..."
                ;;
            0)
                return
                ;;
            *)
                ;;
        esac
    done
}

# Menu Principal do Ceph Utils
ceph_menu() {
    if ! check_ceph_available; then
        disco_menu
        return
    fi
    
    while true; do
        clear
        echo -e "${COLOR_CYAN}${COLOR_BOLD}"
        echo -e "╔═════════════════════════════════════════════════════════════════════╗"
        echo -e "║                                                                     ║"
        echo -e "║                    🐙 Ceph Utils - Gerenciamento                    ║"
        echo -e "║                                                                     ║"
        echo -e "╚═════════════════════════════════════════════════════════════════════╝"
        echo -e "${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_BOLD}  Selecione uma opção:${COLOR_RESET}"
        echo ""
        echo -e "  ${COLOR_CYAN}┌───────────────────────────────────────────────────────────────┐${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}1${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Diagnóstico e Saúde (Read-Only)${COLOR_RESET}                      ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}2${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Benchmark (Teste de Performance)${COLOR_RESET}                    ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}3${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Gerenciamento de Pools${COLOR_RESET}                            ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}4${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Otimização e Tuning (Hardware Check)${COLOR_RESET}              ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_YELLOW}5${COLOR_RESET} ${COLOR_GREEN}➜${COLOR_RESET}  ${COLOR_WHITE}Utilitários de OSD (Device Classes)${COLOR_RESET}                 ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}  ${COLOR_RED}0${COLOR_RESET} ${COLOR_RED}➜${COLOR_RESET}  ${COLOR_WHITE}Voltar${COLOR_RESET}                                                  ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}│${COLOR_RESET}                                                               ${COLOR_CYAN}│${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}└───────────────────────────────────────────────────────────────┘${COLOR_RESET}"
        echo ""
        echo -e "${COLOR_YELLOW}  Digite sua opção: ${COLOR_RESET}"
        read -rsn1 opt
        
        case $opt in
            1)
                diagnostico_menu
                ;;
            2)
                benchmark_menu
                ;;
            3)
                pools_menu
                ;;
            4)
                otimizacao_menu
                ;;
            5)
                osd_menu
                ;;
            0)
                disco_menu
                ;;
            *)
                ;;
        esac
    done
}

