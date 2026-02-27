# Gerenciador de Infraestrutura como Código (IaC) com Shell Script

Este projeto consiste em um conjunto de scripts Shell para automatizar a criação e o gerenciamento de uma infraestrutura básica de usuários, grupos e diretórios em um sistema Linux. Ele funciona como uma solução de "Infraestrutura como Código" (IaC), permitindo que a configuração do ambiente seja versionada e reproduzível.

## Índice

- [Estrutura do Projeto](#estrutura-do-projeto)
- [Como Usar](#como-usar)
  - [Pré-requisitos](#pré-requisitos)
  - [Passo a Passo](#passo-a-passo)
- [Detalhes Técnicos](#detalhes-técnicos)
  - [Permissões de Diretório](#permissões-de-diretório)
  - [Criação de Usuários](#criação-de-usuários)
  - [Logs de Execução](#logs-de-execução)
- [Aprendizados e FAQs Técnicos](#-aprendizados-e-faqs-técnicos)

---

## Estrutura do Projeto

O projeto é composto pelos seguintes arquivos:

-   `iac.sh`: Script principal que serve como menu interativo para o usuário. Orquestra a execução dos outros scripts.
-   `criar_pastas.sh`: Responsável por criar os diretórios na raiz (`/`) e os grupos de permissão correspondentes (`GRP_SETOR`).
-   `criar_usuarios.sh`: Lê o arquivo `usuarios.txt` para criar os usuários, adicioná-los aos grupos corretos e definir uma senha inicial com troca obrigatória no primeiro login.
-   `remover_pastas.sh`: Remove os diretórios e grupos criados.
-   `remover_usuarios.sh`: Remove os usuários listados no arquivo `usuarios.txt`.
-   `validar_iac.sh`: Verifica se os recursos (usuários, grupos, pastas) foram criados ou removidos corretamente.
-   `validar_seguranca.sh`: Realiza uma auditoria de segurança em um diretório específico para garantir que as permissões SGID e Sticky Bit estão funcionando como esperado.
-   `usuarios.txt`: (Arquivo a ser criado pelo usuário) Arquivo de entrada que contém a lista de usuários a serem criados.

---

## Como Usar

### Pré-requisitos

-   Um ambiente Linux (testado em distribuições baseadas em Debian/Ubuntu).
-   Acesso de superusuário (`sudo`).
-   O interpretador `bash`.

### Passo a Passo

1.  **Crie o arquivo `usuarios.txt`**

    Na mesma pasta dos scripts (`01-projeto/`), crie um arquivo chamado `usuarios.txt`. Cada linha deve seguir o formato `login:Nome Completo:setor`, sem espaços ao redor dos dois-pontos.

    **Exemplo de `usuarios.txt`:**
    ```
    carlos:Carlos Silva:adm
    maria:Maria Santos:ven
    joao:Joao Pereira:sec
    ```

2.  **Conceda Permissão de Execução**

    Navegue até o diretório `01-projeto` e torne todos os scripts executáveis:
    ```bash
    chmod +x *.sh
    ```

3.  **Execute o Script Principal**

    Execute o gerenciador com permissões de superusuário:
    ```bash
    sudo ./iac.sh
    ```

    Você verá um menu com as seguintes opções:

    ```
    ==========================================
         GERENCIADOR DE INFRAESTRUTURA IT
    ==========================================
    1 - CRIAR TUDO (Pastas, Grupos e Usuários)
    2 - LIMPAR TUDO (Remover Usuários e Pastas)
    3 - SAIR
    ==========================================
    ```

    -   **Opção 1:** Inicia o processo de criação. O script solicitará os nomes dos diretórios de setor que você deseja criar (ex: `adm ven sec publico`). Com base nisso e no arquivo `usuarios.txt`, ele criará toda a estrutura.
    -   **Opção 2:** Inicia o processo de remoção. Ele removerá os usuários listados em `usuarios.txt` e os diretórios/grupos que você especificar.
    -   **Opção 3:** Encerra o script.

> Caso seja digitado algo que não seja os números 1, 2 e 3, será exibida a seguinte mensagem:
>```
>================================
>OPERAÇÃO INVÁLIDA...
>POR FAVOR, SELECIONE ENTRE AS OPÇÕES DISPONÍVEIS NO MENU INICIAL...
>================================
>```

---

## Detalhes Técnicos

### Permissões de Diretório

-   **Diretórios de Setor (ex: `/adm`, `/ven`)**:
    -   **Dono/Grupo**: `root:GRP_SETOR`
    -   **Permissão**: `3770`
    -   **Efeito do SGID**: Novos arquivos/pastas criados dentro do diretório herdarão o grupo `GRP_SETOR`, facilitando a colaboração.
    -   **Efeito do Sticky Bit**: Apenas o dono do arquivo (ou o `root`) pode apagar ou renomear um arquivo dentro do diretório, mesmo que outros membros do grupo tenham permissão de escrita na pasta.

**Explicação do valor de permissão octal `3770`**:

| Octal | Significado | Permissão Visual (ls -l) |
| ----- | ----------- | ---------------- |
| 3 | SGID (2) + Sticky Bit (1) | `rwxrws--t` |
| 7 | Dono (root) | `rwx` |
| 7 | Grupo (GRP_SETOR) | `rws` (x + SGID) |
| 0 | Outros | `---` |

-   **Diretório `/publico`**:
    -   **Permissão**: `1777` (`rwxrwxrwt`). O `t` final indica o Sticky Bit.
    -   **Efeito**: Qualquer usuário pode criar arquivos, mas só pode apagar os arquivos que ele mesmo criou.

### Criação de Usuários

-   A senha padrão para todos os usuários criados é `Senha123`.
    > **⚠️ AVISO DE SEGURANÇA**: A senha `Senha123` é utilizada apenas para fins educacionais. Em um ambiente de produção real, altere esta lógica para utilizar senhas fortes, chaves SSH ou integração com diretórios (LDAP/AD).
-   É configurada a **troca obrigatória de senha** no primeiro login para garantir a segurança.
-   Cada usuário é automaticamente adicionado ao grupo correspondente ao seu setor (ex: `carlos` é adicionado ao `GRP_ADM`).

### Logs de Execução

O script `iac.sh` gera automaticamente um log detalhado de todas as operações realizadas.
-   **Arquivo**: `infra_it.log`
-   **Conteúdo**: O arquivo captura toda a saída do terminal (stdout) e mensagens de erro (stderr). Isso permite auditar o que foi criado ou removido e identificar falhas sem precisar rolar o terminal.

> O script utiliza emojis para facilitar a leitura rápida dos logs e o monitoramento em tempo real via terminal:
> -  ✅: Sucesso 
> -  ❌:  Erro
> -  ⚠️:  Aviso
> -  👋: Saída do menu inicial
---

## Monitoramento em Tempo Real com `tail`

Enquanto o script `iac.sh` é executado, podemos monitorar o log gerado em tempo real em outro terminal. Isso é extremamente util para diagnosticar problemas durante a criação ou remoção de recursos.

### Como utilizar

1. Abra um terminal separado.
2. Navegue até a pasta do projeto ou a pasta onde estão os scripts/logs
3. Execute o comando:
    ```bash
    tail -f infra_it.log
    ```
4. Para finalizar o monitiramento tecle `Ctrl + C`.

### O que isso faz?

- O parâmetro `-f` (de _follow_ ou "seguir") mantém o arquivo aberto.
- Sempre que o script `iac.sh` escrever uma nova linha de log no `infra_it.log`, o comando `tail` exibirá essa linha instantaneamente no seu terminal de monitoramento.

### Por que isso é útil?

- **Auditoria Visual**: Podemos ver exatamente o momento em que cada grupo, pasta ou usuário é criado ou removido.
- **Depuração (Debug)**: Se o script travar ou der erro em algum passo, poderemos ver a mensagem de erro aparecer no terminal de monitoramento no exato milissegundo em que ocorrer.
- **Ambiente de Produção**: Esse método é utilizado por administradores de sistemas para observar o comportamento de servidores e aplicações em execução.

### Dica: Filtrando logs

Se o arquivo de log ficar muito grande, podemos apenas monitorar as linhas de erro (identificadas pelo prefixo de erro `❌` ou pela ausência do prefixo `✅`) ou monitorar as linhas de sucesso (identificadas pelo prefixo de sucesso `✅`). Para realizar esses filtros podemos combinar os comandos `tail`com `grep` da seguinte forma:

```bash
tail -f infra_it.log | grep -v '^✅'
``` 

```bash
tail -f infra_it.log | grep -v '^❌'
```

```bash
tail -f infra_it.log | grep "❌"
```

> Isso fará com que o terminal fique em "silêncio" até que a condição informada no `grep` seja satisfeita.

| Comando | O que vemos no terminal? |
| ------- | ------------------------ |
| grep -v '^✅' | **Tudo**, menos os sucessos. |
| grep -v '^❌' | **Tudo**, menos os erros. |
| grep "❌" | **Apenas** os erros. |

---

## 💡 Aprendizados e FAQs Técnicos

Durante o desenvolvimento deste projeto, alguns conceitos de Bash foram fundamentais. Abaixo, explico as dúvidas mais comuns que surgiram:

### Por que usar `&>/dev/null` em vez de apenas `>/dev/null`?
- `>/dev/null`: Silencia apenas as mensagens de sucesso (Standard Output). Erros ainda aparecem na tela.
- `&>/dev/null`: Silencia **tudo** (Sucesso e Erros). É útil em scripts de limpeza (como `userdel`), onde erros como "usuário não encontrado" são esperados e não devem poluir a tela.

### O que faz a linha `exec > >(tee -a "infra_it.log") 2>&1`?
Esta é uma técnica avançada de redirecionamento. Ela permite que o script continue mostrando as mensagens no terminal (através do `tee`) enquanto salva uma cópia idêntica em um arquivo de log, capturando tanto sucessos quanto erros.

> O comando `tee` é como um "T" de encanamento, ele joga a saída para a tela e para um arquivo de log ao mesmo tempo.

### Como o script identifica a pasta pública para aplicar permissões diferentes?
Utilizamos uma combinação de `sed` e `awk` no script principal para filtrar a lista de pastas. O script de segurança ignora a pasta `publico` para focar o teste de SGID em pastas de setor, onde a herança de grupo é mandatória.

### Como funciona o comando `if [ "$EUID" -ne 0 ]; then`?
- O `$EUID`variável do sistema que guarda o ID do usuário atual, o `root` é sempre `0`.
- Se quem está executando o script não for o `root`, será exibida uma mensagem amigável, antes mesmo de tentar abrir o log com o `tee`:
    ```
    ===============================================================
    ❌ ERRO: Este script deve ser executado como root (use sudo).
    Exemplo: sudo ./iac.sh
    ===============================================================
    ```
- Sem esse bloco de código no começo do script `iac.sh` será exibida uma mensagem fora do padrão e o menu será exibido:
    ```
    tee: infra_it.log: Permission denied
    --------------------------------------------------
     NOVA SESSÃO INICIADA EM: 27/02/2026 16:51:25
    --------------------------------------------------
    ==========================================
         GERENCIADOR DE INFRAESTRUTURA IT
    ==========================================
    1 - CRIAR TUDO (Pastas, Grupos e Usuários)
    2 - LIMPAR TUDO (Remover Usuários e Pastas)
    3 - SAIR
    ==========================================
    Escolha uma opção: 
    ```

### Como funciona o comando `grep -v '^❌'`?
- O `grep` funciona como um filtro de café ondo você decide o que fica retido e o que passa por esse filtro.
- O `grep` possui "flags" como o `-v`, que podem mudar completamente o que estamos filtrando.
  - O `-v` (invert) diz para o `grep` o seguinte: mostre tudo, **exceto** o que eu te pedir.
  - O `^` indica que o que estamos filtrando está no início da linha.
  - Exemplo 1: 
    - **Comando**: `tail -f infra_it.log | grep -v '^✅'`
    - **Resultado**: Mostra todos os erros '❌', todos os avisos `⚠️` e todas as mensagens de menu, mas **esconde** todas as linhas que sucesso que começam com '✅'.
    - **Utilidade**: Serve para "limpar" mensagens repetitivas de sucesso e mantem apenas os erros, avisos ou mensagens de estrutura do script. O `^` faz com que o filtro seja feito logo no início da linha, otimizando a busca.
  - Exemplo 2: 
    - **Comando**: `tail -f infra_it.log | grep "❌"`
    - **Resultado**: Mostra somente as inhas que contém o emoji de erro'❌', ou seja, o terminal ficará em "silêncio" até que um erro ocorra.
    - **Utilidade**: Mostra apenas as linhas que tiverem mensagens como "❌ Usuário não encontrado".

### Por que o terminal pareceu "lento" ou "travado" ao usar Logs no WSL?
Ao utilizar o **WSL (Windows Subsystem for Linux)**, pode notar uma pequena lentidão ou atraso (lag) na resposta do menu ao ativar o redirecionamento global de logs (`exec > >(tee -a "infra_it.log") 2>&1`).
- **Causa**: Isso ocorre devido à latência de sincronização entre o sistema de arquivos do **Linux** e o do **Windows**. O comando `tee` tenta escrever no arquivo e na tela simultaneamente, e o **WSL2** pode criar um gargalo (bottleneck) nesse fluxo de dados (pipes), especialmente se houver um processo como o `tail -f` monitorando o arquivo ao mesmo tempo.
- **Solução**: Para uma experiência mais fluida no **WSL**, recomenda-se:
  - Utilizar o Windows Terminal (disponível na Microsoft Store) em vez do CMD/PowerShell antigo.
  - Redirecionar para o log apenas as etapas de processamento pesado, em vez de capturar todo o menu interativo.
  - Utilizar o comando cat infra_it.log ao final da execução para conferir o resultado, em vez de monitorar "ao vivo" durante o menu.

No meu caso a lentidão passou a ocorrer quando mudei o nome do computador no terminal para "servidor1" utilizando o comando `sudo hostnamectl set-hostname servidor1`. Como o bash é muito sensível à resolução de nomes, após alterar o hostname devemos ajustar a tabela de endereços locais em `/etc/hosts`.
- Por que ficou lento?
  - Toda vez que executamos o `sudo` ou que o bash precisa renderizar o prompt, o sistema tenta descobrir quem é o servidor1.
    - Ele procura no arquivo de configurações.
    - Ele tenta resolver o nome via DNS interno.
    - Ele fica esperando um "timeout" (tempo limite) até desistir, porque ele não encontra o `servidor1` apontando para o próprio endereço de IP (`127.0.0.1`).
  - Isso faz parecer que o terminal ficou "lento" ou "travado".
-  Como resolver isso?
  - Precisamos dizer ao Linux que o `servidor1` é ele mesmo.
    - Abra o arquivo `hosts`:
        ```bash
        sudo nano /etc/hosts
        ```
    - Veremos algo como:
        ```
        127.0.0.1   localhost
        127.0.1.1   Nome-Antigo-Do-Seu-Note
        ```
    - Adicione o novo nome ao lado do localhost ou substitua o antigo:
        ```
        127.0.0.1   localhost servidor1
        127.0.1.1   servidor1
        ```
    - Salve (`Ctrl+O`, `Enter`) e saia (`Ctrl+X`).
- Como testar?
  - Após as alterações no arquivo `hosts`, tente rodar um comando simples com o `sudo`, se responder instantaneamente, o problema foi resolvido.
  - Exemplo de comando:
        ```bash
        sudo ls
        ```

> **Importante**: Fiz essa configuração de trocar o nome do computador para `servidor1` para facilitar a coleta de prints e possíveis gravações de tela, caso não vá realizar essas atividades de forma constante, não precisa realizar a troca do nome do computador no terminal.