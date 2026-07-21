#!/usr/bin/env bash

set -u

TESTS_DIR="$(
    cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 &&
    pwd
)"

CORUJA_ROOT="$(
    cd -P "${TESTS_DIR}/.." >/dev/null 2>&1 &&
    pwd
)"

source "${TESTS_DIR}/test-helper.sh"
source "${CORUJA_ROOT}/cli/commands/node.sh"

echo "Testes dos comandos Node.js"
echo ""

help_output="$(node_show_help 2>&1)"

assert_contains \
    "ajuda Node apresenta node" \
    "$help_output" \
    "coruja node [projeto] <argumentos>"

assert_contains \
    "ajuda Node apresenta npm" \
    "$help_output" \
    "coruja npm [projeto] <argumentos>"

assert_contains \
    "ajuda Node apresenta npx" \
    "$help_output" \
    "coruja npx [projeto] <argumentos>"

assert_contains \
    "ajuda Node apresenta pnpm" \
    "$help_output" \
    "coruja pnpm [projeto] <argumentos>"

assert_contains \
    "ajuda Node apresenta Yarn" \
    "$help_output" \
    "coruja yarn [projeto] <argumentos>"

valid_project_output="$(
    node_validate_project_name "meu-projeto" 2>&1
)"

if node_validate_project_name "meu-projeto" >/dev/null 2>&1; then
    print_test_success \
        "nome de projeto válido é aceito"
else
    print_test_failure \
        "nome de projeto válido é aceito"
fi

invalid_project_output="$(
    node_validate_project_name "../projeto" 2>&1 ||
    true
)"

assert_contains \
    "nome com travessia de diretório é rejeitado" \
    "$invalid_project_output" \
    "Nome de projeto inválido"

if node_validate_project_name "../projeto" >/dev/null 2>&1; then
    print_test_failure \
        "nome inválido retorna código diferente de zero"
else
    print_test_success \
        "nome inválido retorna código diferente de zero"
fi

empty_workdir_output="$(
    node_resolve_workdir 2>&1
)"

assert_equals \
    "diretório padrão do Node é a raiz de projetos" \
    "/var/www/projects" \
    "$empty_workdir_output"

finish_tests