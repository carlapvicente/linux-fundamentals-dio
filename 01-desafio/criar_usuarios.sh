#!/bin/bash

# Caminho do arquivo .txt
ARQUIVO_USERS="usuarios.txt"

if [ -f "$ARQUIVO_USERS" ]; then
    echo "Iniciando a criação de usuário(s)..."
    echo "Lendo conteúdo do arquivo $ARQUIVO_USERS..."

    #O IFS=: será utilizado para separar cada linha do arquivo em três variáveis
    while IFS=: read -r USER_LOGIN USER_NOME SETOR; do
        LOGIN="${USER_LOGIN,,}"
        NOME="${USER_NOME^}"
        GRUPO="GRP_${SETOR^^}"
        echo "Criando o usuário: $LOGIN e adicionando ao grupo $GRUPO..."

        # Verificando se o usuário já existe
        if id "$LOGIN" &>/dev/null; then
            echo "Aviso: O usuário $LOGIN já existe..."
            echo "Pulando a etapa de criação do usuário $LOGIN..."
        else
            # Criação do usuário e configuração básica inicial. Adiciona o usuário ao grupo de permissão (-G)
            sudo useradd "$LOGIN" -c "$NOME" -s /bin/bash -m -p $(openssl passwd -6 Senha123) -G "$GRUPO"
            # Força a troca da senha no primeiro login
            sudo passwd "$LOGIN"  -e
            echo "Sucesso: Usuário $LOGIN criado e adicionado ao grupo "$GRUPO"!!"
            echo "Aviso: Troca de senha obrigatória no primeiro login."
        fi

    done < "$ARQUIVO_USERS"
else
    echo "Erro: Arquivo $ARQUIVO_USERS não localizado!!"
fi
echo "Processo de criação de usuário(s) finalizado!!"