#!/usr/bin/env bash

test_cli_edt_run_script_file() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_build() {
    assert_equals "[SKIP]" "TEST"    
}

test_cli_edt_cd() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_clean-up-source() {
    assert_equals "[SKIP]" "TEST"    
}

test_cli_edt_delete() {
    assert_equals "[SKIP]" "TEST"    
}

test_cli_edt_export() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_format-modules() {
    
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_help() {

    result=$(echo "$(cli_str_uuid)" | wc -c)
    assert_no_equals "$result" "0"
}

test_cli_edt_import() {
    
    assert_equals "[SKIP]" "TEST"

}

test_cli_edt_infobase() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_infobase-create() {
    
    assert_equals "[SKIP]" "TEST"

}

test_cli_edt_infobase-delete() {
    
    assert_equals "[SKIP]" "TEST"

}

test_cli_edt_infobase-import() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_install-platform-support() {
    result=$(echo "$(cli_edt_install-platform-support)" | wc -c)
    assert_no_equals "$result" "0"
}

test_cli_edt_platform-versions() {
    result=$(echo "$(test_cli_edt_platform-versions)" | wc -c)
    assert_no_equals "$result" "0"
}

test_cli_edt_project() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_script() {
    
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_sort-project() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_uninstall-platform-support() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_validate() {
    assert_equals "[SKIP]" "TEST"
}

test_cli_edt_version() {
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

assert_no_equals() {
    if [[ "$1" != "$2" ]]; then
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