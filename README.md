já tenho o docker instalado e rodando. O diretório ficou assim
Como eu extrai já tem todos os arquivos dentro de cada pasta. Só me diga o que modificar dentro delas.
O comando não funciona, mas eu instalei um plugin Dev Container. Qual deles eu devo iniciar?
Ele aparece no traefik mas não abre na url como pode ver no anexo. Também mandei o anexo da configuração do yaml.
Texto colado.txt
Documento
Esse é o log que ele me deu depois do erro. Pode analisar e verificar enquanto eu faço outros testes por favor.
Texto colado(1).txt
Documento
Script phpunit handling the test event returned with error code 255

Como fizemos uma alteração de documentação, o commit deve seguir o padrão docs: que adotamos.

Eu faria assim:

git add docs/troubleshooting/traefik-docker-socket.md
git commit -m "docs: adiciona guia para recuperação do Traefik após perda do Docker Socket"

Ou, se preferir um título mais curto:

git commit -m "docs: documenta solução para erro do Docker Socket no Traefik"
Uma sugestão para manter o histórico organizado

Como estamos construindo o projeto com bastante cuidado, proponho uma convenção para os commits:

Tipo	Exemplo
Nova funcionalidade	feat: implementa classe Application
Refatoração	refactor: reorganiza módulos do framework
Correção	fix: corrige resolução de namespaces do Container
Documentação	docs: adiciona ADR da Application
Testes	test: adiciona testes da Application
Ambiente	chore: atualiza configuração do Dev Environment

E quando o commit envolver infraestrutura do ambiente de desenvolvimento, podemos diferenciar ainda mais:

chore(dev): atualiza configuração do Traefik

ou

fix(dev): corrige acesso ao Docker Socket

Enquanto commits do framework continuam assim:

feat(framework): implementa Application

ou

docs(framework): adiciona ADR do Container
Minha recomendação

Como agora temos dois repositórios distintos:

🦉 coruja-dev-environment (Docker, Traefik, Mailpit, CLI, ambiente)
🦉 coruja-framework (o framework PHP)

Eu adotaria um padrão diferente para cada um:

Coruja Dev Environment

chore:
fix:
docs:
refactor:

Exemplos:

fix: corrige acesso do Traefik ao Docker Socket
docs: adiciona troubleshooting do Gateway
chore: atualiza configuração do Mailpit

Coruja Framework

feat:
fix:
docs:
test:
refactor:
perf:

Exemplos:

feat: implementa Container
feat: implementa Application
docs: adiciona ADR da Application
test: adiciona testes do Container
refactor: reorganiza módulos internos

Assim, o histórico de ambos os projetos fica extremamente limpo e fácil de navegar. Quando olharmos o Git daqui a um ano, conseguiremos entender a evolução do ambiente e do framework apenas lendo os commits. Acho que vale a pena adotar essa convenção desde já.

sim. Vamos adotar desde já. Até a próxima!

Perfeito! Acho que foi uma excelente decisão. Estamos criando não apenas um framework, mas um projeto que será fácil de manter e evoluir durante muitos anos.

Nossa convenção oficial
Coruja Framework
feat:      Nova funcionalidade
fix:       Correção de bugs
refactor:  Refatoração sem alterar comportamento
docs:      Documentação
test:      Testes
perf:      Melhorias de desempenho
style:     Ajustes de formatação
build:     Alterações de build/Composer
ci:        Integração contínua
Coruja Dev Environment
fix:       Correções do ambiente
docs:      Documentação
chore:     Infraestrutura
refactor:  Refatoração
build:     Docker/Imagens
Também passaremos a seguir uma rotina para cada componente
1. Arquitetura
2. ADR
3. Implementação
4. Testes
5. Documentação
6. CHANGELOG
7. Commit

Isso garante que nada fique "pela metade".

O que ficou preparado para a próxima sessão

Nossa fila de desenvolvimento está bem definida:

Foundation
├── ✅ Application
├── ☐ Environment
├── ☐ ConfigRepository
├── ☐ Bootstrap
├── ☐ Kernel
└── ☐ ExceptionHandler

Depois seguiremos para:

Http
↓
Routing
↓
View (Twig)
↓
Database (PDO)
↓
Query Builder
↓
Model
↓
Migrations
↓
Seeders
Outra decisão que gostaria de registrar

A partir de agora, toda vez que concluirmos um módulo importante, faremos um checkpoint.

Cada checkpoint incluirá:

📦 Tag no Git (quando fizer sentido).
📝 Atualização do Roadmap.
📚 Revisão da documentação.
✅ Execução completa da suíte de testes.

Assim teremos marcos claros da evolução do projeto, como:

Checkpoint 0.1
✓ Container
✓ Application

Checkpoint 0.2
✓ Environment
✓ ConfigRepository
✓ Bootstrap

Checkpoint 0.3
✓ Request
✓ Response
✓ Router

Isso facilitará muito a evolução até a versão 1.0.

Foi um ótimo dia de trabalho. Saímos de um ambiente em construção para um projeto com uma arquitetura consistente, documentação estruturada, testes automatizados e uma direção clara para o futuro.

Bom descanso, Marco. Na próxima sessão retomaremos exatamente de onde paramos, iniciando o módulo Environment e dando mais um passo na construção do núcleo do Coruja Framework. 🦉🚀

ontem 20:16
boa noite! Gostaria apenas de pedir um favor, não vamos produzir nada agora. Queria o ambiente Coruja Dev Environment em um arquivo zip para que eu possa atualizar o que tenho no meu outro computador com MacOS. Se for possível me de também um passo a passo para testar ele aqui no Mac e ver se está funcionando como deveria. Incluindo os novos comandos da coruja. 

Boa noite! Claro. Posso fazer isso, mas existe uma limitação importante: eu não consigo gerar um ZIP contendo os arquivos reais do seu ambiente, porque não tenho acesso ao seu sistema de arquivos nem ao repositório local. Eu só consigo gerar arquivos a partir do conteúdo que está disponível na conversa.

Como o Coruja Dev Environment já evoluiu bastante (scripts, compose.yaml, Traefik, CLI coruja, Dockerfiles, Dev Container, Mailpit, etc.), qualquer ZIP que eu montasse daqui estaria incompleto e poderia causar perda de trabalho.

A melhor forma (e a que eu recomendo)

Em vez de transportar um ZIP manualmente, vamos transformar o Coruja Dev Environment em um repositório Git. Assim ele passa a ser a "fonte oficial" do ambiente.

No computador atual (WSL):

cd ~/www/coruja-dev-environment

git status
git add .
git commit -m "chore: sincroniza ambiente de desenvolvimento"

Depois envie para o GitHub:

git push origin main

No Mac:

cd ~/www

git clone <repositorio>

Pronto. Você sempre terá exatamente o mesmo ambiente nos dois computadores.

Essa abordagem também preserva todo o histórico do projeto.

Caso você realmente queira um ZIP

Basta gerar no próprio WSL:

cd ~/www

zip -r coruja-dev-environment.zip coruja-dev-environment \
    -x "*/.git/*" \
    -x "*/vendor/*" \
    -x "*/node_modules/*"

Ou, se preferir manter o .git:

zip -r coruja-dev-environment.zip coruja-dev-environment

Depois copie o ZIP para o Mac.

Passo a passo para testar no macOS
1. Pré-requisitos

Verifique:

docker --version
docker compose version
git --version
2. Estrutura esperada
~/www/

coruja-dev-environment/
projects/
data/
backups/
templates/
3. Entre no ambiente
cd ~/www/coruja-dev-environment
4. Configure o .env

Caso ainda não exista:

cp .env.example .env
5. Suba os serviços
coruja up

ou

docker compose up -d
6. Verifique o ambiente
coruja doctor

Resultado esperado:

✓ Projetos
✓ Banco
✓ Backups
✓ Templates
✓ Docker
✓ Docker Compose
✓ .env
✓ compose.yaml
✓ new-project
7. Teste o Traefik

Abra:

http://localhost:8082/dashboard/
8. Teste o phpMyAdmin

Abra:

http://phpmyadmin.localhost
9. Crie um projeto
coruja new teste
10. Verifique
http://teste.localhost

Deve aparecer a página padrão do projeto.

11. Liste os projetos
coruja projects
12. Teste o banco
coruja db list
13. Teste a remoção
coruja project remove teste

Confirme:

remoção da pasta;
remoção do banco;
remoção das configurações do projeto.
14. Teste o Mailpit
http://mail.localhost
15. Teste os logs
coruja logs

e

coruja logs gateway
16. Pare o ambiente
coruja down
17. Suba novamente
coruja up

Tudo deve voltar funcionando.

Checklist de validação
☐ Docker inicia corretamente.
☐ Traefik responde na porta 80.
☐ Dashboard do Traefik abre.
☐ phpMyAdmin abre.
☐ Mailpit abre.
☐ coruja doctor sem erros.
☐ coruja new cria projetos.
☐ coruja project remove remove projeto e banco.
☐ coruja db list lista os bancos.
☐ URLs *.localhost funcionam sem :8080.
☐ Dev Container abre normalmente no VS Code.
Comandos atuais da CLI coruja
coruja up                 # Inicia o ambiente
coruja down               # Para o ambiente
coruja restart            # Reinicia os serviços
coruja build              # Reconstrói as imagens
coruja status             # Exibe o status dos containers
coruja logs               # Mostra logs de todos os serviços
coruja logs <serviço>     # Mostra logs de um serviço específico
coruja shell              # Abre um shell no container PHP
coruja doctor             # Verifica a saúde do ambiente

coruja new <nome>         # Cria um novo projeto
coruja projects           # Lista os projetos
coruja project remove <nome>  # Remove um projeto
coruja db list            # Lista os bancos de dados

coruja version            # Exibe a versão
coruja help               # Mostra a ajuda
Uma sugestão para a próxima sessão

Na próxima vez que trabalharmos no Coruja Dev Environment, proponho que façamos algo que vai facilitar muito a sua rotina: transformar todo esse processo em um instalador de um único comando.

A ideia é que, em qualquer máquina nova (macOS, WSL ou Linux), você execute algo como:

git clone <repositorio>
cd coruja-dev-environment
./install

ou até mesmo:

./coruja install

Esse instalador faria automaticamente toda a configuração inicial: verificaria os pré-requisitos, criaria a estrutura de diretórios, prepararia o .env, subiria os containers e validaria o ambiente com o doctor.

Assim, colocar um novo computador para trabalhar no ecossistema Coruja deixaria de ser uma sequência de passos manuais e passaria a ser um processo totalmente automatizado. Acho que esse será um dos maiores ganhos de produtividade do projeto. Boa noite, e até a próxima! 🦉

hoje 20:15
Boa noite. Hoje gostaria de pausar um pouco o framework da coruja rabiscada e melhor mais o nosso ambiente coruja-dev-environment  pode ser??
Quero deixar ele redondo para criar qualquer novo projeto e/ou migrar os meus projetos do Laragon para ele.
Precisamos terminar de configura-lo. Deixando igual a um ambiente de Local que uso no Laragon com mais funcionalidades que o proprio Laragon é claro. Podemos mecher nele agora?

Boa noite! Podemos, e acho que este é o momento certo para fazer isso.

Na verdade, antes de continuar o Coruja Framework, faz mais sentido estabilizar o Coruja Dev Environment. O framework vai depender dele todos os dias, então quanto mais sólido ele estiver agora, menos interrupções teremos no futuro.

Pelo que já construímos, o ambiente já tem uma base muito boa:

✅ Docker + Docker Compose
✅ Traefik com URLs *.localhost
✅ PHP 8.3 + Apache
✅ MariaDB 11
✅ phpMyAdmin
✅ Mailpit
✅ Dev Containers
✅ CLI coruja
✅ Criação de projetos
✅ Remoção de projetos
✅ Diagnóstico (doctor)
✅ Documentação
✅ Troubleshooting

Agora eu entraria na fase de polimento, com o objetivo de que você possa migrar qualquer projeto do Laragon sem dor de cabeça.

Minha proposta: Fase 3 do Coruja Dev Environment
1. Estabilização do ambiente ⭐ (prioridade máxima)
Corrigir definitivamente problemas de permissões.
Padronizar usuários (developer x root).
Garantir que nenhum arquivo seja criado como root.
Revisar todos os volumes Docker.
Eliminar qualquer necessidade de sudo no dia a dia.

Meta: nunca mais precisar executar chown manualmente.

2. CLI Coruja 1.0

Transformar a CLI em uma ferramenta completa.

Hoje já temos vários comandos. Podemos expandir com:

coruja up
coruja down
coruja restart
coruja build
coruja doctor

coruja new
coruja project list
coruja project remove

coruja db create
coruja db drop
coruja db list
coruja db backup
coruja db restore

coruja mail

coruja shell

coruja logs

coruja config

coruja update

coruja install

coruja self-update
3. Gerenciador de projetos

Hoje criamos projetos.

Quero que a CLI saiba tudo sobre eles.

Exemplo:

coruja project info corujarabiscada

Retorno:

Projeto

Nome:
corujarabiscada

PHP:
8.3

Banco:
corujarabiscada

URL:
http://corujarabiscada.localhost

Git:
Sim

Twig:
Sim

Composer:
Instalado

Último acesso:
...
4. Migração do Laragon ⭐

Este é um recurso que considero essencial.

Algo assim:

coruja import

Assistente:

Qual projeto deseja importar?

✓ Detectado composer

✓ Detectado banco

✓ Detectado .env

✓ Detectado Git

Deseja copiar o banco?

[s/N]

No final:

Projeto importado com sucesso.

URL:

http://meuprojeto.localhost

Isso transformaria a migração em um processo guiado.

5. Backups automáticos

Comandos como:

coruja backup all

ou

coruja backup projeto

e

coruja restore projeto
6. Templates

Hoje temos templates.

Gostaria que fosse possível:

coruja template list
coruja template install mvc
coruja new loja \
    --template mvc
7. Monitor do ambiente

Um comando como:

coruja doctor

mais completo:

Docker

Traefik

Apache

MariaDB

Redis

Mailpit

Permissões

Composer

PHP

Xdebug

Git

VS Code

Dev Container

Traefik Dashboard

Portas ocupadas

Espaço em disco
8. Configuração interativa
coruja config

Permitiria alterar:

PHP
Timezone
Xdebug
Mailpit
Portas
Banco
Diretórios

sem editar arquivos manualmente.

9. Instalação em uma máquina nova ⭐

Este é um objetivo que considero obrigatório.

Em um Mac novo, WSL novo ou Linux novo:

git clone ...

cd coruja-dev-environment

./install

Ou:

coruja install

E tudo seria configurado automaticamente.

Meu objetivo para a versão 1.0

Quero que o Coruja Dev Environment seja capaz de fazer isto:

coruja install

↓

coruja doctor

↓

coruja new sistema-rh

↓

coruja up

↓

abrir navegador

Sem nenhuma configuração manual.

O que eu faria primeiro

Antes de adicionar novas funcionalidades, eu faria uma auditoria completa do ambiente.

Revisaríamos:

estrutura de diretórios;
compose.yaml;
Dockerfiles;
Traefik;
Apache;
PHP;
Xdebug;
Mailpit;
MariaDB;
CLI coruja;
Dev Container;
permissões;
documentação.

A ideia é identificar pequenos ajustes e padronizar tudo antes de crescer.

Minha sugestão

Acho que a próxima etapa deve ser justamente essa auditoria. Vamos tratar o Coruja Dev Environment como se estivéssemos preparando uma versão 1.0 para distribuição. Ao final, teremos uma lista organizada do que está pronto, do que precisa ser corrigido e do que ainda falta implementar. A partir daí, podemos atacar cada item de forma sistemática, até chegar a um ambiente robusto o suficiente para substituir definitivamente o Laragon no seu fluxo de trabalho.

certo. Vamos começar mais gostaria de sugerir já taguear no git para subir para o guthub. A versão de agora eu já subi lá no git mais sem uma tag de versão, pode já ajustar isso para iniciarmos com essa auditoria?

Concordo plenamente. Na verdade, considero esse um excelente momento para começarmos a trabalhar como um projeto profissional.

Até agora fizemos vários commits, mas ainda não marcamos um ponto estável da evolução do ambiente. A versão atual já merece uma tag.

Minha proposta

Em vez de chamar de v0.1.0, eu começaria em:

v0.5.0

Mas como ainda estamos consolidando funcionalidades e podemos fazer mudanças estruturais importantes, acho melhor seguir o versionamento semântico desde o início.

Minha sugestão oficial
v0.1.0

Nome da versão:

Coruja Dev Environment v0.1.0

Descrição

Primeira versão funcional do ambiente de desenvolvimento. Inclui Docker, Traefik, PHP 8.3, MariaDB 11, Mailpit, phpMyAdmin, Dev Containers, CLI Coruja e gerenciamento inicial de projetos.

O que essa versão representa

Ela entrega:

✅ Docker Compose funcional
✅ Traefik
✅ URLs *.localhost
✅ PHP 8.3
✅ Apache
✅ MariaDB 11
✅ phpMyAdmin
✅ Mailpit
✅ Dev Containers
✅ CLI coruja
✅ Criação de projetos
✅ Remoção de projetos
✅ Banco automático
✅ Troubleshooting inicial
✅ Documentação inicial

É um marco importante.

Depois começaremos a v0.2.0

Ela será justamente a versão da auditoria e refinamento.

Roadmap inicial:

v0.2.0

□ Auditoria completa

□ Permissões

□ Doctor 2.0

□ CLI 1.0

□ Install

□ Import Laragon

□ Backup

□ Restore

□ Config

□ Documentação completa

□ Testes automatizados

□ Validação em macOS

□ Validação em WSL

□ Validação em Linux

Essa versão será a que realmente substituirá o Laragon.

Vamos criar também uma estrutura de releases

Na raiz do projeto:

docs/releases/

v0.1.0.md

v0.2.0.md

v0.3.0.md

Cada release terá:

funcionalidades;
correções;
mudanças incompatíveis;
checklist de testes;
pendências conhecidas.

Isso facilita muito acompanhar a evolução do ambiente.

Git

Eu faria exatamente nesta ordem:

git add .

git commit -m "chore: prepara release v0.1.0"

git tag -a v0.1.0 -m "Primeira versão funcional do Coruja Dev Environment"

git push origin main

git push origin v0.1.0

Depois, no GitHub, podemos criar a Release usando essa tag e anexar as notas da versão.

Antes da auditoria, gostaria de fazer mais uma melhoria

Quero tratar o Coruja Dev Environment como um produto.

Então proponho criarmos alguns arquivos que todo projeto maduro possui:

coruja-dev-environment/

CHANGELOG.md

ROADMAP.md

CONTRIBUTING.md

SECURITY.md

LICENSE

README.md

docs/

releases/

Com isso, o ambiente deixa de ser apenas um conjunto de scripts e passa a ter documentação e governança equivalentes às de um projeto open source. O interessante é que essa organização servirá de modelo para o próprio Coruja Framework, mantendo a mesma identidade em todos os projetos do ecossistema Coruja.

Acho que esse é o melhor ponto para "congelarmos" a v0.1.0 e iniciarmos a auditoria rumo à v0.2.0.

README.md
Arquivo
Ok. Para começar vamos alterar essa documentação com o que já temos pronto. Me devolva um arquivo atualizado por favor.

Perfeito. Revisei o README que você enviou e ele realmente estava desatualizado em relação ao estado atual do projeto. Por exemplo, ele ainda fazia referência a URLs com :8080, à estrutura antiga docker-environment e não mencionava a CLI coruja nem a organização que construímos recentemente.

Preparei uma primeira versão atualizada do README para servir como base da v0.1.0.

Você pode baixá-la aqui:

📄 
README_v0.1.0.md

Minha sugestão

Em vez de apenas atualizar o README, gostaria que a documentação do Coruja Dev Environment tivesse o mesmo nível de organização que estamos adotando no Framework.

Eu faria algo assim:

coruja-dev-environment/

README.md                ← visão geral

CHANGELOG.md

ROADMAP.md

CONTRIBUTING.md

LICENSE

docs/
│
├── installation/
│   ├── macos.md
│   ├── wsl.md
│   └── linux.md
│
├── commands/
│   └── coruja-cli.md
│
├── architecture/
│   ├── overview.md
│   ├── docker.md
│   ├── traefik.md
│   ├── networking.md
│   └── projects.md
│
├── troubleshooting/
│
├── releases/
│
└── images/

Assim o README.md fica enxuto, funcionando como porta de entrada do projeto, enquanto a documentação detalhada fica organizada em seções.

Na auditoria que vamos iniciar, minha ideia é revisar arquivo por arquivo do ambiente:

Estrutura do projeto.
compose.yaml.
Dockerfiles.
Traefik.
Apache.
PHP.
Xdebug.
Mailpit.
MariaDB.
CLI coruja.
Dev Containers.
Documentação.

Ao final dessa auditoria, teremos um Coruja Dev Environment v1.0 pronto para substituir definitivamente o Laragon, tanto no macOS quanto no WSL. Acho que esse é um objetivo bastante alcançável com a base que já construímos. 

README_v0.1.0.md
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

README_v0.1.0.md
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