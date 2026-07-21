#!/usr/bin/env bash

show_getting_started() {
    local option
    local project_name

    output_step "Primeiros passos"

    echo "[1] Encerrar"
    echo "[2] Criar primeiro projeto"
    echo "[3] Ver próximos comandos"
    echo

    if ! read -r -p "Escolha uma opção [1]: " option; then
        option="1"
    fi

    option="${option:-1}"

    case "$option" in
        1)
            output_info "Instalação encerrada"
            ;;

        2)
            if ! read -r -p "Nome do projeto: " project_name; then
                project_name=""
            fi

            if [[ -z "$project_name" ]]; then
                output_warning "Nome do projeto não informado"
                return 0
            fi

            output_info "Criando projeto '${project_name}'..."

            if run_cli new "$project_name"; then
                output_success "Projeto criado com sucesso"
                output_info "Acesse: https://${project_name}.localhost"
                return 0
            fi

            output_error "Não foi possível criar o projeto"
            return 0
            ;;

        3)
            echo
            echo "Comandos principais:"
            echo "  coruja up"
            echo "  coruja down"
            echo "  coruja doctor"
            echo "  coruja projects"
            echo "  coruja new meu-projeto"
            ;;

        *)
            output_warning "Opção inválida. Instalação encerrada."
            ;;
    esac
}