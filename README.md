# Coruja Dev Environment

> Ambiente de desenvolvimento moderno para PHP baseado em Docker, criado
> para substituir o Laragon e oferecer uma plataforma única para
> desenvolvimento no macOS, WSL e Linux.

## Status

**Versão:** `v0.1.0`

Primeira versão funcional contendo:

-   Docker + Docker Compose
-   Traefik com URLs `*.localhost`
-   PHP 8.3 + Apache
-   MariaDB 11
-   phpMyAdmin
-   Mailpit
-   Dev Containers
-   Xdebug
-   Composer
-   CLI `coruja`
-   Criação e remoção de projetos
-   Banco de dados automático
-   Documentação inicial
-   Troubleshooting

## Projetos relacionados

-   **Coruja Dev Environment**: infraestrutura de desenvolvimento.
-   **Coruja Framework**: framework PHP independente que utiliza este
    ambiente.

## Estrutura

``` text
/home/<usuario>/www/
├── coruja-dev-environment/
├── projects/
├── data/
│   └── mariadb/
├── backups/
└── templates/
```

## Instalação

``` bash
git clone <repositorio>
cd coruja-dev-environment
cp .env.example .env
coruja up
coruja doctor
```

## URLs

  Serviço      URL
  ------------ ----------------------------------
  Projetos     http://nome-do-projeto.localhost
  phpMyAdmin   http://phpmyadmin.localhost
  Mailpit      http://mail.localhost
  Traefik      http://localhost:8082/dashboard/

## CLI

### Ambiente

``` text
coruja up
coruja down
coruja restart
coruja build
coruja status
coruja logs
coruja shell
coruja doctor
coruja version
coruja help
```

### Projetos

``` text
coruja new <nome>
coruja projects
coruja project remove <nome>
```

### Banco

``` text
coruja db list
```

## Roadmap v0.2.0

-   Auditoria completa
-   Correção definitiva de permissões
-   Install automatizado
-   Importação de projetos do Laragon
-   Backup e Restore
-   Doctor 2.0
-   Configuração interativa
-   Validação em macOS, WSL e Linux
