#!/usr/bin/env bash

OPERATING_SYSTEM=""
IS_WSL=false

detect_system() {

    case "$(uname -s)" in

        Darwin)

            OPERATING_SYSTEM="macOS"
            ;;

        Linux)

            OPERATING_SYSTEM="Linux"

            if grep -qi microsoft /proc/version 2>/dev/null; then
                OPERATING_SYSTEM="WSL"
                IS_WSL=true
            fi
            ;;

        *)

            echo "Sistema operacional não suportado."

            exit 1
            ;;

    esac

    echo "Sistema detectado: ${OPERATING_SYSTEM}"

}