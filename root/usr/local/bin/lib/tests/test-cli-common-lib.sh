#!/usr/bin/env bash

test_cli_date_get_current() {
    result="$(cli_date_get_current "%C")"
    assert_equals "$result" "20"
}

test_cli_str_uuid() {
    result=$(echo "$(cli_str_uuid)" | wc -c)
    assert_equals "$result" "37"
}

test_cli_str_trim_string() {
    result="$(cli_str_trim_string "    Hello,    World    ")"
    assert_equals "$result" "Hello,    World"
}

test_cli_str_trim_all() {

   result="$(cli_str_trim_all "    Hello,    World    ")"
   assert_equals "$result" "Hello, World"

}

test_cli_srt_regex() {

    result="$(cli_srt_regex "#FFFFFF" '^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$')"
    assert_equals "$result" "#FFFFFF"

}

test_cli_str_split() {
    IFS=$'\n' read -d "" -ra result < <(cli_str_split "hello,world,my,name,is,john" ",")
    assert_equals "${result[*]}" "hello world my name is john"
}

test_cli_str_lower() {

    result="$(cli_str_lower "HeLlO")"
    assert_equals "$result" "hello"

}

test_cli_str_upper() {
    result="$(cli_str_upper "HeLlO")"
    assert_equals "$result" "HELLO"
}

test_cli_str_reverse_case() {
    result="$(cli_str_reverse_case "HeLlO")"
    assert_equals "$result" "hElLo"
}

test_cli_str_trim_quotes() {
    result="$(cli_str_trim_quotes "\"te'st' 'str'ing\"")"
    assert_equals "$result" "test string"
}

test_cli_str_strip_all() {
    result="$(cli_str_strip_all "The Quick Brown Fox" "[aeiou]")"
    assert_equals "$result" "Th Qck Brwn Fx"
}

test_cli_str_strip() {
    result="$(cli_str_strip "The Quick Brown Fox" "[aeiou]")"
    assert_equals "$result" "Th Quick Brown Fox"
}

test_cli_str_lstrip() {
    result="$(cli_str_lstrip "!:IHello" "!:I")"
    assert_equals "$result" "Hello"
}

test_cli_str_rstrip() {
    result="$(cli_str_rstrip "Hello!:I" "!:I")"
    assert_equals "$result" "Hello"
}

test_cli_str_urlencode() {
    result="$(cli_str_urlencode "https://github.com/dylanaraps/pure-bash-bible")"
    assert_equals "$result" "https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible"
}

test_cli_str_urldecode() {
    result="$(cli_str_urldecode "https%3A%2F%2Fgithub.com%2Fdylanaraps%2Fpure-bash-bible")"
    assert_equals "$result" "https://github.com/dylanaraps/pure-bash-bible"
}

test_cli_array_reverse() {
    shopt -s compat44
    IFS=$'\n' read -d "" -ra result < <(cli_array_reverse 1 2 3 4 5)
    assert_equals "${result[*]}" "5 4 3 2 1"
    shopt -u compat44
}

test_cli_array_remove_dups() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_array_random_element() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_file_head() {
    printf '%s\n%s\n\n\n' "hello" "world" > /tmp/test_file
    result="$(cli_file_head 2 /tmp/test_file)"
    assert_equals "$result" $'hello\nworld'
}

test_cli_file_tail() {
    printf '\n\n\n%s\n%s\n' "hello" "world" > /tmp/test_file
    result="$(cli_file_tail 2 /tmp/test_file)"
    assert_equals "$result" $'hello\nworld'

}

test_cli_file_lines() {
    printf '\n\n\n\n\n\n\n\n' > /tmp/test_file
    result="$(cli_file_lines /tmp/test_file)"
    assert_equals "$result" "8"
}

test_cli_file_count() {
    result="$(cli_file_count ./{README.m,LICENSE.m,.travis.ym}*)"
    assert_equals "$result" "3"
}

test_cli_file_extract() {
    printf '{\nhello, world\n}\n' > /tmp/test_file
    result="$(cli_file_extract /tmp/test_file "{" "}")"
    assert_equals "$result" "hello, world"
}

test_cli_file_get_functions_stript() {
    IFS=$'\n' read -d "" -ra functions < <(cli_file_get_functions_stript)
    assert_equals "${functions[0]}" "assert_equals"
}

test_cli_path_dirname() {

    result="$(cli_path_dirname "/home/black/Pictures/Wallpapers/1.jpg")"
    assert_equals "$result" "/home/black/Pictures/Wallpapers"

    result="$(cli_path_dirname "/")"
    assert_equals "$result" "/"

    result="$(cli_path_dirname "/foo")"
    assert_equals "$result" "/"

    result="$(cli_path_dirname ".")"
    assert_equals "$result" "."

    result="$(cli_path_dirname "/foo/foo")"
    assert_equals "$result" "/foo"

    result="$(cli_path_dirname "something/")"
    assert_equals "$result" "."

    result="$(cli_path_dirname "//")"
    assert_equals "$result" "/"

    result="$(cli_path_dirname "//foo")"
    assert_equals "$result" "/"

    result="$(cli_path_dirname "")"
    assert_equals "$result" "."

    result="$(cli_path_dirname "something//")"
    assert_equals "$result" "."

    result="$(cli_path_dirname "something/////////////////////")"
    assert_equals "$result" "."

    result="$(cli_path_dirname "something/////////////////////a")"
    assert_equals "$result" "something"

    result="$(cli_path_dirname "something//////////.///////////")"
    assert_equals "$result" "something"

    result="$(cli_path_dirname "//////")"
    assert_equals "$result" "/"

}

test_cli_path_basename() {
    result="$(cli_path_basename "/home/black/Pictures/Wallpapers/1.jpg")"
    assert_equals "$result" "1.jpg"
}

test_cli_term_get_size() {

    assert_equals "[SKIP]" "TEST"
}

test_cli_term_get_window_size() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_term_get_cursor_pos() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_term_hex_to_rgb() {
    result="$(cli_term_hex_to_rgb "#FFFFFF")"
    assert_equals "$result" "255 255 255"

    result="$(cli_term_hex_to_rgb "000000")"
    assert_equals "$result" "0 0 0"
}

test_cli_term_rgb_to_hex() {
    result="$(cli_term_rgb_to_hex 0 0 0)"
    assert_equals "$result" "#000000"
}

test_cli_term_read_sleep() {
    result="$((SECONDS+1))"
    cli_term_read_sleep 1
    assert_equals "$result" "$SECONDS"
}

test_cli_term_bar() {
    result="$(cli_term_bar 50 10)"
    assert_equals "${result//$'\r'}" "[-----     ]"

}

test_cli_term_bkr() {
    assert_equals "[SKIP]" "TEST"
}

assert_equals() {
    if [[ "$1" == "$2" ]]; then
        ((pass+=1))
        status=$'\e[32m✔'
    else
        ((fail+=1))
        status=$'\e[31m✖'
        local err="(\"$1\" != \"$2\")"
    fi

    printf ' %s\e[m | %s\n' "$status" "${FUNCNAME[1]/test_} $err"
}

main() {
    
    clear
    
    # Run shellcheck and source the code.
    path_sripts=/cli-scripts.d
    if [ -d $path_sripts ]; then
        for i in "${path_sripts}"/*.sh; do
            chmod +x "$i"
            if [ -x "$i" ] && [ ""$i"" != *"test"* ]; then
                . "$i"
            fi
        done
        unset i
    fi

    # trap 'rm readme_code test_file' EXIT
    head="-> Running tests.."
    printf '\n%s\n%s\n' "$head" "${head//?/-}"

    # Generate the list of tests to run.
    IFS=$'\n' read -d "" -ra funcs < <(declare -F)
    for func in "${funcs[@]//declare -f }"; do
        [[ "$func" == test_* ]] && "$func";
    done
    
    comp="Completed $((fail+pass)) tests. ${pass:-0} passed, ${fail:-0} failed."
    printf '%s\n%s\n\n' "${comp//?/-}" "$comp"

    # If a test failed, exit with '1'.
    ((fail>0)) || exit 0 && exit 1
}

main "$@"