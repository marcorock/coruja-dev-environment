#!/usr/bin/env bash

resolve_cli_path() {
    local path="$1"
    local directory
    local target

    while [[ -L "$path" ]]; do
        directory="$(
            cd -P "$(dirname "$path")" >/dev/null 2>&1 &&
            pwd
        )"

        target="$(readlink "$path")"

        if [[ "$target" == /* ]]; then
            path="$target"
        else
            path="${directory}/${target}"
        fi
    done

    directory="$(
        cd -P "$(dirname "$path")" >/dev/null 2>&1 &&
        pwd
    )"

    printf '%s/%s\n' "$directory" "$(basename "$path")"
}

ensure_cli_directory() {
    local install_directory="$1"

    if [[ -d "$install_directory" ]]; then
        return 0
    fi

    if mkdir -p "$install_directory" 2>/dev/null; then
        return 0
    fi

    if command -v sudo >/dev/null 2>&1 &&
        sudo mkdir -p "$install_directory"; then
        return 0
    fi

    output_error "Não foi possível criar o diretório da CLI:"
    echo "  ${install_directory}"

    return 1
}

create_cli_link() {
    local source_file="$1"
    local target_file="$2"

    if ln -s "$source_file" "$target_file" 2>/dev/null; then
        return 0
    fi

    if command -v sudo >/dev/null 2>&1 &&
        sudo ln -s "$source_file" "$target_file"; then
        return 0
    fi

    return 1
}

replace_cli_link() {
    local source_file="$1"
    local target_file="$2"

    if ln -sfn "$source_file" "$target_file" 2>/dev/null; then
        return 0
    fi

    if command -v sudo >/dev/null 2>&1 &&
        sudo ln -sfn "$source_file" "$target_file"; then
        return 0
    fi

    return 1
}

install_cli() {
    local source_file="${ROOT_DIR}/coruja"
    local install_directory="${CORUJA_CLI_DIR:-/usr/local/bin}"
    local target_file="${install_directory}/coruja"
    local resolved_source
    local resolved_target
    local confirmation="n"

    output_step "Instalando a CLI Coruja..."

    if [[ ! -f "$source_file" ]]; then
        output_error "Arquivo da CLI não encontrado:"
        echo "  ${source_file}"
        return 1
    fi

    if [[ ! -x "$source_file" ]]; then
        if chmod +x "$source_file"; then
            output_success "Permissão de execução aplicada à CLI"
        else
            output_error "Não foi possível tornar a CLI executável"
            return 1
        fi
    fi

    if ! ensure_cli_directory "$install_directory"; then
        return 1
    fi

    resolved_source="$(resolve_cli_path "$source_file")"

    if [[ -L "$target_file" ]]; then
        resolved_target="$(resolve_cli_path "$target_file")"

        if [[ "$resolved_target" == "$resolved_source" ]]; then
            output_success "CLI já instalada corretamente"
            output_info "${target_file}"
            return 0
        fi

        output_warning "Já existe outro link para o comando coruja"
        echo "  Atual: ${resolved_target}"
        echo "  Novo:  ${resolved_source}"
        echo

        if ! read -r -p "Substituir o link existente? [s/N] " confirmation; then
            confirmation="n"
        fi

        if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
            output_warning "Instalação da CLI mantida sem alterações"
            return 0
        fi

        if replace_cli_link "$source_file" "$target_file"; then
            output_success "Link da CLI atualizado"
            output_info "${target_file}"
            return 0
        fi

        output_error "Não foi possível atualizar o link da CLI"
        return 1
    fi

    if [[ -e "$target_file" ]]; then
        output_warning "Já existe um arquivo em:"
        echo "  ${target_file}"
        echo

        if ! read -r -p "Substituir o arquivo existente? [s/N] " confirmation; then
            confirmation="n"
        fi

        if [[ ! "$confirmation" =~ ^[sS]$ ]]; then
            output_warning "Instalação da CLI mantida sem alterações"
            return 0
        fi

        if rm -f "$target_file" 2>/dev/null ||
            sudo rm -f "$target_file"; then
            if create_cli_link "$source_file" "$target_file"; then
                output_success "CLI instalada"
                output_info "${target_file}"
                return 0
            fi
        fi

        output_error "Não foi possível substituir o arquivo existente"
        return 1
    fi

    if create_cli_link "$source_file" "$target_file"; then
        output_success "CLI instalada"
        output_info "${target_file}"
        return 0
    fi

    output_error "Não foi possível instalar a CLI"
    return 1
}