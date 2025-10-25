#!/usr/bin/env bash

# Вывод справки
is_show_help=false
h_command_name=
h_description=
h_description_full=
h_syntax=
h_list_option=
h_list_arg=
h_examples=

function cli_show_help() {
    is_show_help=false
    h_command_name=${h_command_name:-${FUNCNAME[1]}}
    h_description=${h_description:-"Нет описания"}
    h_description_full=${h_description_full:-$h_description}
    h_syntax=${h_syntax:-"$h_command_name [ПАРАМЕТРЫ] [АРГУМЕНТЫ]"}
    h_list_option=${h_list_option:-""}
    h_list_arg=${h_list_arg:-"<НЕТ>"}
    h_examples=${h_examples:-"<НЕТ>"}

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help) is_show_help=true;;
            *) params+=("$1");;

        esac
        shift
    done

    if [[ "$is_show_help" = true ]]; then
        cat <<EOF 
${h_command_name}(1)    Пользовательские команды    ${h_command_name}(1)
ИМЯ
    ${h_command_name} - ${h_description}

СИНТАКСИС
    ${h_syntax} 

ОПИСАНИЕ
    ${h_description_full}

ОПЦИИ
    -h, --help          Показать эту справку
    ${h_list_option}

АРГУМЕНТЫ
    ${h_list_arg}

ПРИМЕРЫ
    \$ ${h_command_name} --help
    ${h_examples}

EOF
    fi

}

cli_date_get_current(){
    
    # Обработка параметров и вывод help
    h_description="Возвращает текущую дату"
    h_description_full="Возвращает текущую дату"
    h_syntax="cli_date_get_current [ПАРАМЕТРЫ] [АРГУМЕНТЫ] - формат аргументов соответствует шаблону функции printf "
    h_list_arg="\$1 - строка-шаблон модификкатора функции printf, основные:
    %Y — год (4 цифры)
    %m — месяц (01-12)
    %d — день (01-31)
    %H — час (00-23)
    %M — минуты (00-59)
    %S — секунды (00-59)
    %A — полное название дня недели
    %B — полное название месяца"

    h_examples="
    $ cli_date_get_current \"%a %d %b - %l:%M %p\"
    \"Пт 19 сен -  3:59\""

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    printf "%($1)T\\n" "-1"
    
}

cli_str_uuid() {
    
    # Обработка параметров и вывод help
    h_description="Генерирует uuid"
    h_examples="
    $ cli_str_uuid
    d5b6c731-1310-4c24-9fe3-55d556d44374"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    C="89ab"

    for ((N=0;N<16;++N)); do
        B="$((RANDOM%256))"

        case "$N" in
            6)  printf '4%x' "$((B%16))" ;;
            8)  printf '%c%x' "${C:$RANDOM%${#C}:1}" "$((B%16))" ;;

            3|5|7|9)
                printf '%02x-' "$B"
            ;;

            *)
                printf '%02x' "$B"
            ;;
        esac
    done

    printf '\n'

}

cli_str_trim_string() {

    # Обработка параметров и вывод help
    h_description="Удаляет из строки начальные и конечные пробелы"
    h_list_arg=" \$1 - Обрабатываемая строка"

    h_examples="
    \$ cli_str_trim_string \" Hello, World \"
    Hello, World"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"

}

cli_str_trim_all() {

    # Обработка параметров и вывод help
    h_description="Удаляет из строки все пробелы и сокращает количество пробелов"
    h_list_arg="\$1 - Обрабатываемая строка"

    h_examples="
    $ cli_str_trim_all \" Hello, World \"
    Hello, World"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    set -f
    set -- "$*"
    printf '%s\n' "$*"
    set +f
}

cli_srt_regex() {

    # Обработка параметров и вывод help
    h_description="Применение  регулярного выражение для переданной строки"
    h_list_arg="
    \$1 - Обрабатываемая строка
    \$2 - Строка-шаблон регулярного выражения"

    h_examples="
    $ # Trim leading white-space.
    $ cli_srt_regex '    hello' '^\s*(.*)'
    hello
     
    $ # Validate a hex color.
    $ cli_srt_regex \"#FFFFFF\" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$'
    #FFFFFF
     
    $ # Validate a hex color (invalid).
    $ cli_srt_regex \"red\" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$'
    # no output (invalid)"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"

}

cli_str_split() {

    # Обработка параметров и вывод help
    h_description="Разделяет строку по указанному разделителю"
    h_list_arg="
    \$1 - Обрабатываемая строка
    \$2 - Строка-шаблон разделителя"

    h_examples="
    $ cli_str_split \"apples,oranges,pears,grapes\" \",\"
    apples
    oranges
    pears
    grapes"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
   printf '%s\n' "${arr[@]}"

}

cli_str_lower() {

    # Обработка параметров и вывод help
    h_description="Строка в нижний регистр"
    h_list_arg="
    \$1 - Обрабатываемая строка"

    h_examples="
    $ cli_str_lower \"HELLO\"
    hello"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi

    # Основная логика
    printf '%s\n' "${1,,}"

}

cli_str_upper() {

    # Обработка параметров и вывод help
    h_description="Строка в верний регистр"
    h_list_arg="
    \$1 - Обрабатываемая строка"

    h_examples="
    $ cli_str_upper \"hello\"
    HELLO"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "${1^^}"
}

cli_str_reverse_case() {

    # Обработка параметров и вывод help
    h_description="Обратный регистр строк"
    h_list_arg="
    \$1 - Обрабатываемая строка"

    h_examples="
    $ cli_str_reverse_case \"HeLlO\"
    hElLo"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "${1~~}"

}

cli_str_trim_quotes() {

    # Обработка параметров и вывод help
    h_description="Удаляет из строки кавычки"
    h_list_arg="
    \$1 - Обрабатываемая строка"

    h_examples="
    $ var=\"'Hello', \"World\"\"
    $ cli_str_trim_quotes \"\$var\"
    Hello, World"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    : "${1//\'}"
    printf '%s\n' "${_//\"}"
}

cli_str_strip_all() {

    # Обработка параметров и вывод help
    h_description="Удаляет из строки все вхождения шаблона"
    h_list_arg="
    \$1 - Обрабатываемая строка
    \$2 - Строка-шаблон"

    h_examples="
    $ cli_str_strip_all \"The Quick Brown Fox\" \"[aeiou]\"
    Th Qck Brwn Fx
    
    $ cli_str_strip_all \"The Quick Brown Fox\" \"[[:space:]]\"
    TheQuickBrownFox
    
    $ cli_str_strip_all \"The Quick Brown Fox\" \"Quick \"
    The Brown Fox"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "${1//$2}"
    
}

cli_str_strip() {
    
    # Обработка параметров и вывод help
    h_description="Удаляет из строки первое вхождение из шаблона"
    h_list_arg="
    \$1 - Обрабатываемая строка
    \$2 - Строка-шаблон"

    h_examples="
    $ cli_str_strip \"The Quick Brown Fox\" \"[aeiou]\"
    Th Quick Brown Fox
    
    $ cli_str_strip \"The Quick Brown Fox\" \"[[:space:]]\"
    TheQuick Brown Fox"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "${1/$2}"

}

cli_str_lstrip() {

    # Обработка параметров и вывод help
    h_description="Возвращает строку с начала от слово шаблона исключения"
    h_list_arg="
    \$1 - Обрабатываемая строка
    \$2 - Строка-шаблон"

    h_examples="
    $ cli_str_lstrip \"The Quick Brown Fox\" \"The \"
    Quick Brown Fox"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "${1##"$2"}"
}

cli_str_rstrip() {

    # Обработка параметров и вывод help
    h_description="Возвращает строку с конца от слово шаблона исключения"
    h_list_arg="
    \$1 - Обрабатываемая строка
    \$2 - Строка-шаблон"

    h_examples="
    $ cli_str_rstrip \"The Quick Brown Fox\" \" Fox\"
    The Quick Brown"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "${1%%"$2"}"

}

cli_str_urlencode() {

    # Обработка параметров и вывод help
    h_description="Нормализация строки для url (процентное кодирование)"
    h_list_arg="
    \$1 - Обрабатываемая строка"

    h_examples="
    $ cli_str_urlencode \"https://github.com/dylanaraps/pure-bash-bible\"
    https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    local LC_ALL=C
    for (( i = 0; i < ${#1}; i++ )); do
        : "${1:i:1}"
        case "$_" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$_"
            ;;

            *)
                printf '%%%02X' "'$_"
            ;;
        esac
    done
    printf '\n'

}

cli_str_urldecode() {

    # Обработка параметров и вывод help
    h_description="Декодирование строки, закодированной в процентах"
    h_list_arg="
    \$1 - Обрабатываемая строка"

    h_examples="
    $ cli_str_urldecode \"https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible\"
    https://github.com/dylanaraps/pure-bash-bible"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    : "${1//+/ }"
    printf '%b\n' "${_//%/\\x}"

}

cli_array_reverse() {
    
    # Обработка параметров и вывод help
    h_description="Возвращет массив в обратном порядке"
    h_list_arg="
    \$1 - Обрабатываемый массив"

    h_examples="
    $ cli_array_reverse 1 2 3 4 5
    5
    4
    3
    2
    1"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    shopt -s extdebug
    f()(printf '%s\n' "${BASH_ARGV[@]}"); f "$@"
    shopt -u extdebug

}

cli_array_remove_dups() {

    # Обработка параметров и вывод help
    h_description="Удалет повторяющиеся элементы в массиве"
    h_list_arg="
    \$1 - Обрабатываемый массив"
    
    h_examples="
    $ cli_array_remove_dups 1 1 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 5
    1
    2
    3
    4
    5
     
    $ arr=(red red green blue blue)
    $ cli_array_remove_dups \"\${arr[@]}\"
    red
    green
    blue"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    declare -A tmp_array

    for i in "$@"; do
        [[ $i ]] && IFS=" " tmp_array["${i:- }"]=1
    done

    printf '%s\n' "${!tmp_array[@]}"
}

cli_array_random_element() {

    # Обработка параметров и вывод help
    h_description="Возвращет случайный элемент массива"
    h_list_arg="
    \$1 - Обрабатываемый массив"

    h_examples="
    $ array=(red green blue yellow brown)
    $ cli_array_random_element \"\${array[@]}\"
    yellow
     
    $ # Multiple arguments can also be passed.
    $ cli_array_random_element 1 2 3 4 5 6 7
    3"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    local arr=("$@")
    printf '%s\n' "${arr[RANDOM % $#]}"
}

cli_file_head() {

    # Обработка параметров и вывод help
    h_description="Получает первые N строк файла"
    h_list_arg="
    \$1 - Количество возвращаемых строк
    \$2 - Путь к файлу"

    h_examples="
    $ cli_file_head 2 ~/.bashrc
    Prompt
    PS1='➜ '"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    mapfile -tn "$1" line < "$2"
    printf '%s\n' "${line[@]}"
}

cli_file_tail() {

    # Обработка параметров и вывод help
    h_description="Получает последние N строк файла"
    h_list_arg="
    \$1 - Количество возвращаемых строк
    \$2 - Путь к файлу"

    h_examples="
    $ cli_file_tail 2 ~/.bashrc
    # Enable tmux.
    # [[ -z \"$TMUX\" ]] && exec tmux"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    mapfile -tn 0 line < "$2"
    printf '%s\n' "${line[@]: -$1}"

}

cli_file_lines() {

    # Обработка параметров и вывод help
    h_description="Возвращает количество строк в файле"
    h_list_arg="
    \$1 - Путь к файлу"

    h_examples="
    $ cli_file_lines ~/.bashrc
    48"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    mapfile -tn 0 lines < "$1"
    printf '%s\n' "${#lines[@]}"

}

cli_file_count() {

    # Обработка параметров и вывод help
    h_description="Подсчитывает количество файлов или каталогов в указанном каталоге"
    h_list_arg="
    \$1 - Путь к обрабатываемому каталогу"

    h_examples="
    # Count all files in dir.
    $ cli_file_count ~/Downloads/*
    232
      
    # Count all dirs in dir.
    $ cli_file_count ~/Downloads/*/
    45
     
    # Count all jpg files in dir.
    $ cli_file_count ~/Pictures/*.jpg
    64"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%s\n' "$#"
}

cli_file_extract() {

    # Обработка параметров и вывод help
    h_description="Возвращает строки файла извлеченные между двумя маркерами"
    h_list_arg="
    \$1 - Путь к обрабатываемому каталогу
    \$2 - Строка-маркер начало блока
    \$3 - Строка-маркер конца блока"

    h_examples="
    # Extract code blocks from MarkDown file.
    $ cli_file_extract ~/projects/pure-bash/README.md '\`\`\`sh' '\`\`\`'
    # Output here..."

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    while IFS=$'\n' read -r line; do
        [[ $extract && $line != "$3" ]] &&
            printf '%s\n' "$line"

        [[ $line == "$2" ]] && extract=1
        [[ $line == "$3" ]] && extract=
    done < "$1"

}

cli_file_get_functions_stript() {

    # Обработка параметров и вывод help
    h_description="Возвращает список функций из файла скрипта"
    h_list_arg="
    \$1 - Путь к обрабатываемому файлу"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика

    IFS=$'\n' read -d "" -ra functions < <(declare -F)
    printf '%s\n' "${functions[@]//declare -f }"
}

cli_path_dirname() {

    # Обработка параметров и вывод help
    h_description="Возвращает имя каталога, в котором указан путь к файлу"
    h_list_arg="
    \$1 - Путь к обрабатываемому файлу"

    h_examples="
    $ cli_path_dirname ~/Pictures/Wallpapers/1.jpg
    /home/black/Pictures/Wallpapers
     
    $ cli_path_dirname ~/Pictures/Downloads/
    /home/black/Pictures"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    local tmp=${1:-.}

    [[ $tmp != *[!/]* ]] && {
        printf '/\n'
        return
    }

    tmp=${tmp%%"${tmp##*[!/]}"}

    [[ $tmp != */* ]] && {
        printf '.\n'
        return
    }

    tmp=${tmp%/*}
    tmp=${tmp%%"${tmp##*[!/]}"}

    printf '%s\n' "${tmp:-/}"
}

cli_path_basename() {

    # Обработка параметров и вывод help
    h_description="Получиет базовое имя пути к файлу"
    h_list_arg="
    \$1 - Путь к обрабатываемому файлу"

    h_examples="
    $ cli_path_basename ~/Pictures/Wallpapers/1.jpg
    1.jpg
     
    $ cli_path_basename ~/Pictures/Wallpapers/1.jpg .jpg
    1
    
    $ cli_path_basename ~/Pictures/Downloads/
    Downloads"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    local tmp

    tmp=${1%"${1##*[!/]}"}
    tmp=${tmp##*/}
    tmp=${tmp%"${2/"$tmp"}"}

    printf '%s\n' "${tmp:-/}"
}

cli_term_get_size() {

    # Обработка параметров и вывод help
    h_description="Получает размер терминала в строках и столбцах (из скрипта)"
    h_examples="
    # Output: LINES COLUMNS
    $ cli_term_get_size
    15 55"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    shopt -s checkwinsize; (:;:)
    printf '%s\n' "$LINES $COLUMNS"

}

cli_term_get_window_size() {

    # Обработка параметров и вывод help
    h_description="Получает размер терминала в пикселях"
    h_examples="
    # Output: WIDTHxHEIGHT
    $ cli_term_get_window_size
    1200x800
     
    # Output (fail):
    $ cli_term_get_window_size
    x"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '%b' "${TMUX:+\\ePtmux;\\e}\\e[14t${TMUX:+\\e\\\\}"
    IFS=$(';t') read -d t -t 0.05 -sra term_size
    printf '%s\n' "${term_size[1]}x${term_size[2]}"
}

cli_term_get_cursor_pos() {

    # Обработка параметров и вывод help
    h_description="Возвращает текущее положение курсора"
    h_examples="
    # Output: X Y
    $ cli_term_get_cursor_pos
    1 8"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    IFS='[;' read -p $'\e[6n' -d R -rs _ y x _
    printf '%s\n' "$x $y"
}

cli_term_hex_to_rgb() {

    # Обработка параметров и вывод help
    h_description="Преобразует шестнадцатеричного цвета в RGB"
    h_list_arg="
    \$1 - Значение цвета в шестнадцатеричном формате"

    h_examples="
    $ cli_term_hex_to_rgb \"#FFFFFF\"
    # 255 255 255"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    : "${1/\#}"
    ((r=16#${_:0:2},g=16#${_:2:2},b=16#${_:4:2}))
    printf '%s\n' "$r $g $b"

}

cli_term_rgb_to_hex() {

    # Обработка параметров и вывод help
    h_description="Преобразование цвета RGB в шестнадцатеричный формат"
    h_list_arg="
    \$1 - Число R цвета
    \$2 - Число G цвета
    \$3 - Число B цвета"

    h_examples="
    $ cli_term_rgb_to_hex \"255\" \"255\" \"255\"
    #FFFFFF"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    printf '#%02x%02x%02x\n' "$1" "$2" "$3"

}

cli_term_read_sleep() {

    # Обработка параметров и вывод help
    h_description="Режим сна"
    h_list_arg="
    \$1 - Время сна в секундах"

    h_examples="
    $ cli_term_read_sleep 1
    $ cli_term_read_sleep 0.1
    $ cli_term_read_sleep 30"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    read -rt "$1" <> <(:) || :

}

cli_term_bar() {

    # Обработка параметров и вывод help
    h_description="Прогресс бар"
    h_list_arg="
    \$1 - Счетчик исполнения операций
    \$2 - Общий размер операций"

    h_examples="
    for ((i=0;i<=100;i++)); do
       <Команды>
       cli_term_bar \"\$i\" \"10\"
    done"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    ((elapsed=$1*$2/100))

    # Create the bar with spaces.
    printf -v prog  "%${elapsed}s"
    printf -v total "%$(($2-elapsed))s"
    printf '%s\r' "[${prog// /-}${total}]"

}

cli_term_bkr() {

    # Обработка параметров и вывод help
    h_description="Запуск команды в фоновом режиме"
    h_list_arg="
    \$1 - Путь к исполняемому файлу (скрипту)"

    h_examples="
    $ cli_term_bkr ./some_script.sh"

    cli_show_help "$@"
    if [[ "$is_show_help" = true ]]; then
        return 0
    fi
    
    # Основная логика
    (nohup "$@" &>/dev/null &)
    
}