## Projetos relacionados

### Coruja Dev Environment

Responsável pelo ambiente de desenvolvimento:

- Docker
- PHP
- Apache
- MariaDB
- Redis
- Mailpit
- Traefik
- phpMyAdmin
- Dev Containers
- Xdebug
- Zsh
- CLI do ambiente

### Coruja Framework

Responsável pela arquitetura e pelos componentes das aplicações PHP.

Os dois projetos são independentes. É possível usar o ambiente sem utilizar o framework.

# Coruja Dev Environment

Ambiente compartilhado para vários projetos PHP usando Docker, Apache, PHP 8.3, MariaDB 11, phpMyAdmin, Composer, Dev Containers, Zsh e Xdebug.

## Estrutura recomendada no WSL

```text
/home/seu-usuario/www/
├── docker-environment/
└── projects/
    ├── projeto1/
    ├── coruja-rabiscada/
    └── outros-projetos/
```

## Instalação no WSL

Extraia este pacote dentro do WSL, preferencialmente em:

```bash
~/www/docker-environment
```

Crie a pasta dos projetos:

```bash
mkdir -p ~/www/projects
```

Entre no ambiente:

```bash
cd ~/www/docker-environment
```

Crie o `.env`:

```bash
cp .env.example .env
```

Descubra os valores do WSL:

```bash
echo $HOME
id -u
id -g
```

Edite `.env` e ajuste:

```env
PROJECTS_ROOT=/home/seu-usuario/www/projects
USER_UID=1000
USER_GID=1000
```

Mantenha os arquivos dentro de `/home/...`, e não em `/mnt/c`, para melhorar o desempenho do Docker, Composer e Git.

## Subir o ambiente

```bash
docker compose up -d --build
```

Confira:

```bash
docker compose ps
```

## Endereços

Aplicações:

```text
http://nome-do-projeto.localhost:8080
```

phpMyAdmin:

```text
http://localhost:8081
```

Credenciais iniciais:

```text
root / root
developer / developer
```

## Criar um projeto

```bash
chmod +x scripts/new-project
./scripts/new-project meu-projeto
```

Acesse:

```text
http://meu-projeto.localhost:8080
```

## Dev Container

Abra `docker-environment` no VS Code conectado ao WSL e execute:

```text
Dev Containers: Rebuild and Reopen in Container
```

## Xdebug

No VS Code, execute:

```text
Escutar Xdebug
```

Depois abra:

```text
http://meu-projeto.localhost:8080/?XDEBUG_TRIGGER=1
```
