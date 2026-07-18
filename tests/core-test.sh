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

VERSION="test"

source "${TESTS_DIR}/test-helper.sh"
source "${CORUJA_ROOT}/cli/core.sh"

temporary_directory="$(mktemp -d)"
environment_file="${temporary_directory}/.env"

cleanup() {
    rm -rf "$temporary_directory"
}

trap cleanup EXIT

cat > "$environment_file" <<'ENV'
APP_NAME=Projeto Antigo
APP_URL=http://projeto-antigo.localhost
DB_DATABASE=projeto_antigo
ENV

replace_env_value \
    "$environment_file" \
    "APP_NAME" \
    "Projeto Novo"

app_name="$(
    grep '^APP_NAME=' "$environment_file" |
    cut -d '=' -f2-
)"

assert_equals \
    "replace_env_value altera uma chave existente" \
    "Projeto Novo" \
    "$app_name"

app_name_occurrences="$(
    grep -c '^APP_NAME=' "$environment_file"
)"

assert_equals \
    "replace_env_value não duplica uma chave existente" \
    "1" \
    "$app_name_occurrences"

replace_env_value \
    "$environment_file" \
    "APP_ENV" \
    "development"

app_environment="$(
    grep '^APP_ENV=' "$environment_file" |
    cut -d '=' -f2-
)"

assert_equals \
    "replace_env_value adiciona uma chave ausente" \
    "development" \
    "$app_environment"

original_database="$(
    grep '^DB_DATABASE=' "$environment_file" |
    cut -d '=' -f2-
)"

assert_equals \
    "replace_env_value preserva as demais chaves" \
    "projeto_antigo" \
    "$original_database"

if replace_env_value \
    "${temporary_directory}/arquivo-inexistente" \
    "APP_NAME" \
    "Teste" >/dev/null 2>&1; then
    print_test_failure \
        "replace_env_value falha quando o arquivo não existe"
else
    print_test_success \
        "replace_env_value falha quando o arquivo não existe"
fi

finish_tests
