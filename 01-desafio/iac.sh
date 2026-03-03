#!/bin/bash
# --- VALIDAÇÃO DE SUPERUSUÁRIO ---
if [ "$EUID" -ne 0 ]; then
    echo "==============================================================="
    echo "❌ ERRO: Este script deve ser executado como root (use sudo)."
    echo "Exemplo: sudo ./iac.sh"
    echo "==============================================================="
    exit 1
fi

# Carregando configurações
if [ -f "./config.conf" ]; then
    source "./config.conf"
else
    echo "❌ ERRO: Arquivo de configuração 'config.conf' não encontrado."
    exit 1
fi

# Função para escrever no log com timestamp (data e hora)
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Função para validar o arquivo de usuários
validar_arquivo_usuarios() {
    local ARQUIVO="usuarios.txt"
    if [ ! -f "$ARQUIVO" ]; then
        echo "==========================================================================="
        echo "❌ ERRO: Arquivo '$ARQUIVO' não localizado!"
        echo "Para prosseguir, crie um arquivo com o nome '$ARQUIVO' no seguinte formato:"
        echo "login:Nome Completo:setor"
        echo "Exemplo:"
        echo "carlos:Carlos Silva:adm"
        echo "==========================================================================="
        return 1 # Retorna erro
    fi
    return 0 # Retorna sucesso
}

# Função para solicitar os nomes das pastas com validação
solicitar_pastas() {
    while true; do
        echo "============================================================"
        echo "Informe os nomes das pastas de setor (separados por espaço)."
        echo "Exemplo: adm ven sec"
        read -p "Informe o(s) nome(s) dos diretórios: " PASTAS_INPUT

        if [ -z "$PASTAS_INPUT" ]; then
            echo "❌ ERRO: Você deve informar ao menos um nome de diretório!"
            sleep 1
        elif [ "$PASTAS_INPUT" == "voltar" ]; then
            echo "Operação cancelada pelo usuário..."
            return 1 # Sair da função
        else
            PASTAS="$PASTAS_INPUT"
            return 0 # Sai do loop se houver entrada
        fi
        echo "============================================================"
    done
}

# Geração de log para cada execução do script
exec > >(tee -a "$LOG_FILE") 2>&1
echo "--------------------------------------------------"
echo " NOVA SESSÃO INICIADA EM: $(date '+%d/%m/%Y %H:%M:%S')"
echo "--------------------------------------------------"

# --- LOOP PRINCIPAL ---
while true; do
    echo "=========================================="
    echo "     GERENCIADOR DE INFRAESTRUTURA IT     "
    echo "=========================================="
    echo "1 - Criar diretório(s) e grupo(s)"
    echo "2 - Criar usuário(s)"
    echo "3 - Remover diretório(s) e grupo(s)"
    echo "4 - Remover usuário(s)"
    echo "5 - Sair do sistema"
    echo "=========================================="
    read -p "Escolha uma opção: " OPCAO

    case $OPCAO in
        1) 
            # Realiza a criação dos diretórios e grupos de permissão
            if solicitar_pastas; then
                echo "============================================"
                echo "⏳ Provisionando estrutura de diretórios..."
                echo "============================================"
                echo ""
                # Etapa 1: Criando pastas e grupos
                ./gerenciar_pastas.sh --criar $PASTAS >> "$LOG_FILE" 2>&1
                echo ""
                # Etapa 2: Validando
                echo "--- [ RELATÓRIO DE VALIDAÇÃO ] ---"
                ./gerenciar_pastas.sh --validar $PASTAS >> "$LOG_FILE" 2>&1
                echo ""
                # Etapa 3: Validando a segurança das pastas (SGID e Sticky Bit)
                # Coleta a lista de pastas informada - $PASTAS
                # O sed remove a palavra 'publico' (se existir)
                # O awk pega a primeira palavra que restou
                PASTA_TESTE=$(echo $PASTAS | sed 's/\bpublico\b//g' | awk '{print $1}')
                if [ -n "$PASTA_TESTE" ]; then
                    NOME_MAI="${PASTA_TESTE^^}"
                    ./validar_seguranca.sh "/$PASTA_TESTE" "GRP_$NOME_MAI" >> "$LOG_FILE" 2>&1
                else
                    echo "⚠️ Aviso: Sem pastas de setor para testar segurança (apenas 'publico' disponível)."
                fi
                echo ""
                echo "================================================================="
                echo "✅ Operação concluída. Detalhes técnicos salvos em: infra_it.log"
                echo "================================================================="
            fi
            ;;
        2)
            # Verifica o arquivo antes de pedir as pastas
            if validar_arquivo_usuarios; then
                echo "============================================"            
                echo "✅ Arquivo de usuários validado com sucesso."
                echo ""
                echo "⏳ Provisionando usuários..."
                echo "============================================"
                echo ""
                # Etapa 1: Criando usuários
                ./gerenciar_usuarios.sh --criar >> "$LOG_FILE" 2>&1
                echo ""
                # Etapa 2: Validando
                echo "--- [ RELATÓRIO DE VALIDAÇÃO ] ---"
                ./gerenciar_usuarios.sh --validar >> "$LOG_FILE" 2>&1
                echo ""
                echo "================================================================="
                echo "✅ Operação concluída. Detalhes técnicos salvos em: infra_it.log"
                echo "================================================================="
            fi
            ;;
        3)
            # Remover Diretórios e Grupos
            if solicitar_pastas; then
                echo "===================================="
                echo "⏳ Removendo diretórios e grupos..."
                echo "===================================="
                ./gerenciar_pastas.sh --remover $PASTAS >> "$LOG_FILE" 2>&1
                echo ""
                echo "--- [ VALIDAÇÃO DA REMOÇÃO ] ---"
                ./gerenciar_pastas.sh --validar-remocao $PASTAS >> "$LOG_FILE" 2>&1
                echo ""
                echo "================================================================="
                echo "✅ Operação concluída. Detalhes técnicos salvos em: infra_it.log"
                echo "================================================================="
            fi
            ;;
        4)
            # Remover Usuários
            # Verifica o arquivo antes de pedir as pastas
            if validar_arquivo_usuarios; then
                echo "===================================="
                echo "⏳ Removendo usuários..."
                echo "===================================="
                ./gerenciar_usuarios.sh --remover >> "$LOG_FILE" 2>&1
                echo ""
                echo "--- [ VALIDAÇÃO DA REMOÇÃO ] ---"
                ./gerenciar_usuarios.sh --validar-remocao >> "$LOG_FILE" 2>&1
                echo ""
                echo "================================================================="
                echo "✅ Operação concluída. Detalhes técnicos salvos em: infra_it.log"
                echo "================================================================="
            fi
            ;;
        5)
            echo "================================"
            echo "👋 OPERAÇÃO FINALIZADA..."
            echo "SAINDO DO SISTEMA..."
            echo "================================"
            exit 0
            ;;
        *)
            echo "================================"
            echo "❌ OPERAÇÃO INVÁLIDA..."
            echo "POR FAVOR, SELECIONE ENTRE AS OPÇÕES DISPONÍVEIS NO MENU INICIAL..."
            echo "================================"
            sleep 1
            ;;
    esac

done