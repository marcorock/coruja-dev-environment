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
- execução de diagnósticos iniciais e posteriores à instalação;
- inicialização opcional do ambiente por meio da CLI;
- validação do ambiente após a inicialização;

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

## Fluxo de execução

O instalador executa três etapas principais:

1. **prepare_installation()**
   - detecção do sistema;
   - validação de dependências;
   - criação dos diretórios;
   - geração do `.env`;
   - validação da configuração.

2. **execute_installation()**
   - instalação da CLI;
   - execução do diagnóstico inicial;
   - inicialização opcional do ambiente;
   - validação do ambiente iniciado;
   - demais ações futuras.

3. **finish_installation()**
   - resumo da instalação;
   - próximos passos.