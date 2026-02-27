#!/bin/bash

# Caminho do arquivo .txt
ARQUIVO_USERS="usuarios.txt"

if [ -f "$ARQUIVO_USERS" ]; then
    echo "Iniciando a remoção de usuário(s)..."
    echo "Lendo conteúdo do arquivo $ARQUIVO_USERS..."

    #O IFS=: será utilizado para separar cada linha do arquivo em três variáveris
    while IFS=: read -r USER_LOGIN USER_NOME SETOR; do
        LOGIN="${USER_LOGIN,,}"
        echo "Verificando o usuário: $LOGIN..."
        
        # Verificando se o usuário não existe
        if id "$LOGIN" &>/dev/null; then
            # Remoção do usuário e do diretório do usuário
            echo "Removendo usuário $LOGIN e sua pasta pessoal..."
            sudo userdel -r "$LOGIN"
            echo "Usuário $LOGIN removido com sucesso!!"
        else
            echo "Aviso: O usuário $LOGIN não existe..."
            echo "Pulando a etapa de remoção do usuário $LOGIN..."
        fi
    done < "$ARQUIVO_USERS"
else
    echo "Erro: Arquivo $ARQUIVO_USERS não localizado!!"
fi

echo "Processo de remoção de usuário(s) finalizado!!"