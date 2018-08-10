#!/usr/bin/env bash

function error() {
    osascript <<EOT
        tell app "System Events"
            display dialog "$1" buttons {"OK"} default button 1 with icon caution with title "$2"
            return  -- Suppress result
        end tell
EOT
}

function prompt() {
#     osascript <<EOT
#         tell app "System Events"
#             text returned of (display dialog "$1" default answer "$2" buttons {"OK"} default button 1 with title "$3")
#         end tell
# EOT
    osascript <<EOT
        text returned of ( \
            display dialog "$2" \
            with title "$1" \
            buttons {"A"} \
            default answer "$3" )
EOT

}

function choose() {
    osascript <<EOT
        set options to {"A", "B", "C"}
        choose from list options
EOT
}

function main() {
    local title="sqa tools"
    local default="1"
    local content="\
        1. 安裝 Android Build \n\
        2. B \n\
        3. C \n\
        4. exit \n\
    "

    prompt "$title" "$content"
}

# while true; do
    # main
    choose
# done
