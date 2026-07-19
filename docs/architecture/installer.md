# Arquitetura do Instalador

## Objetivo

O instalador (`install.sh`) é responsável por preparar o ambiente para utilização
do Coruja Dev Environment.

Seu objetivo **não é substituir a CLI**, mas sim automatizar a configuração
inicial do ambiente e delegar as demais operações para a ferramenta `coruja`.

---

# Filosofia

O instalador deve ser executado apenas durante:

- primeira instalação;
- migração para uma nova máquina;
- reinstalação do ambiente.

Após a instalação, toda operação cotidiana deve ser realizada através da CLI.

Exemplos:

```bash
coruja doctor

coruja up

coruja down

coruja new projeto

coruja remove projeto
```

O instalador não deve duplicar funcionalidades já existentes na CLI.

---

# Fluxo geral

```text
Usuário

    │

    ▼

install.sh

    │

    ▼

prepare_installation()

    │

    ├── detectar sistema operacional

    ├── validar dependências

    ├── preparar diretórios

    ├── gerar .env

    └── validar configuração

    │

    ▼

execute_installation()

    │

    ├── instalar CLI

    ├── iniciar ambiente (futuro)

    ├── executar doctor (futuro)

    └── criar primeiro projeto (futuro)

    │

    ▼

finish_installation()

    │

    ├── resumo

    ├── URLs

    └── próximos passos
```

---

# Relação entre Installer e CLI

```text
                  Coruja Dev Environment

                         │

         ┌───────────────┴────────────────┐

         │                                │

         ▼                                ▼

    Installer                        CLI Coruja

         │                                │

         ▼                                ▼

Preparação inicial            Operação diária

         │                                │

         └───────────────┬────────────────┘

                         ▼

                    Docker

                         ▼

                 Containers

                         ▼

                   Projetos
```

A CLI é a responsável pelas operações do ambiente.

O instalador apenas prepara o ambiente e garante que a CLI esteja disponível.

---

# Responsabilidades

## Installer

Responsável por:

- detectar sistema operacional;
- validar dependências;
- preparar diretórios;
- gerar arquivos de configuração;
- instalar a CLI;
- executar validações iniciais.

Não deve:

- administrar projetos;
- controlar containers continuamente;
- executar tarefas repetitivas de manutenção.

---

## CLI

Responsável por:

- gerenciamento dos containers;
- criação de projetos;
- remoção de projetos;
- backup;
- restore;
- diagnóstico;
- manutenção do ambiente.

---

# Estrutura

```text
installer/

core/

checks/

setup/

actions/

finalize/
```

## core

Infraestrutura compartilhada.

## checks

Validações.

## setup

Preparação do ambiente.

## actions

Execução de ações.

## finalize

Resumo da instalação.

---

# Princípios

O instalador segue os seguintes princípios:

- responsabilidade única;
- modularização;
- reutilização da CLI;
- idempotência;
- compatibilidade entre macOS, WSL e Linux;
- facilidade de manutenção;
- documentação contínua.

---

# Evolução

Versão 0.2

- instalação automatizada;
- geração do `.env`;
- instalação da CLI;
- validação do ambiente.

Versões futuras

- instalação interativa;
- atualização automática;
- rollback;
- instalação silenciosa;
- suporte a plugins.