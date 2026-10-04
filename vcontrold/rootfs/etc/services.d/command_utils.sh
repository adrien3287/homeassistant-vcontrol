#!/usr/bin/with-contenv bashio

load_vcontrold_commands_array() {
    local commands_raw=${1-}
    local -n output_array=$2

    output_array=()
    mapfile -t output_array <<< "${commands_raw}"

    if (( ${#output_array[@]} == 1 )) && [[ "${output_array[0]}" == *'|'* ]]; then
        IFS='|' read -r -a output_array <<< "${output_array[0]}"
    fi
}

parse_vcontrold_command_entry() {
    local command_entry=${1-}
    local default_interval=${2-}
    local -n output_command=$3
    local -n output_type=$4
    local -n output_interval=$5
    local remainder

    output_command=""
    output_type=""
    output_interval=""

    [[ "${command_entry}" == *:* ]] || return 1
    output_command=${command_entry%%:*}
    remainder=${command_entry#*:}
    output_type=${remainder%%:*}

    if [[ "${remainder}" == *:* ]]; then
        output_interval=${remainder#*:}
        [[ -n "${output_interval}" && "${output_interval}" != *:* ]] || return 1
    else
        output_interval=${default_interval}
    fi

    [[ "${output_command}" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]] || return 1
    [[ "${output_type}" =~ ^(FLOAT|STRING)$ ]] || return 1
    [[ "${output_interval}" =~ ^[1-9][0-9]{0,4}$ ]] || return 1
    (( output_interval <= 86400 )) || return 1
}
