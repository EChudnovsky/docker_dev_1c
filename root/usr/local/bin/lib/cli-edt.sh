#!/usr/bin/env bash

# Вывод справки
is_show_help=false
h_description=

# СЛУЖЕБНЫЕ ФУНКЦИИ

function show_help_edt() {
    is_show_help=false
    local h_command_name=
    for (( i=${#FUNCNAME[@]}-1; i>=0 ; i-- ))
    do 
        h_command_name="${FUNCNAME[$i]}"
        if [[ ${h_command_name} = *"cli_"* ]] && [[ "${h_command_name}" != *"show_help_edt"* ]]; then
            break
        else
            h_command_name=""
        fi
    done

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) is_show_help=true;;
            *) params+=("$1");;

        esac
        shift
    done

    if [[ "$is_show_help" = true ]]; then
        h_command_name=$(echo "${h_command_name}" | sed 's/cli_edt_//')
echo "
${h_command_name}(1)    Пользовательские команды EDT    ${h_command_name}(1)

ОПИСАНИЕ
${h_description}
"
        cliedt -command help ${h_command_name}
    fi

}

function cliedt(){

    # Определение ALIAS
    local params=()
    if [[ -n ${EDT_PATH_WORKSPACE} ]] ; then
        params+=("-data ${EDT_PATH_WORKSPACE}")
    else
        echo "Не задан путь для переменной \${EDT_PATH_WORKSPACE}. Операция прервана"
        exit 1
    fi
    # Максимальное время выполнения в секундах
    if [[ -n ${EDT_MAXTIMEOUT} ]] ; then
        params+=("-timeout ${EDT_MAXTIMEOUT}")
    fi

    if [[ -n ${EDT_VMARGS} ]] ; then
        params+=("-vmargs ${EDT_VMARGS}")
    fi
    params+=("$@")

    IFS=' ' # разделитель
    strparams="${params[*]}"

    1cedtcli $strparams
}

# ОБЩИЕ ФУНКЦИИ

cli_edt_version() {

    # Обработка параметров и вывод help
    h_description="
    Выводит версию 1С:EDT или список установленных компонентов с версиями или версию выбранного компонента."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command version "$@"

}

cli_edt_cd() {

    # Обработка параметров и вывод help
    h_description="
    Отображает или изменяет текущий рабочий каталог"

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command cd "$@"
}

cli_edt_help() {

    # Обработка параметров и вывод help
    h_description="
    Выводит список доступных команд или кодов возврата."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    local params=$(echo "${@}" | sed 's/cli_edt_//')
    cliedt -command help "$params"

}

cli_edt_platform-versions() {

    # Обработка параметров и вывод help
    h_description="
    Сообщает список версий платформы «1С:Предприятие», которые поддерживаются данной средой разработки."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command platform-versions

}

cli_edt_install-platform-support() {

    # Обработка параметров и вывод help
    h_description="
    Устанавливает поддержку платформы «1С:Предприятие» указанной версии.
    При вызове команды без параметров будет установлена версия платформы из переменной \${_1C_VERSION}."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    local params=
    if [[ -z "${@}" ]]; then
        params="--version ${_1C_VERSION}"
    else
        params="${@}"
    fi

    cliedt -command install-platform-support ${params}

}

cli_edt_uninstall-platform-support() {

    # Обработка параметров и вывод help
    h_description="
    Удаляет поддержку платформы «1С:Предприятие» указанной версии.
    При вызове команды без параметров будет установлена версия платформы из переменной \${_1C_VERSION}."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    local params=
    if [[ -z "${@}" ]]; then
        params="--version ${_1C_VERSION}"
    else
        params="${@}"
    fi
    cliedt -command uninstall-platform-support ${params}

}

# РАБОТА С ПРОЕКТАМИ EDT

cli_edt_project() {

    # Обработка параметров и вывод help
    h_description="
    Выводит информацию по всем или по нескольким проектам."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    local params=
    if [[ -z "${@}" ]]; then
        params="--details true [${CI_PROJECT_NAME}]"
    else
        params="${@}"
    fi

    cliedt -command project "$@" 

}

cli_edt_build() {

    # Обработка параметров и вывод help
    h_description="
    Очищает и пересобирает все или некоторые проекты.
    Является аналогом интерактивной команды Проект > Очистить..."
    
    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command build "$@"
}
cli_edt_clean-up-source() {

    # Обработка параметров и вывод help
    h_description="
    Оптимизирует формат хранения данных проекта."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command clean-up-source --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

}
cli_edt_delete() {

    # Обработка параметров и вывод help
    h_description="
    Удаляет все или некоторые проекты."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command delete "$@"

}

cli_edt_export() {

    # Обработка параметров и вывод help
    h_description="
    Экспортирует проект 1C:EDT в .xml-файлы конфигурации."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command export --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

}

cli_edt_format-modules() {

    # Обработка параметров и вывод help
    h_description="
    Форматирует все модули встроенного языка в соответствии с настройками форматирования."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command format-modules --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

}

cli_edt_import() {

    # Обработка параметров и вывод help
    h_description="
    1. Импортирует проект 1C:EDT в рабочую область.
    2. Импортирует .xml-файлы конфигурации в проект 1C:EDT. "

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command import --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

}

cli_edt_infobase() {

    # Обработка параметров и вывод help
    h_description="
    Показывает список информационных баз и информацию о выбранных базах."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command infobase "$@" 

}
cli_edt_infobase-create() {

    # Обработка параметров и вывод help
    h_description="
    Создает информационную базу."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    if [ -z "${_1C_DB_PATH_CF}" ]; then
        cliedt -command infobase-create --name "${DB_NAME}" --path "${_1C_DB_PATH}" --version "${DB_VERSION}"
    el
        cliedt -command infobase-create --name "${DB_NAME}" --path "${_1C_DB_PATH}" --version "${DB_VERSION}" --cf "${_1C_DB_PATH_CF}"
    fi

}

cli_edt_infobase-delete() {

    # Обработка параметров и вывод help
    h_description="
    Удаляет одну или несколько информационных баз."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command infobase-delete --name "${DB_NAME}" "$@" 

}

cli_edt_infobase-import() {

    # Обработка параметров и вывод help
    h_description="
    Импортирует информационную базу в проект. "

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command infobase-import --name "${DB_NAME}" --project-name "${CI_PROJECT_NAME}" "$@" 

}

cli_edt_script() {

    # Обработка параметров и вывод help
    h_description="
    Выводит список доступных скриптов, показывает информацию о скрипте, загружает один или несколько скриптов."
    
    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command script "$@"

}

cli_edt_sort-project() {

    # Обработка параметров и вывод help
    h_description="
    Сортирует объекты конфигурации в соответствии с настройками автоматической сортировки.
    Если автоматическая сортировка не была включена для проекта, будут установлены стандартные настройки автоматической сортировки,
    в соответствии с которыми объекты конфигурации будут отсортированы."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command sort-project --project-list ["${EDT_PATH_PROJECT}"]

}


cli_edt_validate() {

    # Обработка параметров и вывод help
    h_description="
    Проверяет проект и выводит результат в .tsv-файл."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -command validate --file "${PROJECT_LOG_DIR}\validation-result.tsv" --project-list ["${EDT_PATH_PROJECT}"]

}

cli_edt_run_script_file() {
    
    # Обработка параметров и вывод help
    h_description=
    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    cliedt -file "$1"
}

cli_edt_project