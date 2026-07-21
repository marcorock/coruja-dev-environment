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

failures=0

run_test_file() {
    local test_file="$1"

    echo ""
    echo "Executando $(basename "$test_file")"
    echo "────────────────────────────────────────"

    if bash "$test_file"; then
        return 0
    fi

    failures=$((failures + 1))
    return 0
}

echo "Coruja Dev Environment"
echo "Testes automatizados"
echo ""

echo "Verificando sintaxe Bash..."

while IFS= read -r script_file; do
    relative_path="${script_file#"${CORUJA_ROOT}/"}"

    if bash -n "$script_file"; then
        echo "✓ ${relative_path}"
    else
        echo "✗ ${relative_path}"
        failures=$((failures + 1))
    fi
done < <(
    find "$CORUJA_ROOT" \
        -type f \
        \( -name "*.sh" -o -name "coruja" \) \
        -not -path "${CORUJA_ROOT}/.git/*" \
        -print |
    sort
)

run_test_file "${TESTS_DIR}/cli-test.sh"
run_test_file "${TESTS_DIR}/core-test.sh"
run_test_file "${TESTS_DIR}/node-test.sh"

echo ""
echo "════════════════════════════════════════"
echo ""

if ((failures > 0)); then
    echo "A suíte encontrou ${failures} grupo(s) com falha."
    exit 1
fi

echo "Suíte concluída com sucesso."
