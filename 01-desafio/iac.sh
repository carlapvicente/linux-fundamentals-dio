#!/bin/bash
# Nome do arquivo de log fixo ou por data
LOG_GERAL="infraestrutura.log"

# Função para escrever no log com timestamp (data e hora)
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_GERAL"
}

# Função para validar o arquivo de usuários
validar_arquivo_usuarios() {
    local ARQUIVO="usuarios.txt"
    if [ ! -f "$ARQUIVO" ]; then
        echo "==========================================================================="
        echo "ERRO: Arquivo '$ARQUIVO' não localizado!"
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
            echo "ERRO: Você deve informar ao menos um nome de diretório!"
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
exec > >(tee -a "infra_it.log") 2>&1
echo "--------------------------------------------------"
echo " NOVA SESSÃO INICIADA EM: $(date '+%d/%m/%Y %H:%M:%S')"
echo "--------------------------------------------------"

# --- LOOP PRINCIPAL ---
while true; do
    echo "=========================================="
    echo "     GERENCIADOR DE INFRAESTRUTURA IT     "
    echo "=========================================="
    echo "1 - CRIAR TUDO (Pastas, Grupos e Usuários)"
    echo "2 - LIMPAR TUDO (Remover Usuários e Pastas)"
    echo "3 - SAIR"
    echo "=========================================="
    read -p "Escolha uma opção: " OPCAO

    case $OPCAO in
        1)
            # Verifica o arquivo antes de pedir as pastas
            if validar_arquivo_usuarios; then
                if solicitar_pastas; then
                    echo "===================="
                    echo "INICIANDO CRIAÇÃO..."
                    echo "===================="
                    echo ""
                    # Etapa 1 : Criando pastas e grupos de permissão
                    ./criar_pastas.sh $PASTAS > /dev/null
                    # Etapa 2: Criando usuários (usuarios.txt) e adicionando aos grupos
                    ./criar_usuarios.sh > /dev/null
                    echo ""
                    # Etapa 3: Validando a criação dos recursos
                    ./validar_iac.sh $PASTAS
                    echo ""
                    # Etapa 4: Validando a segurança das pastas (SGID e Sticky Bit)
                    # Coleta a lista de pastas informada - $PASTAS
                    # O sed remove a palavra 'publico' (se existir)
                    # O awk pega a primeira palavra que restou
                    PASTA_TESTE=$(echo $PASTAS | sed 's/\bpublico\b//g' | awk '{print $1}')
                    if [ -n "$PASTA_TESTE" ]; then
                        NOME_MAI="${PASTA_TESTE^^}"
                        ./validar_seguranca.sh "/$PASTA_TESTE" "GRP_$NOME_MAI"
                    else
                        echo "⚠️  Aviso: Sem pastas de setor para testar segurança (apenas 'publico' disponível)."
                    fi
                    echo ""
                    echo "================================"
                    echo "CRIAÇÃO FINALIZADA COM SUCESSO!!"
                    echo "================================"
                fi
            fi
            ;;
        2)
            # Para remover, talvez não precise do usuarios.txt existir,
            # pois o script de remoção pode apenas avisar se o usuário não existe.
            if solicitar_pastas; then
                echo "===================="
                echo "INICIANDO REMOÇÃO..."
                echo "===================="
                echo ""
                # Etapa 1: Removendo usuários (usuarios.txt)
                ./remover_usuarios.sh > /dev/null
                # Etapa 2 : Removendo pastas e grupos de permissão
                ./remover_pastas.sh $PASTAS > /dev/null
                echo ""
                # Etapa 3: Validando a remoção dos recursos
                ./validar_iac.sh --limpar $PASTAS
                echo ""
                echo "================================"
                echo "REMOÇÃO FINALIZADA COM SUCESSO!!"
                echo "================================"
            fi
            ;;
        3)
            echo "================================"
            echo "OPERAÇÃO CANCELADA..."
            echo "SAINDO..."
            echo "================================"
            exit 0
            ;;
        *)
            echo "================================"
            echo "OPERAÇÃO INVÁLIDA..."
            echo "POR FAVOR, SELECIONE ENTRE AS OPÇÕES DISPONÍVEIS NO MENU INICIAL..."
            echo "================================"
            sleep 1
            ;;
    esac

done