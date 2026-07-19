# Arquitetura do instalador

O instalador é dividido por responsabilidade.

## core

Funções fundamentais compartilhadas por todos os módulos.

Exemplos:

- exibição do banner;
- mensagens de saída;
- detecção do sistema operacional.

## checks

Validações executadas antes ou durante a instalação.

Exemplos:

- dependências obrigatórias;
- validação de configurações;
- verificação de permissões.

## setup

Preparação de arquivos, diretórios e configurações locais.

Exemplos:

- criação dos diretórios persistentes;
- geração do arquivo `.env`.

## actions

Ações executadas após a preparação inicial.

Exemplos:

- instalação da CLI;
- inicialização do ambiente;
- criação do primeiro projeto.

As ações devem reutilizar a CLI sempre que uma funcionalidade equivalente já
existir, evitando duplicação de lógica.

## finalize

Etapas finais e resumo da instalação.

Exemplos:

- apresentação das URLs;
- próximos comandos;
- resultado final da instalação.