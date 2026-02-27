#!/bin/bash

# Validando os nomes dos diretórios
if [ $# -eq 0 ]; then
    echo "Erro: Por favor, informe o nome da(s) pasta(s) que deseja remover!!"
    echo "Exemplo de uso: $0 pasta1 pasta2 pasta3..."
    exit 1
fi

echo "Iniciando a remoção de $# diretórios e grupos..."

# Loop para remover os diretórios
for PASTA in "$@"; do
    NOME_MIN="${PASTA,,}"
    NOME_MAI="${PASTA^^}"

    # Verificação e remoção dos diretórios
    if [ -d "/$NOME_MIN" ]; then
        sudo rm -rf "/$NOME_MIN"
        echo "Diretório /$NOME_MIN removido com sucesso!!"
    else
        echo "Aviso: O diretório /$NOME_MIN não existe."
        echo "Pulando a etapa de remoção do diretório /$NOME_MIN..."
    fi

    # Verificação e remoção de grupos
    if [ "$NOME_MIN" != "publico" ]; then
        if getent group "GRP_$NOME_MAI" > /dev/null; then
            sudo groupdel "GRP_$NOME_MAI"
            echo "Grupo GRP_$NOME_MAI removido com sucesso!!"
        else
            echo "Aviso: O grupo GRP_$NOME_MAI não existe."
            echo "Pulando a etapa de remoção do grupo GRP_$NOME_MAI..."
        fi
    fi
done

echo "Remoção de diretórios e grupos finalizada com sucesso!!"