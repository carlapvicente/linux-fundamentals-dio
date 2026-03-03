#!/bin/bash

# --- VALIDAÇÃO DE SUPERUSUÁRIO ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ ERRO: Este script deve ser executado como root (use sudo)."
    exit 1
fi

# Carregando configurações
if [ -f "./config.conf" ]; then
    source "./config.conf"
else
    echo "❌ ERRO: Arquivo de configuração 'config.conf' não encontrado."
    exit 1
fi

MODO=$1
ARQUIVO_USERS="usuarios.txt"

if [ ! -f "$ARQUIVO_USERS" ]; then
    echo "==========================================================================="
    echo "❌ ERRO: Arquivo '$ARQUIVO_USERS' não localizado!"
    echo "Para prosseguir, crie um arquivo com o nome '$ARQUIVO_USERS' no seguinte formato:"
    echo "login:Nome Completo:setor"
    echo "Exemplo:"
    echo "carlos:Carlos Silva:adm"
    echo "==========================================================================="
    exit 1
fi

# Definição de mensagens de cabeçalho e rodapé baseadas no modo
case $MODO in
    --criar)
        MSG_TITULO="⏳ Iniciando a criação de usuário(s)..."
        MSG_FIM="✅ Criação de usuário(s) finalizada com sucesso!!"
        ;;
    --remover)
        MSG_TITULO="⏳ Iniciando a remoção de usuário(s)..."
        MSG_FIM="✅ Remoção de usuário(s) finalizada com sucesso!!"
        ;;
    --validar)
        MSG_TITULO="⏳ Iniciando a validação de criação de usuário(s)..."
        MSG_FIM="✅ Validação de criação de usuário(s) finalizada com sucesso!!"
        ;;
    --validar-remocao)
        MSG_TITULO="⏳ Iniciando a validação de remoção de usuário(s)..."
        MSG_FIM="✅ Validação de remoção de usuário(s) finalizada com sucesso!!"
        ;;
    *)
        echo "Opção inválida. Use: --criar, --remover, --validar ou --validar-remocao"
        exit 1
        ;;
esac

echo "================================================================="
echo "$MSG_TITULO"
echo "================================================================="
echo ""

while IFS=: read -r USER_LOGIN USER_NOME SETOR; do
    LOGIN="${USER_LOGIN,,}"
    NOME="${USER_NOME^}"
    GRUPO="GRP_${SETOR^^}"

    case $MODO in
        --criar)
            # Verificação e criação dos usuários
            if id "$LOGIN" &>/dev/null; then
                echo "⚠️  Usuário $LOGIN já existe."
            else
                # Cria usuário, adiciona ao grupo e define senha
                sudo useradd "$LOGIN" -c "$NOME" -s /bin/bash -m -p $(openssl passwd -6 "$SENHA_PADRAO") -G "$GRUPO"
                sudo passwd "$LOGIN" -e > /dev/null # Força troca de senha sem poluir o terminal
                echo "✅ Usuário $LOGIN criado e adicionado a $GRUPO."
            fi
            ;;

        --remover)
            # Verificação e remoção dos usuários
            if id "$LOGIN" &>/dev/null; then
                sudo userdel -r "$LOGIN"
                echo "✅ Usuário $LOGIN removido."
            else
                echo "⚠️  Usuário $LOGIN não encontrado."
            fi
            ;;

        --validar)
            # Validação de CRIAÇÃO de usuários
            if id "$LOGIN" &>/dev/null; then
                echo "✅ Usuário $LOGIN : OK"
            else
                echo "❌ Usuário $LOGIN : NÃO ENCONTRADO"
            fi
            ;;

        --validar-remocao)
            # Validação de REMOÇÃO de usuários
            if ! id "$LOGIN" &>/dev/null; then
                echo "✅ Usuário $LOGIN : REMOVIDO COM SUCESSO"
            else
                echo "❌ Usuário $LOGIN : AINDA EXISTE"
            fi
            ;;
    esac
done < "$ARQUIVO_USERS"

echo "================================================================="
echo "$MSG_FIM"
echo "================================================================="
echo ""