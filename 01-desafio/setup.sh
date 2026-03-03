#!/bin/bash

echo "=========================================="
echo "    🚀 INICIANDO CONFIGURAÇÃO DO AMBIENTE    "
echo "=========================================="
echo ""

# 1. Verificando a dependência: openssl
echo "🔎 Verificando se o 'openssl' está instalado..."
if ! command -v openssl &> /dev/null; then
    echo "❌ ERRO: 'openssl' não encontrado."
    echo "   'openssl' é necessário para a criação de senhas de usuários."
    echo "   Por favor, instale-o usando o gerenciador de pacotes da sua distribuição."
    echo "   Exemplo para Debian/Ubuntu: sudo apt-get update && sudo apt-get install openssl"
    echo ""
    exit 1
else
    echo "✅ 'openssl' encontrado."
fi
echo ""

# 2. Concedendo permissão de execução para os scripts .sh
echo "🔑 Concedendo permissão de execução para os scripts (*.sh)..."
chmod +x *.sh
echo "✅ Permissões aplicadas com sucesso."
echo ""

echo "=========================================="
echo "    🎉 CONFIGURAÇÃO CONCLUÍDA! 🎉    "
echo "=========================================="
echo "Agora você pode executar o script principal com: sudo ./iac.sh"
echo ""