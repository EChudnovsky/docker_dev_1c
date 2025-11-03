#!/usr/bin/env bash

# Максимальное время выполнения в секундах
# if [[ -n ${EDT_MAXTIMEOUT} ]] ; then
#     alias_str+=("-timeout ${EDT_MAXTIMEOUT}")
# fi

# if [[ -n ${EDT_VMARGS} ]] ; then
#     alias_str+=("-vmargs ${EDT_VMARGS}")
# fi
# alias_str=("1cedtcli")
# if [[ -n ${EDT_PATH_WORKSPACE} ]] ; then
#     alias_str+=("-data ${EDT_PATH_WORKSPACE}")
# else
#     echo "Не задан путь для переменной \${EDT_PATH_WORKSPACE}. Операция прервана"
#     exit 1
# fi

# IFS=' ' # разделитель
# alias cliedt='${alias_str[*]}'

cli_edt_run_script_file() {
    
    if [ $# -eq 0 ]; then
        echo "Не передан путь к скрипту. Операция прервана"
        return 1
    fi

    cliedt -file "$1"
}

cli_edt_build() {
    
    cliedt -command build "$@"
}
cli_edt_cd() {
    
    cliedt -command cd "$@"
}
cli_edt_clean-up-source() {
    
    cliedt -command clean-up-source --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"
}
cli_edt_delete() {
    
    cliedt -command delete "$@"
}

cli_edt_export() {
    
    cliedt -command export --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"
}

cli_edt_format-modules() {
    
    cliedt -command format-modules --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"
}
cli_edt_help() {
    
    cliedt -command help "$@"
}
cli_edt_import() {
    
    cliedt -command import --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"
}
cli_edt_infobase() {
    
    cliedt -command infobase "$@" 
}
cli_edt_infobase-create() {
    
    if [ -z "${_1C_DB_PATH_CF}" ]; then
        cliedt -command infobase-create --name "${DB_NAME}" --path "${_1C_DB_PATH}" --version "${DB_VERSION}"
    el
        cliedt -command infobase-create --name "${DB_NAME}" --path "${_1C_DB_PATH}" --version "${DB_VERSION}" --cf "${_1C_DB_PATH_CF}"
    fi

}
cli_edt_infobase-delete() {
    
    cliedt -command infobase-delete --name "${DB_NAME}" "$@" 
}
cli_edt_infobase-import() {
    
    cliedt -command infobase-import --name "${DB_NAME}" --project-name "${CI_PROJECT_NAME}" "$@" 
}
cli_edt_install-platform-support() {
    
    cliedt -command install-platform-support --version "${DB_VERSION}"
}
cli_edt_platform-versions() {
    
    cliedt -command platform-versions
}
cli_edt_project() {
    
    cliedt -command project "$@" 
}
cli_edt_script() {
    
    cliedt -command script "$@"
}
cli_edt_sort-project() {
    
    cliedt -command sort-project --project-list ["${EDT_PATH_PROJECT}"]
}
cli_edt_uninstall-platform-support() {
    
    cliedt -command uninstall-platform-support --version "${DB_VERSION}"
}
cli_edt_validate() {
    
    cliedt -command validate --file "${PROJECT_LOG_DIR}\validation-result.tsv" --project-list ["${EDT_PATH_PROJECT}"]
}
cli_edt_version() {
    
    cliedt -command version "$@"
}