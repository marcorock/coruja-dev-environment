# Node.js no Coruja Dev Environment

O Coruja Dev Environment fornece um serviço Node.js compartilhado para executar
ferramentas de frontend sem instalar Node.js diretamente no sistema operacional.

O serviço pode ser utilizado por projetos PHP puro, Laravel, WordPress e outras
aplicações armazenadas no diretório de projetos do ambiente.

## Ferramentas disponíveis

A imagem Node.js contém:

- Node.js 24;
- npm;
- npx;
- Corepack;
- pnpm 11;
- Yarn 1.

As versões exatas podem ser consultadas por meio da CLI:

```bash
coruja node --version
coruja npm --version
coruja npx --version
coruja pnpm --version
coruja yarn --version
```

## Arquitetura

O Node.js é executado em um container separado do PHP.

```text
Host
└── projects/
    ├── projeto-a/
    └── projeto-b/
         │
         ├── container PHP
         │   └── /var/www/projects
         │
         └── container Node.js
             └── /var/www/projects
```

Os containers PHP e Node.js compartilham o mesmo diretório de projetos, mas
mantêm suas ferramentas e dependências de sistema isoladas.

## Serviço Docker

O serviço é definido no `compose.yaml` com o nome:

```text
node
```

A imagem é construída por:

```text
Dockerfile.node
```

O container utiliza:

```text
/var/www/projects
```

como diretório de trabalho padrão.

## Permissões

O usuário do container Node.js utiliza o mesmo UID e GID configurados no
arquivo `.env`:

```env
USER_UID=1000
USER_GID=1000
```

Isso evita que arquivos como `package-lock.json`, `pnpm-lock.yaml`,
`yarn.lock` e `node_modules` sejam criados como `root`.

Para verificar:

```bash
docker compose exec node id
```

## Iniciar o serviço

O serviço Node.js é iniciado junto com o ambiente:

```bash
coruja up
```

Também pode ser iniciado isoladamente:

```bash
docker compose up -d node
```

A CLI inicia automaticamente o serviço quando um comando Node.js é executado e
o container está parado.

## Sintaxe da CLI

A sintaxe geral é:

```text
coruja <ferramenta> [projeto] <argumentos>
```

Ferramentas disponíveis:

```text
node
npm
npx
pnpm
yarn
```

## Comandos globais

Comandos iniciados por uma opção, como `--version`, são executados na raiz
compartilhada de projetos:

```bash
coruja node --version
coruja npm --version
coruja pnpm --version
```

## Executar em um projeto

Para executar uma ferramenta dentro de um projeto, informe o nome do diretório
como primeiro argumento:

```bash
coruja npm meu-projeto install
coruja npm meu-projeto run dev
coruja pnpm meu-projeto install
coruja yarn meu-projeto install
```

O comando:

```bash
coruja npm meu-projeto install
```

é executado internamente em:

```text
/var/www/projects/meu-projeto
```

## Exemplos com npm

Instalar dependências:

```bash
coruja npm meu-projeto install
```

Adicionar uma dependência:

```bash
coruja npm meu-projeto install axios
```

Adicionar uma dependência de desenvolvimento:

```bash
coruja npm meu-projeto install --save-dev vite
```

Executar um script:

```bash
coruja npm meu-projeto run dev
```

Criar uma versão de produção:

```bash
coruja npm meu-projeto run build
```

## Exemplos com pnpm

Instalar dependências:

```bash
coruja pnpm meu-projeto install
```

Adicionar um pacote:

```bash
coruja pnpm meu-projeto add axios
```

Adicionar uma dependência de desenvolvimento:

```bash
coruja pnpm meu-projeto add -D vite
```

Executar um script:

```bash
coruja pnpm meu-projeto run dev
```

## Exemplos com Yarn

Instalar dependências:

```bash
coruja yarn meu-projeto install
```

Adicionar um pacote:

```bash
coruja yarn meu-projeto add axios
```

Executar um script:

```bash
coruja yarn meu-projeto run dev
```

## Exemplos com npx

Executar Vite:

```bash
coruja npx meu-projeto vite
```

Criar uma configuração:

```bash
coruja npx meu-projeto vite --host 0.0.0.0
```

## Vite e servidores de desenvolvimento

Processos como:

```bash
coruja npm meu-projeto run dev
```

permanecem ligados ao terminal atual.

Para que um servidor de desenvolvimento seja acessível fora do container, ele
deve escutar em:

```text
0.0.0.0
```

Exemplo de script:

```json
{
  "scripts": {
    "dev": "vite --host 0.0.0.0"
  }
}
```

A publicação e o roteamento da porta do servidor Vite ainda precisam ser
configurados conforme o projeto. O serviço Node.js compartilhado não publica
automaticamente uma porta de frontend.

## Projeto inexistente

A CLI valida a existência do projeto antes de executar o comando:

```bash
coruja npm projeto-inexistente install
```

Resultado:

```text
Projeto não encontrado: projeto-inexistente
Diretório esperado:
  /caminho/para/projects/projeto-inexistente
```

## Segurança do nome do projeto

Nomes de projeto aceitam:

- letras;
- números;
- pontos;
- hífens;
- sublinhados.

Tentativas de travessia de diretório são rejeitadas:

```text
../projeto
```

## Diagnóstico

Execute:

```bash
coruja doctor
```

O diagnóstico Node.js verifica:

- existência do serviço no Docker Compose;
- estado do container;
- versão do Node.js;
- versão do npm;
- versão do npx;
- versão do Corepack;
- versão do pnpm;
- versão do Yarn;
- UID do usuário;
- diretório de trabalho.

Exemplo:

```text
Verificando Node.js...

✓ Serviço Node.js configurado
✓ Serviço Node.js em execução
✓ Node.js: v24.18.0
✓ npm: 11.16.0
✓ npx: 11.16.0
✓ Corepack: 0.35.0
✓ pnpm: 11.15.1
✓ Yarn: 1.22.22
✓ Usuário Node.js: UID 1000
✓ Diretório Node.js: /var/www/projects
```

## Comandos Docker equivalentes

A CLI:

```bash
coruja npm meu-projeto install
```

equivale aproximadamente a:

```bash
docker compose exec \
    --workdir /var/www/projects/meu-projeto \
    node \
    npm install
```

O uso da CLI é recomendado porque ela valida o ambiente, verifica o projeto e
inicia o serviço automaticamente quando necessário.

## Solução de problemas

### Serviço parado

```bash
docker compose up -d node
```

### Reconstruir a imagem

```bash
docker compose build --no-cache node
docker compose up -d --force-recreate node
```

### Conferir versões

```bash
docker compose exec -T node node --version
docker compose exec -T node npm --version
docker compose exec -T node pnpm --version
docker compose exec -T node yarn --version
```

### Arquivos criados como root

Confira o UID configurado:

```bash
grep -E '^(USER_UID|USER_GID)=' .env
```

Confira o usuário do container:

```bash
docker compose exec node id
```

Depois reconstrua a imagem caso os valores tenham sido alterados:

```bash
docker compose build --no-cache node
docker compose up -d --force-recreate node
```