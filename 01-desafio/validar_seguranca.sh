#!/bin/bash
# Uso: ./validar_seguranca.sh /nome_da_pasta GRP_NOME

PASTA=$1
GRUPO=$2

echo "=================================="
echo "      AUDITORIA DE SEGURANÇA      "
echo "=================================="

# 1. Criando usuários temporários para o teste
sudo useradd -m -G "$GRUPO" temp_user1 &>/dev/null
sudo useradd -m -G "$GRUPO" temp_user2 &>/dev/null

# 2. Testando o SGID (Herança de Grupo)
sudo -u temp_user1 touch "$PASTA/teste_sgid"
GRUPO_ARQUIVO=$(stat -c "%G" "$PASTA/teste_sgid")

if [ "$GRUPO_ARQUIVO" == "$GRUPO" ]; then
    echo "✅ SGID: OK (Arquivos herdam o grupo $GRUPO)"
else
    echo "❌ SGID: FALHA"
fi

# 3. Testando o Sticky Bit (Proteção de Exclusão)
ERRO_SABOTAGEM=$(sudo -u temp_user2 rm "$PASTA/teste_sgid" 2>&1)

if [[ $ERRO_SABOTAGEM == *"Operation not permitted"* ]]; then
    echo "✅ STICKY BIT: OK (Um usuário não pôde apagar o arquivo do outro)"
else
    echo "❌ STICKY BIT: FALHA (Permissão de exclusão está insegura!)"
fi

# Limpeza dos rastros
sudo rm -f "$PASTA/teste_sgid"
sudo userdel -r temp_user1 &>/dev/null
sudo userdel -r temp_user2 &>/dev/null
echo "=================================="
echo "  FIM DA AUDITORIA DE SEGURANÇA   "
echo "=================================="