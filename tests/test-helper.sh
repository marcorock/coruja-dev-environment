#!/usr/bin/env bash

TESTS_PASSED=0
TESTS_FAILED=0

print_test_success() {
    local description="$1"

    echo "✓ ${description}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

print_test_failure() {
    local description="$1"
    local details="${2:-}"

    echo "✗ ${description}"

    if [[ -n "$details" ]]; then
        echo "  ${details}"
    fi

    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_success() {
    local description="$1"
    shift

    if "$@"; then
        print_test_success "$description"
        return 0
    fi

    print_test_failure "$description"
    return 0
}

assert_failure() {
    local description="$1"
    shift

    if "$@"; then
        print_test_failure \
            "$description" \
            "o comando terminou com sucesso, mas deveria falhar"
        return 0
    fi

    print_test_success "$description"
    return 0
}

assert_contains() {
    local description="$1"
    local content="$2"
    local expected="$3"

    if [[ "$content" == *"$expected"* ]]; then
        print_test_success "$description"
        return 0
    fi

    print_test_failure \
        "$description" \
        "texto esperado não encontrado: ${expected}"

    return 0
}

assert_equals() {
    local description="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$actual" == "$expected" ]]; then
        print_test_success "$description"
        return 0
    fi

    print_test_failure \
        "$description" \
        "esperado '${expected}', recebido '${actual}'"

    return 0
}

finish_tests() {
    echo ""
    echo "Resultado:"
    echo "  ${TESTS_PASSED} teste(s) aprovado(s)"
    echo "  ${TESTS_FAILED} teste(s) reprovado(s)"
    echo ""

    if ((TESTS_FAILED > 0)); then
        return 1
    fi

    echo "Todos os testes passaram."
    return 0
}
