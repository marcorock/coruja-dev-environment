# Validação no WSL

## Ambiente testado

O Coruja Dev Environment foi instalado e validado no Windows utilizando WSL
com Docker Desktop integrado à distribuição Linux.

## Funcionalidades verificadas

- clonagem e atualização do repositório;
- uso da branch de desenvolvimento;
- configuração do arquivo `.env`;
- criação dos diretórios persistentes;
- instalação e execução da CLI `coruja`;
- inicialização e encerramento dos containers;
- criação de projetos;
- clonagem e remoção de projetos;
- instalação de dependências com Composer;
- criação automática de banco de dados;
- backup e restauração de banco;
- acesso aos projetos por domínio `.localhost`;
- acesso ao phpMyAdmin;
- acesso ao Mailpit;
- funcionamento do Redis;
- comunicação do Traefik com o Docker Socket;
- execução dos testes automatizados;
- execução do diagnóstico `coruja doctor`;
- execução inicial do instalador modular.

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
• Projeto HTTP: nenhum projeto com pasta public encontrado

Ambiente saudável.
```

O retorno HTTP 404 do Gateway é esperado quando a raiz do Traefik é acessada
sem um domínio de projeto.

A mensagem sobre ausência de projeto HTTP é apenas informativa e não representa
falha no ambiente.

## Integração com Windows

O código e os dados do ambiente foram mantidos dentro do sistema de arquivos
Linux do WSL, evitando a execução dos projetos diretamente em caminhos
montados como `/mnt/c`.

O Docker Desktop foi utilizado com integração habilitada para a distribuição
WSL.

## Resultado

O ambiente foi considerado funcional e compatível com Windows utilizando WSL.