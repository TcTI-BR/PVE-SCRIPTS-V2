#!/bin/bash

# Script de teste para diagnosticar busca de VMs/Containers
# Execute no servidor Proxmox: bash test_find_vms.sh

echo "=========================================="
echo "  TESTE DE BUSCA DE VMs E CONTAINERS"
echo "=========================================="
echo ""

QEMU_DIR="/etc/pve/qemu-server"
LXC_DIR="/etc/pve/lxc"

echo "1. Testando diretórios:"
echo "   QEMU_DIR: $QEMU_DIR"
echo "   LXC_DIR: $LXC_DIR"
echo ""

echo "2. Verificando se diretórios existem:"
if [ -d "$QEMU_DIR" ]; then
    echo "   ✓ $QEMU_DIR existe"
else
    echo "   ✗ $QEMU_DIR NÃO existe"
fi

if [ -d "$LXC_DIR" ]; then
    echo "   ✓ $LXC_DIR existe"
else
    echo "   ✗ $LXC_DIR NÃO existe"
fi
echo ""

echo "3. Listando arquivos com 'ls':"
echo "   VMs:"
ls -1 "$QEMU_DIR"/*.conf 2>/dev/null | head -5
echo ""
echo "   Containers:"
ls -1 "$LXC_DIR"/*.conf 2>/dev/null | head -5
echo ""

echo "4. Testando 'find' (método usado no script):"
echo "   VMs encontradas com find:"
find "$QEMU_DIR" -type f -name "*.conf" 2>/dev/null | head -5
echo ""
echo "   Containers encontrados com find:"
find "$LXC_DIR" -type f -name "*.conf" 2>/dev/null | head -5
echo ""

echo "5. Testando padrão regex:"
vm_count=0
echo "   Testando arquivos de VMs:"
while IFS= read -r file; do
    [ -n "$file" ] || continue
    basename=$(basename "$file")
    echo "      Arquivo: $basename"
    if [[ $basename =~ ^[0-9]+\.conf$ ]]; then
        echo "         ✓ MATCH! (aceito)"
        vm_count=$((vm_count + 1))
    else
        echo "         ✗ NO MATCH (rejeitado)"
    fi
done < <(find "$QEMU_DIR" -type f -name "*.conf" 2>/dev/null | head -5)
echo ""

ct_count=0
echo "   Testando arquivos de Containers:"
while IFS= read -r file; do
    [ -n "$file" ] || continue
    basename=$(basename "$file")
    echo "      Arquivo: $basename"
    if [[ $basename =~ ^[0-9]+\.conf$ ]]; then
        echo "         ✓ MATCH! (aceito)"
        ct_count=$((ct_count + 1))
    else
        echo "         ✗ NO MATCH (rejeitado)"
    fi
done < <(find "$LXC_DIR" -type f -name "*.conf" 2>/dev/null | head -5)
echo ""

echo "=========================================="
echo "  RESUMO"
echo "=========================================="
echo "VMs que passaram no regex: $vm_count"
echo "Containers que passaram no regex: $ct_count"
echo ""
echo "Se os números acima são 0, há um problema com o regex ou find."
echo "Se os números estão corretos, o script principal deveria funcionar."
echo "=========================================="

