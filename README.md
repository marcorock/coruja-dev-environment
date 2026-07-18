# Coruja Dev Environment

> Ambiente local de desenvolvimento para projetos PHP, baseado em Docker,
> com suporte a WSL, Linux e macOS.

O Coruja Dev Environment foi criado para oferecer uma experiência semelhante
ao Laragon, com isolamento por containers, URLs automáticas, serviços
integrados e ferramentas próprias de linha de comando.

## Status

**Versão atual:** `v0.1.0`

Esta versão inclui:

- Docker Compose
- Traefik
- PHP 8.3.32
- Apache
- MariaDB 11.8.8
- Redis 8.8
- phpMyAdmin
- Mailpit
- Composer
- Xdebug
- Zsh
- Dev Containers
- CLI `coruja`
- criação, clonagem e remoção de projetos
- criação, backup e restauração de bancos
- diagnóstico do ambiente

## Projetos relacionados

### Coruja Dev Environment

Responsável pelo ambiente local, serviços, containers e ferramentas de
desenvolvimento.

### Coruja Framework

Responsável pela arquitetura e pelos componentes das aplicações PHP.

Os projetos são independentes. O Coruja Dev Environment pode executar
projetos PHP que não utilizam o Coruja Framework.

## Estrutura recomendada

### WSL e Linux

```text
/home/<usuario>/www/
├── coruja-dev-environment/
├── projects/
├── data/
│   ├── mariadb/
│   └── redis/
├── backups/
└── templates/
```

### macOS

```text
/Users/<usuario>/www/
├── coruja-dev-environment/
├── projects/
├── data/
│   ├── mariadb/
│   └── redis/
├── backups/
└── templates/
```

## Pré-requisitos

- Docker Desktop ou Docker Engine
- Docker Compose
- Git
- Bash
- portas 80, 3306 e 8082 disponíveis

## Instalação

Clone o repositório:

```bash
mkdir -p ~/www
cd ~/www

git clone git@github.com:marcorock/coruja-dev-environment.git
cd coruja-dev-environment
```

Crie a configuração local:

```bash
cp .env.example .env
```

Edite o `.env` e ajuste os caminhos para o seu usuário.

### Exemplo no WSL ou Linux

```env
CORUJA_HOME=/home/seu-usuario/www
PROJECTS_ROOT=/home/seu-usuario/www/projects
DB_DATA_PATH=/home/seu-usuario/www/data/mariadb
REDIS_DATA_PATH=/home/seu-usuario/www/data/redis
BACKUPS_PATH=/home/seu-usuario/www/backups
TEMPLATES_PATH=/home/seu-usuario/www/templates
```

### Exemplo no macOS

```env
CORUJA_HOME=/Users/seu-usuario/www
PROJECTS_ROOT=/Users/seu-usuario/www/projects
DB_DATA_PATH=/Users/seu-usuario/www/data/mariadb
REDIS_DATA_PATH=/Users/seu-usuario/www/data/redis
BACKUPS_PATH=/Users/seu-usuario/www/backups
TEMPLATES_PATH=/Users/seu-usuario/www/templates
```

Crie os diretórios:

```bash
mkdir -p \
    ~/www/projects \
    ~/www/data/mariadb \
    ~/www/data/redis \
    ~/www/backups \
    ~/www/templates
```

## Instalar a CLI

Dê permissão de execução:

```bash
chmod +x coruja scripts/new-project
```

Crie o link simbólico:

### WSL ou Linux

```bash
sudo ln -sf "$(pwd)/coruja" /usr/local/bin/coruja
```

### macOS

```bash
sudo ln -sf "$(pwd)/coruja" /usr/local/bin/coruja
```

Teste:

```bash
coruja version
```

Resultado esperado:

```text
Coruja Dev Environment 0.1.0
```

## Iniciar o ambiente

```bash
coruja up
```

Ou, diretamente pelo Docker Compose:

```bash
docker compose up -d
```

Verifique:

```bash
coruja status
coruja doctor
```

## URLs

| Serviço | Endereço |
|---|---|
| Projetos | `http://nome-do-projeto.localhost` |
| phpMyAdmin | `http://db.localhost` |
| Mailpit | `http://mail.localhost` |
| Traefik Dashboard | `http://localhost:8082/dashboard/` |

## Serviços internos

| Serviço | Host interno | Porta |
|---|---|---:|
| MariaDB | `database` | `3306` |
| Redis | `redis` | `6379` |
| Mailpit SMTP | `mail` | `1025` |
| Mailpit Web | `mail` | `8025` |

## CLI Coruja

### Ambiente

```text
coruja up
coruja down
coruja restart
coruja build
coruja status
coruja logs
coruja logs <serviço>
coruja shell
```

### Projetos

```text
coruja new <nome>
coruja projects
coruja project list
coruja project info <nome>
coruja project clone <origem> <destino>
coruja project remove <nome>
```

### Banco de dados

```text
coruja db list
coruja db create <nome>
coruja db drop <nome>
coruja db backup <banco>
coruja db restore <arquivo> [banco]
coruja db shell
```

### Serviços

```text
coruja service status
coruja service restart <nome>
coruja service logs <nome>
```

### Redis

```text
coruja redis ping
coruja redis shell
coruja redis info
coruja redis flush
```

### Sistema

```text
coruja doctor
coruja version
coruja help
```

## Criar um projeto

```bash
coruja new meu-projeto
```

O comando:

1. cria a estrutura do projeto;
2. gera o arquivo `.env`;
3. cria o banco de dados;
4. instala as dependências do Composer;
5. disponibiliza a aplicação no Traefik.

Acesse:

```text
http://meu-projeto.localhost
```

## Clonar um projeto

```bash
coruja project clone projeto-base novo-projeto
```

O comando:

- copia os arquivos;
- remove `.git` e `vendor`;
- atualiza o `.env`;
- cria um novo banco;
- instala as dependências.

## Remover um projeto

```bash
coruja project remove meu-projeto
```

A remoção utiliza uma pasta temporária de segurança. Caso a exclusão do banco
falhe, os arquivos do projeto são restaurados.

## Backup e restauração

Criar backup:

```bash
coruja db backup meu_banco
```

Restaurar:

```bash
coruja db restore backups/meu_banco.sql
```

Restaurar em outro banco:

```bash
coruja db restore backups/meu_banco.sql banco_destino
```

## Dev Container

Abra o diretório do ambiente no VS Code e execute:

```text
Dev Containers: Rebuild and Reopen in Container
```

O container utiliza o usuário `developer`, Zsh, PHP, Composer e as extensões
recomendadas para desenvolvimento PHP.

## Xdebug

No VS Code, ative:

```text
Listen for Xdebug
```

Depois acesse:

```text
http://meu-projeto.localhost/?XDEBUG_TRIGGER=1
```

## Diagnóstico

```bash
coruja doctor
```

O comando verifica:

- diretórios;
- permissões;
- Docker;
- Docker Compose;
- MariaDB;
- Redis;
- Mailpit;
- Traefik;
- Docker Socket;
- arquivos de configuração.

## Roadmap v0.2.0

- instalador automatizado;
- importação de projetos do Laragon;
- diagnóstico HTTP completo;
- configuração interativa;
- testes automatizados da CLI;
- validação completa em macOS;
- validação completa em Linux;
- documentação de migração;
- templates de projeto.