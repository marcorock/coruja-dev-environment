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

echo "Testes da CLI Coruja"
echo ""

version_output="$("${CORUJA_ROOT}/coruja" version 2>&1)"

assert_contains \
    "comando version exibe a versão" \
    "$version_output" \
    "Coruja Dev Environment 0.1.0"

help_output="$("${CORUJA_ROOT}/coruja" help 2>&1)"

assert_contains \
    "ajuda apresenta o comando de criação" \
    "$help_output" \
    "new <nome>"

assert_contains \
    "ajuda apresenta backup de banco" \
    "$help_output" \
    "db backup <banco>"

assert_contains \
    "ajuda apresenta restauração de banco" \
    "$help_output" \
    "db restore <arquivo> [banco]"

assert_contains \
    "ajuda apresenta diagnóstico" \
    "$help_output" \
    "doctor"

assert_contains \
    "ajuda apresenta comando Node.js" \
    "$help_output" \
    "node [projeto] <argumentos>"

assert_contains \
    "ajuda apresenta comando npm" \
    "$help_output" \
    "npm [projeto] <argumentos>"

assert_contains \
    "ajuda apresenta comando npx" \
    "$help_output" \
    "npx [projeto] <argumentos>"

assert_contains \
    "ajuda apresenta comando pnpm" \
    "$help_output" \
    "pnpm [projeto] <argumentos>"

assert_contains \
    "ajuda apresenta comando Yarn" \
    "$help_output" \
    "yarn [projeto] <argumentos>"

short_help_output="$("${CORUJA_ROOT}/coruja" -h 2>&1)"
long_help_output="$("${CORUJA_ROOT}/coruja" --help 2>&1)"

assert_contains \
    "opção -h exibe ajuda" \
    "$short_help_output" \
    "coruja <comando> [argumentos]"

assert_contains \
    "opção --help exibe ajuda" \
    "$long_help_output" \
    "coruja <comando> [argumentos]"

unknown_output="$(
    "${CORUJA_ROOT}/coruja" comando-inexistente 2>&1 ||
    true
)"

assert_contains \
    "comando inválido apresenta mensagem adequada" \
    "$unknown_output" \
    "Comando desconhecido: comando-inexistente"

if "${CORUJA_ROOT}/coruja" comando-inexistente \
    >/dev/null 2>&1; then
    print_test_failure \
        "comando inválido retorna código diferente de zero"
else
    print_test_success \
        "comando inválido retorna código diferente de zero"
fi

finish_tests
