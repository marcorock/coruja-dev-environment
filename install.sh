#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(
    cd -P "$(dirname "${BASH_SOURCE[0]}")" &&
    pwd
)"

source "${ROOT_DIR}/installer/common.sh"
source "${ROOT_DIR}/installer/system.sh"
source "${ROOT_DIR}/installer/dependencies.sh"
source "${ROOT_DIR}/installer/directories.sh"

main() {
    show_banner

    detect_system

    check_dependencies

    create_directories

    echo
    echo "Instalador inicializado com sucesso."
}

main "$@"