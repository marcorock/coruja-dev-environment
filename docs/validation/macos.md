# Validação no macOS

## Ambiente testado

O Coruja Dev Environment foi instalado e validado no macOS utilizando Docker
Desktop.

## Funcionalidades verificadas

- clonagem do repositório;
- configuração do arquivo `.env`;
- criação dos diretórios persistentes;
- instalação da CLI `coruja`;
- inicialização dos containers;
- criação de projetos;
- instalação de dependências com Composer;
- criação automática de banco de dados;
- acesso aos projetos por domínio `.localhost`;
- acesso ao phpMyAdmin;
- acesso ao Mailpit;
- funcionamento do Redis;
- comunicação do Traefik com o Docker Socket;
- execução do diagnóstico `coruja doctor`.

## Resultado do diagnóstico

```text
✓ MariaDB respondendo
✓ Redis respondendo
✓ Mailpit em execução
✓ Docker Socket disponível no Traefik

Verificando HTTP...

✓ Traefik Gateway: HTTP 404
✓ phpMyAdmin: HTTP 200
✓ Mailpit: HTTP 200

Ambiente saudável.

```

O retorno HTTP 404 do Gateway é esperado quando a raiz do Traefik é acessada
sem um domínio de projeto.

## Resultado

O ambiente foi considerado funcional e compatível com macOS.