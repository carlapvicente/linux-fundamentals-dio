#!/bin/bash

ARQUIVO_USERS="usuarios.txt"
MODO=$1 # Recebe o primeiro argumento (pode ser --limpar ou nada)

# Se o primeiro argumento for --limpar, removemos ele da lista de argumentos ($@)
# para que sobrem apenas os nomes das pastas.
if [ "$MODO" == "--limpar" ]; then
    shift
    TITULO="VALIDAÇÃO DE REMOÇÃO (LIMPEZA)"
    CHECK_EXISTE="❌" # Se existir, é erro
    CHECK_AUSENTE="✅" # Se não existir, é sucesso
else
    TITULO="VALIDAÇÃO DE CRIAÇÃO"
    CHECK_EXISTE="✅"
    CHECK_AUSENTE="❌"
fi

echo "=================================================="
echo "      $TITULO      "
echo "=================================================="

# 1. Validando Diretórios
echo -e "\n[ VALIDANDO DIRETÓRIOS E PERMISSÕES ]"
echo "--------------------------------------------------"
for pasta in "$@"; do
    if [ -d "/$pasta" ]; then
        PERM=$(stat -c "%a" "/$pasta")
        DONO=$(stat -c "%U:%G" "/$pasta")
        echo "$CHECK_EXISTE /$pasta : CRIADO COM SUCESSO | Permissão: $PERM | Dono:Grupo: $DONO"
    else
        echo "$CHECK_AUSENTE /$pasta : NÃO LOCALIZADO NO SISTEMA"
    fi
done
echo "--------------------------------------------------"

# 2. Validando Grupos
echo -e "\n[ VALIDANDO GRUPOS DO SISTEMA ]"
echo "--------------------------------------------------"
for pasta in "$@"; do
    if [ "$pasta" != "publico" ]; then
        GRUPO="GRP_${pasta^^}"
        if getent group "$GRUPO" > /dev/null; then
            echo "$CHECK_EXISTE $GRUPO : CRIADO COM SUCESSO"
        else
            echo "$CHECK_AUSENTE $GRUPO : NÃO LOCALIZADO NO SISTEMA"
        fi
    fi
done
echo "--------------------------------------------------"

# 3. Validando Usuários
echo -e "\n[ VALIDANDO USUÁRIOS ]"
echo "--------------------------------------------------"
if [ -f "$ARQUIVO_USERS" ]; then
    while IFS=: read -r USER_LOGIN USER_NOME SETOR; do
        LOGIN="${USER_LOGIN,,}"
        if id "$LOGIN" &>/dev/null; then
            echo "$CHECK_EXISTE $LOGIN : LOCALIZADO NO SISTEMA"
        else
            echo "$CHECK_AUSENTE $LOGIN : NÃO LOCALIZADO NO SISTEMA"
        fi
    done < "$ARQUIVO_USERS"
else
    echo "FALHA: Arquivo $ARQUIVO_USERS não encontrado."
fi
echo "--------------------------------------------------"
echo -e "\n================================================"
echo "                FIM DA VALIDAÇÃO                "
echo "================================================"