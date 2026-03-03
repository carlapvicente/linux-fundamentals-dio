#!/bin/bash

# --- VALIDAÇÃO DE SUPERUSUÁRIO ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ ERRO: Este script deve ser executado como root (use sudo)."
    exit 1
fi

# Validando os nomes dos diretórios
if [ $# -eq 0 ]; then
    echo "❌ ERRO: Por favor, informe o nome da(s) pasta(s) que deseja criar!!"
    echo "Exemplo de uso: $0 pasta1 pasta2 pasta3..."
    exit 1
fi


# Validação básica de argumentos
if [ $# -lt 2 ]; then
    echo "❌ ERRO: Argumentos insuficientes."
    echo "Uso: $0 [--criar|--remover|--validar|--validar-remocao] pasta1 pasta2..."
    exit 1
fi

MODO=$1
shift # Remove o primeiro argumento (o modo) para sobrar apenas as pastas
NUM_PASTAS=$#

# Definição de mensagens de cabeçalho e rodapé baseadas no modo
case $MODO in
    --criar)
        MSG_TITULO="⏳ Iniciando a criação de $NUM_PASTAS diretório(s) e grupo(s)..."
        MSG_FIM="✅ Criação de diretório(s) e grupo(s) finalizada com sucesso!!"
        ;;
    --remover)
        MSG_TITULO="⏳ Iniciando a remoção de $NUM_PASTAS diretórios e grupos..."
        MSG_FIM="✅ Remoção de diretórios e grupos finalizada com sucesso!!"
        ;;
    --validar)
        MSG_TITULO="⏳ Iniciando a validação de criação de $NUM_PASTAS diretórios e grupos..."
        MSG_FIM="✅ Validação de criação de diretórios e grupos finalizada com sucesso!!"
        ;;
    --validar-remocao)
        MSG_TITULO="⏳ Iniciando a validação de remoção de $NUM_PASTAS diretórios e grupos..."
        MSG_FIM="✅ Validação de remoção de diretórios e grupos finalizada com sucesso!!"
        ;;
    *)
        echo "❌ Opção inválida. Use: --criar, --remover, --validar ou --validar-remocao"
        exit 1
        ;;
esac

echo "================================================================="
echo "$MSG_TITULO"
echo "================================================================="
echo ""

# Loop para criar os diretórios
for PASTA in "$@"; do
    NOME_MIN="${PASTA,,}"
    NOME_MAI="${PASTA^^}"

    case $MODO in
        --criar)   
            # Verificação e criação dos diretórios
            if [ -d "/$NOME_MIN" ]; then
                echo "⚠️ Aviso: O diretório /$NOME_MIN já existe."
                echo "Pulando a etapa de criação do diretório /$NOME_MIN..."
            else
                sudo mkdir -p "/$NOME_MIN"
                echo "✅ Diretório /$NOME_MIN criado com sucesso!!"
            fi
            # Verificação e criação de grupos e aplicação de permissões
            if [ "$NOME_MIN" == "publico" ]; then
                # Ativa o Sticky Bit (1), o usuário só pode deletar o(s) próprio(s) arquivo(s).
                sudo chmod 1777 "/$NOME_MIN"
                echo "Aplicadas as permissões para a pasta pública /$NOME_MIN (1777 - Sticky Bit ativo)"
            else
                # Verificação e criação dos grupos
                if getent group "GRP_$NOME_MAI" > /dev/null; then
                    echo "⚠️ Aviso: O grupo GRP_$NOME_MAI já existe."
                    echo "Pulando a etapa de criação do grupo GRP_$NOME_MAI..."
                else
                    sudo groupadd "GRP_$NOME_MAI"
                    echo "✅ Grupo GRP_$NOME_MAI criado com sucesso!!"
                fi
                # Aplica dono e permissão
                sudo chown root:"GRP_$NOME_MAI" "/$NOME_MIN"
                # Ativa o Sticky Bit (1), o usuário só pode deletar o(s) próprio(s) arquivo(s).
                # Ativa o SGID (2), novos arquivos pertencem ao grupo dono da pasta.
                sudo chmod 3770 "/$NOME_MIN"
                echo "✅ Acesso restrito configurado com sucesso do grupo GRP_$NOME_MAI para o diretório /$NOME_MIN (3770 - SGID e Sticky Bit ativos)!!"
            fi
            ;;

        --remover) 
            # Verificação e remoção dos diretórios
            if [ -d "/$NOME_MIN" ]; then
                sudo rm -rf "/$NOME_MIN"
                echo "✅ Diretório /$NOME_MIN removido com sucesso!!"
            else
                echo "⚠️ Aviso: O diretório /$NOME_MIN não existe."
                echo "Pulando a etapa de remoção do diretório /$NOME_MIN..."
            fi
            # Verificação e remoção de grupos
            if [ "$NOME_MIN" != "publico" ]; then
                if getent group "GRP_$NOME_MAI" > /dev/null; then
                    sudo groupdel "GRP_$NOME_MAI"
                    echo "✅ Grupo GRP_$NOME_MAI removido com sucesso!!"
                else
                    echo "⚠️ Aviso: O grupo GRP_$NOME_MAI não existe."
                    echo "Pulando a etapa de remoção do grupo GRP_$NOME_MAI..."
                fi
            fi
            ;;

        --validar) 
            # Validação de CRIAÇÃO (Espera-se que exista)
            if [ -d "/$NOME_MIN" ]; then
                PERM=$(stat -c "%a" "/$NOME_MIN")
                echo "✅ /$NOME_MIN : OK (Perm: $PERM)"
            else
                echo "❌ /$NOME_MIN : NÃO ENCONTRADO"
            fi

            if [ "$NOME_MIN" != "publico" ]; then
                if getent group "GRP_$NOME_MAI" > /dev/null; then
                    echo "✅ GRP_$NOME_MAI : OK"
                else
                    echo "❌ GRP_$NOME_MAI : NÃO ENCONTRADO"
                fi
            fi
            ;;

        --validar-remocao)
            # Validação de REMOÇÃO (Espera-se que NÃO exista)
            if [ ! -d "/$NOME_MIN" ]; then
                echo "✅ /$NOME_MIN : REMOVIDO COM SUCESSO"
            else
                echo "❌ /$NOME_MIN : AINDA EXISTE (FALHA NA REMOÇÃO)"
            fi

            if [ "$NOME_MIN" != "publico" ]; then
                if ! getent group "GRP_$NOME_MAI" > /dev/null; then
                    echo "✅ GRP_$NOME_MAI : REMOVIDO COM SUCESSO"
                else
                    echo "❌ GRP_$NOME_MAI : AINDA EXISTE"
                fi
            fi
            ;;
    esac
done

echo "================================================================="
echo "$MSG_FIM"
echo "================================================================="
echo ""
