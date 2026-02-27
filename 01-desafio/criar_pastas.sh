#!/bin/bash

# Validando os nomes dos diretórios
if [ $# -eq 0 ]; then
    echo "Erro: Por favor, informe o nome da(s) pasta(s) que deseja criar!!"
    echo "Exemplo de uso: $0 pasta1 pasta2 pasta3..."
    exit 1
fi

echo "Iniciando a criação de $# diretório(s) e grupo(s)..."

# Loop para criar os diretórios
for PASTA in "$@"; do
    NOME_MIN="${PASTA,,}"
    NOME_MAI="${PASTA^^}"

    # Verificação e criação dos diretórios
    if [ -d "/$NOME_MIN" ]; then
        echo "Aviso: O diretório /$NOME_MIN já existe."
        echo "Pulando a etapa de criação do diretório /$NOME_MIN..."
    else
        sudo mkdir -p "/$NOME_MIN"
        echo "Diretório /$NOME_MIN criado com sucesso!!"
    fi

    # Verificação e criação de grupos e aplicação de permissões
    if [ "$NOME_MIN" == "publico" ]; then
        # Ativa o Sticky Bit (1), o usuário só pode deletar o(s) próprio(s) arquivo(s).
        sudo chmod 1777 "/$NOME_MIN"
        echo "Aplicadas as permissões para a pasta pública /$NOME_MIN (1777 - Sticky Bit ativo)"
    else
        # Verificação e criação dos grupos
        if getent group "GRP_$NOME_MAI" > /dev/null; then
            echo "Aviso: O grupo GRP_$NOME_MAI já existe."
            echo "Pulando a etapa de criação do grupo GRP_$NOME_MAI..."
        else
            sudo groupadd "GRP_$NOME_MAI"
            echo "Grupo GRP_$NOME_MAI criado com sucesso!!"
        fi

        # Aplica dono e permissão
        sudo chown root:"GRP_$NOME_MAI" "/$NOME_MIN"
        # Ativa o Sticky Bit (1), o usuário só pode deletar o(s) próprio(s) arquivo(s).
        # Ativa o SGID (2), novos arquivos pertencem ao grupo dono da pasta.
        sudo chmod 3770 "/$NOME_MIN"
        echo "Acesso restrito configurado com sucesso do grupo GRP_$NOME_MAI para o diretório /$NOME_MIN (3770 - SGID e Sticky Bit ativos)!!"
    fi
done

echo "Criação de diretório(s) e grupo(s) finalizada com sucesso!!"