# Linux Fundamentals - DIO

![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![WSL](https://img.shields.io/badge/WSL-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![License](https://img.shields.io/github/license/carlapvicente/linux-fundamentals-dio?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/carlapvicente/linux-fundamentals-dio?style=for-the-badge)

<br>

Este repositório é destinado à publicação dos scripts e soluções desenvolvidos para os desafios do curso **"Linux Fundamentals"** da **Digital Innovation One (DIO)**.

O objetivo é documentar a evolução do aprendizado em administração de sistemas Linux, focando em automação, gerenciamento de usuários e permissões.

---

# 🛠️ Ferramentas Utilizadas
- Sistema Operacional: Ubuntu (via WSL2)
- Linguagem: Shell Script (Bash)
- Gravação de Demonstração: [ScreenToGif](https://www.screentogif.com/)

---

# Estrutura do Repositório

## [Infraestrutura como Código (IaC): Script de Criação de Estrutura de Usuários, Diretórios e Permissões](./01-desafio)
Contém a solução para o desafio de **Infraestrutura como Código (IaC): Script de Criação de Estrutura de Usuários, Diretórios e Permissões**.
- Automação de criação de usuários, grupos e diretórios.
- Gerenciamento de permissões e segurança.
- Scripts de validação e auditoria.

### Demonstração em Tempo Real

> Demonstração foi gravada com ScreenToGif.

- Falha ao executar o script `iac.sh` com um usuários sem ser o `root` e sem utilizar o comando `sudo`:
    ![Execução do Gerenciador de Infraestrutura](./assets/01-desafio/demo_01.gif)

- Falha ao tentar criar os usuários sem ter o arquivo `usuarios.txt`:
    ![Execução do Gerenciador de Infraestrutura](./assets/01-desafio/demo_02.gif)

- Criação de diretórios, grupos de permissão e usuários:
    ![Execução do Gerenciador de Infraestrutura](./assets/01-desafio/demo_03.gif)

- Remoção de diretórios, grupos de permissão e usuários:
    ![Execução do Gerenciador de Infraestrutura](./assets/01-desafio/demo_04.gif)

---

# 🤝 Contribuindo

Este repositório tem como foco o estudo e a prática de administração de sistemas Linux.

- **Melhorias:** Encontrou um bug, otimizou um script ou tem uma nova ideia? Sinta-se à vontade para abrir um Pull Request. Sua contribuição ajuda a comunidade a evoluir.

Juntos construímos uma comunidade de aprendizado prático e acessível. 🚀

---
*Projeto desenvolvido para fins educacionais.*