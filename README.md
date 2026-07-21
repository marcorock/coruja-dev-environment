# Coruja Dev Environment

> Ambiente local de desenvolvimento para projetos PHP, baseado em Docker,
> com suporte a WSL, Linux e macOS.

O Coruja Dev Environment foi criado para oferecer uma experiência semelhante
ao Laragon, com isolamento por containers, URLs automáticas, serviços
integrados e ferramentas próprias de linha de comando.

## Status

**Versão em desenvolvimento:** `v0.2.0`

A versão `v0.2.0` está sendo preparada na branch de desenvolvimento e inclui:

- Docker Compose;
- Traefik com HTTPS local;
- certificados locais com `mkcert`;
- PHP 8.3 com Apache;
- MariaDB 11;
- Redis;
- phpMyAdmin;
- Mailpit;
- Composer;
- Node.js 24;
- npm e npx;
- Corepack;
- pnpm;
- Yarn;
- Xdebug;
- Zsh;
- Dev Containers;
- instalador automatizado;
- CLI `coruja`;
- criação de projetos por templates;
- criação, clonagem e remoção de projetos;
- criação, backup e restauração de bancos;
- diagnóstico modular do ambiente;
- testes automatizados da CLI.

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

- Docker Desktop ou Docker Engine;
- Docker Compose;
- Git;
- Bash;
- portas `80`, `443`, `3306` e `8082` disponíveis.

O instalador também utiliza o `mkcert` para gerar certificados HTTPS locais.
Quando necessário, ele orienta ou realiza a instalação da ferramenta.

## Instalação

Clone o repositório:

```bash
mkdir -p ~/www
cd ~/www

git clone git@github.com:marcorock/coruja-dev-environment.git
cd coruja-dev-environment
```

Execute o instalador:

```bash
chmod +x install.sh
./install.sh
```

O instalador:

1. identifica WSL, Linux ou macOS;
2. verifica as dependências;
3. cria os diretórios do ambiente;
4. gera o arquivo `.env`;
5. configura UID e GID;
6. gera os certificados HTTPS;
7. instala a autoridade certificadora local;
8. valida a configuração;
9. instala a CLI `coruja`;
10. oferece a opção de iniciar o ambiente.

A configuração gerada utiliza uma estrutura semelhante a:

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

Depois da instalação, valide a CLI:

```bash
coruja version
```

Para consultar as opções disponíveis:

```bash
coruja help
```

A arquitetura do instalador está documentada em
[`docs/architecture/installer.md`](docs/architecture/installer.md).

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

## URLs

| Serviço | Endereço |
|---|---|
| Projetos | `https://nome-do-projeto.localhost` |
| phpMyAdmin | `https://db.localhost` |
| Mailpit | `https://mail.localhost` |
| Traefik Dashboard | `http://localhost:8082/dashboard/` |

As requisições HTTP dos projetos, do phpMyAdmin e do Mailpit são redirecionadas
automaticamente para HTTPS.

Os certificados são gerados localmente com `mkcert`.

## Serviços internos

## Serviços internos

| Serviço | Host interno | Porta |
|---|---|---:|
| PHP/Apache | `web` | `80` |
| Node.js | `node` | interna |
| MariaDB | `database` | `3306` |
| Redis | `redis` | `6379` |
| Mailpit SMTP | `mail` | `1025` |
| Mailpit Web | `mail` | `8025` |
| Traefik | `gateway` | `80` e `443` |

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
coruja new <nome> [--template=<nome>]
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

### Node.js

```text
coruja node --version
coruja npm --version
coruja npm <projeto> install
coruja npm <projeto> run dev
coruja npx <projeto> <comando>
coruja pnpm <projeto> install
coruja yarn <projeto> install
```

O Node.js é executado em um container separado do PHP, utilizando o mesmo
diretório de projetos e o mesmo UID/GID do usuário do host.

Consulte a documentação completa em
[`docs/guides/node.md`](docs/guides/node.md).

### Sistema

```text
coruja doctor
coruja version
coruja help
```

## Criar um projeto

Criar um projeto com o template padrão:

```bash
coruja new meu-projeto
```

Criar um projeto informando o template:

```bash
coruja new minha-api --template=php-mvc-basic
```

O comando:

1. valida o nome e o template;
2. cria a estrutura do projeto;
3. gera o arquivo `.env`;
4. cria o banco de dados;
5. instala as dependências do Composer;
6. disponibiliza a aplicação no Traefik.

Acesse:

```text
https://meu-projeto.localhost
```

Os templates ficam armazenados em:

```text
project-templates/
```

O template disponível atualmente é:

```text
php-mvc-basic
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
coruja db restore meu_banco.sql 
```

Restaurar em outro banco:

```bash
coruja db restore meu_banco.sql banco_destino
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
https://meu-projeto.localhost/?XDEBUG_TRIGGER=1
```

## Diagnóstico

Execute:

```bash
coruja doctor
```

O diagnóstico é dividido em módulos e verifica:

- diretórios;
- permissões;
- Docker;
- Docker Compose;
- arquivos de configuração;
- MariaDB;
- Redis;
- Mailpit;
- Traefik;
- Docker Socket;
- conectividade HTTP;
- redirecionamento HTTP para HTTPS;
- certificados locais;
- configuração TLS;
- porta HTTPS;
- phpMyAdmin por HTTPS;
- Mailpit por HTTPS;
- projetos por HTTPS;
- serviço Node.js;
- Node.js;
- npm;
- npx;
- Corepack;
- pnpm;
- Yarn;
- UID do container Node.js;
- diretório de trabalho do Node.js.

Quando algum componente não está disponível, o comando informa o problema e
retorna um código de saída diferente de zero.

## Roadmap v0.2.0

- [x] instalador automatizado;
- [x] configuração de HTTPS local;
- [x] certificados automáticos com `mkcert`;
- [x] integração da CA entre WSL e Windows;
- [x] diagnóstico HTTP;
- [x] diagnóstico HTTPS;
- [x] diagnóstico Node.js;
- [x] testes automatizados da CLI;
- [x] templates desacoplados da CLI;
- [x] template `php-mvc-basic`;
- [x] serviço Node.js compartilhado;
- [x] comandos Node.js na CLI;
- [x] validação em macOS;
- [x] validação em WSL;
- [ ] configuração interativa avançada;
- [ ] importação de projetos do Laragon;
- [ ] validação completa em Linux nativo;
- [ ] documentação de migração;
- [ ] template Laravel;
- [ ] template WordPress;
- [ ] publicação e roteamento opcional para servidores Vite.