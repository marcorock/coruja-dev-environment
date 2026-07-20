#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(
    cd -P "$(dirname "${BASH_SOURCE[0]}")" &&
    pwd
)"

source "${ROOT_DIR}/installer/core/common.sh"
source "${ROOT_DIR}/installer/core/output.sh"
source "${ROOT_DIR}/installer/core/system.sh"
source "${ROOT_DIR}/installer/core/flow.sh"
source "${ROOT_DIR}/installer/core/interaction.sh"

source "${ROOT_DIR}/installer/checks/dependencies.sh"
source "${ROOT_DIR}/installer/checks/validation.sh"

source "${ROOT_DIR}/installer/setup/directories.sh"
source "${ROOT_DIR}/installer/setup/environment.sh"

source "${ROOT_DIR}/installer/actions/install_cli.sh"
source "${ROOT_DIR}/installer/actions/run_cli.sh"
source "${ROOT_DIR}/installer/actions/diagnostics.sh"
source "${ROOT_DIR}/installer/actions/start_environment.sh"



main() {

    show_banner

    prepare_installation

    execute_installation

    finish_installation

}

main "$@"