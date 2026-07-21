#!/usr/bin/env bash

INSTALLER_SSL_READY=false
INSTALLER_SSL_TRUSTED=false

prepare_local_certificates() {
    local certificates_dir="${ROOT_DIR}/certs"
    local certificate_file="${certificates_dir}/localhost.pem"
    local certificate_key_file="${certificates_dir}/localhost-key.pem"

    output_step "Preparando HTTPS local"

    mkdir -p "$certificates_dir"

    if [[ -f "$certificate_file" && -f "$certificate_key_file" ]]; then
        output_success "Certificados locais já existem"
        output_info "${certificate_file}"

        INSTALLER_SSL_READY=true

        check_certificate_trust
        return 0
    fi

    if ! command -v mkcert >/dev/null 2>&1; then
        output_warning "mkcert não encontrado"
        show_mkcert_installation_help
        return 0
    fi

    output_info "Instalando a autoridade certificadora local..."

    if mkcert -install; then
        INSTALLER_SSL_TRUSTED=true
        output_success "Autoridade certificadora local instalada"
    else
        output_warning "Não foi possível instalar automaticamente a autoridade certificadora"
    fi

    output_info "Gerando certificado para localhost e subdomínios..."

    if ! mkcert \
        -cert-file "$certificate_file" \
        -key-file "$certificate_key_file" \
        "localhost" \
        "*.localhost" \
        "127.0.0.1" \
        "::1"
    then
        output_error "Não foi possível gerar os certificados locais"

        rm -f \
            "$certificate_file" \
            "$certificate_key_file"

        return 0
    fi

    chmod 600 "$certificate_key_file"
    chmod 644 "$certificate_file"

    INSTALLER_SSL_READY=true

    output_success "Certificados locais gerados"
    output_info "${certificate_file}"

    check_certificate_trust
}

check_certificate_trust() {
    if ! command -v mkcert >/dev/null 2>&1; then
        return 0
    fi

    if [[ "${OPERATING_SYSTEM}" == "WSL" ]]; then
        install_wsl_ca_in_windows
        return 0
    fi

    INSTALLER_SSL_TRUSTED=true
}

show_mkcert_installation_help() {
    echo
    echo "O HTTPS requer o mkcert."
    echo

    case "${OPERATING_SYSTEM}" in
        macOS)
            echo "Instale com:"
            echo "  brew install mkcert"
            echo "  brew install nss"
            ;;

        WSL)
            echo "No Ubuntu/WSL, instale com:"
            echo "  sudo apt update"
            echo "  sudo apt install -y mkcert libnss3-tools"
            ;;

        Linux)
            echo "No Ubuntu/Debian, instale com:"
            echo "  sudo apt update"
            echo "  sudo apt install -y mkcert libnss3-tools"
            ;;

        *)
            echo "Instale o mkcert e execute novamente o instalador."
            ;;
    esac

    echo
    echo "Depois execute novamente:"
    echo "  ./install.sh"
}

install_wsl_ca_in_windows() {
    local ca_root
    local ca_file
    local windows_ca_file

    ca_root="$(mkcert -CAROOT 2>/dev/null || true)"
    ca_file="${ca_root}/rootCA.pem"

    if [[ -z "$ca_root" || ! -f "$ca_file" ]]; then
        output_warning "Autoridade certificadora local não encontrada"
        show_wsl_certificate_notice
        return 0
    fi

    if ! command -v wslpath >/dev/null 2>&1; then
        output_warning "wslpath não está disponível"
        show_wsl_certificate_notice
        return 0
    fi

    if ! command -v certutil.exe >/dev/null 2>&1; then
        output_warning "certutil.exe não está acessível pelo WSL"
        show_wsl_certificate_notice
        return 0
    fi

    windows_ca_file="$(wslpath -w "$ca_file")"

    echo
    echo "Para que Chrome, Edge e outros aplicativos do Windows"
    echo "confiem nos projetos locais, a CA do mkcert precisa ser"
    echo "adicionada ao repositório de certificados do usuário."
    echo
    echo "Certificado:"
    echo "  ${windows_ca_file}"
    echo

    if ! ask_confirmation \
        "Deseja instalar a CA local no Windows agora?"
    then
        output_warning "Importação da CA no Windows ignorada"
        show_wsl_certificate_notice
        return 0
    fi

    output_info "Importando CA no repositório do usuário do Windows..."

    if certutil.exe \
        -user \
        -addstore \
        Root \
        "$windows_ca_file" \
        >/dev/null
    then
        INSTALLER_SSL_TRUSTED=true
        output_success "CA local instalada no Windows"
        return 0
    fi

    output_warning "Não foi possível importar automaticamente a CA no Windows"
    show_wsl_certificate_notice
}

show_wsl_certificate_notice() {
    local ca_root
    local ca_file

    ca_root="$(mkcert -CAROOT 2>/dev/null || true)"
    ca_file="${ca_root}/rootCA.pem"

    output_warning "O certificado foi criado dentro do WSL"

    echo
    echo "O navegador executado no Windows também precisa confiar na CA local."

    if [[ -f "$ca_file" ]]; then
        echo
        echo "CA local:"
        echo "  ${ca_file}"

        if command -v wslpath >/dev/null 2>&1; then
            echo
            echo "Caminho no Windows:"
            echo "  $(wslpath -w "$ca_file")"
        fi
    fi

    echo
    echo "Para importar manualmente no Windows:"
    echo
    echo "  certutil -user -addstore Root \"CAMINHO_DA_CA\""
    echo
    echo "Feche e abra novamente o navegador após a importação."
}