#!/usr/bin/env bash

# Вывод справки
is_show_help=false
h_description=
h_command_name=
g_code=

# СЛУЖЕБНЫЕ ФУНКЦИИ

function show_help_edt() {

    is_show_help=false
    h_command_name=""

    for (( i=${#FUNCNAME[@]}-1; i>=0 ; i-- ))
    do 
        h_command_name="${FUNCNAME[$i]}"
        if [[ ${h_command_name} = *"cli-"* ]] && [[ "${h_command_name}" != *"show_help_edt"* ]]; then
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
        h_command_name=$(echo "${h_command_name}" | sed 's/cli-edt-//')
echo "
${h_command_name}(1)    Пользовательские команды EDT    ${h_command_name}(1)

ОПИСАНИЕ
${h_description}
"
        cliedt -command help ${h_command_name}
    fi
    
    # очистка заголовка для следующих команд
    h_description=""    

}

# НАЧАЛО. ВЫВОД В КОНСОЛЬ

function print_log() {
    #  $1 - Текст сообщения
    #  $2 - Если 0 = успех иначе 0 <> Код ошибки
    #  $3 - Если не пустой вызывает исключение с кодом ошибки

    local l_code=0
    
    # Передан код числом
    [[ "$2" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] && l_code=$2 
    # Передан признак
    [[ "$2" == "true" ]]  && l_code=1

    if [ "$l_code" -ne 0 ]; then
        echo -e "[ERROR] $1. Код ошибки: ($l_code)" >&2
        if [ ! -z "$3" ]; then
            exit $l_code
        fi
    else
        echo -e "[INFO] $1"
    fi
}

function print_start_command(){
    g_code=0
    print_log "НАЧАЛО. Команда: $h_command_name. \n ${h_description}"
}

function print_end_command(){
    print_log  "ОКОНЧАНИЕ.  Команда: $h_command_name" $g_code "true"
}

# КОНЕЦ. ВЫВОД В КОНСОЛЬ

сreate_catalog() {
    
    local value=$1
    
    [ -z "$value" ] && print_log "Передан пустой путь каталога для создания" 1 "true"
    
    # Пересоздавать каталог
    if [ -d "$value" ]; then
        [[ "$2" == "true" ]]  && rm -f -r ${value}/* || print_log "Не удалось очистить каталог: $value" 1 "true"
    else
        mkdir -p "$value" || print_log "Ошибка создания каталога: $value" 1 "true"
    fi
    
    print_log "Создан каталог: $value"
}


function cliedt(){
    
    local resualt=
    g_code=0

    [[ -z ${EDT_PATH_WORKSPACE} ]] && print_log  "Не задан путь для переменной \${EDT_PATH_WORKSPACE}. Операция прервана" 1 "true"
    
    local params=()
    params+=("-data ${EDT_PATH_WORKSPACE}")

    # Максимальное время выполнения в секундах
    [[ -n ${EDT_MAXTIMEOUT} ]] && params+=("-timeout ${EDT_MAXTIMEOUT}")
    [[ -n ${EDT_VMARGS} ]] && params+=("-vmargs ${EDT_VMARGS}")
    
    params+=("$@")

    IFS=' ' # разделитель
    strparams="${params[*]}"
    
    IFS=$'\n'    
    resualt="$(1cedtcli $strparams)"
    
    g_code=$?
    if [[ -z "$g_code" || $g_code -eq 0 ]]; then
        case "$resualt" in
            *"успешно завершено"*) g_code=0;;
            *"Не удалось запустить 1C:EDT CLI"*) g_code=1;;
            *"код ошибки*") g_code=1;;
            *) g_code=0:;;
        esac
    fi

    # for l_msg in $resualt; do
    #     if [[ "$l_msg" = *"код ошибки"* ]]; then
    #         g_code=1
    #     elif [[ "$l_msg" = *"Не удалось запустить 1C:EDT CLI"* ]]; then
    #         g_code=1
    #     elif [[ "$l_msg" = *"успешно завершено"* ]]; then
    #         g_code=0
    #     fi
    # done
    
    echo "$resualt"

}

# ПРОГРАММНЫЙ ИНТЕРФЕЙС

cli-edt-version() {

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

cli-edt-cd() {

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

cli-edt-help() {

    # Обработка параметров и вывод help
    h_description="
    Выводит список доступных команд или кодов возврата."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    local params=$(echo "${@}" | sed 's/cli-edt-//')
    cliedt -command help "$params"

}

cli-edt-platform-versions() {

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

cli-edt-install-platform-support() {

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

    h_description="Установка поддержки версии платформы 
    Параметры: $params"
    
    print_start_command
    
    cliedt -command install-platform-support ${params}

    print_end_command

}

cli-edt-uninstall-platform-support() {

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

    h_description="Удаление поддержки версии платформы 
    Параметры: $params"

    print_start_command
    
    cliedt -command uninstall-platform-support ${params}
    
    print_end_command

}

# РАБОТА С ПРОЕКТАМИ EDT

cli-edt-project() {

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
    
    local result=$(cliedt -command project "$@")

    [ -z "$result" ] && result="<Нет сведений о проектах>"
    
    print_log "$result" "$g_code" "true"

}

# РАБОТА С БАЗОЙ

cli-edt-infobase-create() {

    # Обработка параметров и вывод help
    h_description="
    Создает информационную базу."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Создание информационной базы"
    print_start_command

    local params=""
    if [[ -n "${_1C_DB_PATH_CF_LOAD}" ]]; then
    
        print_log "из конфигурационного файла
    PATH_CF: ${_1C_DB_PATH_CF_LOAD}
    DB_NAME: ${_1C_DB_NAME}
    DB_PATH: ${_1C_DB_PATH}"

        [[ ! -f ${_1C_DB_PATH_CF_LOAD} ]] && print_log "Не удалось найти файл для загрузки. Операция прервана" "true" "true"
        params=-cf "${_1C_DB_PATH_CF_LOAD}"
        
    else

    print_log "пустой базы
    DB_NAME: ${_1C_DB_NAME}
    DB_PATH: ${_1C_DB_PATH}"

    fi

    сreate_catalog ${_1C_DB_PATH} true

    cliedt -command infobase-create --name "${_1C_DB_NAME}" --path "${_1C_DB_PATH}" --version "${_1C_VERSION}" ${params}

    print_end_command

}

cli-edt-build() {

    # Обработка параметров и вывод help
    h_description="
    Очищает и пересобирает все или некоторые проекты.
    Является аналогом интерактивной команды Проект > Очистить..."
    
    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Очистка и пересбор проекта"
    print_start_command

    cliedt -command build "$@"

    print_end_command

}

cli-edt-clean-up-source() {

    # Обработка параметров и вывод help
    h_description="
    Оптимизирует формат хранения данных проекта."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Оптимизация формата хранения"
    print_start_command

    cliedt -command clean-up-source --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

    print_end_command

}

cli-edt-delete() {

    # Обработка параметров и вывод help
    h_description="
    Удаляет все или некоторые проекты."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Удаление проекта"
    print_start_command

    cliedt -command delete "$@"

    print_end_command

}

cli-edt-export() {

    # Обработка параметров и вывод help
    h_description="
    Экспортирует проект 1C:EDT в .xml-файлы конфигурации."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Экспортиру проекта 1C:EDT в .xml-файлы конфигурации"
    print_start_command

    cliedt -command export --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

    print_end_command

}

cli-edt-format-modules() {

    # Обработка параметров и вывод help
    h_description="
    Форматирует все модули встроенного языка в соответствии с настройками форматирования."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Форматирование модулей встроенного языка проекта EDT"
    print_start_command

    cliedt -command format-modules --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

    print_end_command

}

cli-edt-import() {

    # Обработка параметров и вывод help
    h_description="
    1. Импортирует проект 1C:EDT в рабочую область.
    2. Импортирует .xml-файлы конфигурации в проект 1C:EDT. "

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Импортирование проекта EDT"
    print_start_command

    cliedt -command import --project-name "${CI_PROJECT_NAME}" --project "${EDT_PATH_PROJECT}" "$@"

    print_end_command

}

cli-edt-infobase() {

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

cli-edt-infobase-delete() {

    # Обработка параметров и вывод help
    h_description="
    Удаляет одну или несколько информационных баз."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Удаление информационной базы"
    print_start_command

    cliedt -command infobase-delete --name "${_1C_DB_NAME}" "$@" 

    print_end_command

}

cli-edt-infobase-import() {

    # Обработка параметров и вывод help
    h_description="
    Импортирует информационную базу в проект. "

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Импортирование информационной базы в проект"
    print_start_command

    cliedt -command infobase-import --name "${_1C_DB_NAME}" --project-name "${CI_PROJECT_NAME}" "$@" 

    print_end_command

}

cli-edt-script() {

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

cli-edt-sort-project() {

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
    h_description="Сортировка объектов конфигурации"
    print_start_command

    cliedt -command sort-project --project-list ["${EDT_PATH_PROJECT}"]
    
    print_end_command

}


cli-edt-validate() {

    # Обработка параметров и вывод help
    h_description="
    Проверяет проект и выводит результат в .tsv-файл."

    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Проверка проекта и выводит результат в .tsv-файл "
    print_start_command

    cliedt -command validate --file "${PROJECT_LOG_DIR}\validation-result.tsv" --project-list ["${EDT_PATH_PROJECT}"]
    
    print_end_command

}

cli-edt-run_script_file() {
    
    # Обработка параметров и вывод help
    h_description=
    show_help_edt "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    h_description="Выполнение скрипта EDT из файла"
    print_start_command

    cliedt -file "$1"

    print_end_command
    
}

# cli-edt-infobase-create