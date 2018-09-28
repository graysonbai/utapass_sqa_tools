#! /bin/sh

AUID="07036330158"
PKG_NAME=""
URL_STATUS="http://shell.kkcorp/~carolinesun/utapass_member_update_api.php"

function end_leave() {
    echo "End Reserved-unsubscribe status ..."
    [ "$AUID" = "" ] && echo "Skip: AUID not defined, please specify auid by '--auid 07012345678'" && exit 1

    printf 'AUID: %s, ' "$AUID"  
    local msg
    msg=`curl -d "auid=$AUID&pkg_name=$PKG_NAME&action=end_unsub_reserved" $URL_STATUS 2>/dev/null`
    [ $? -ne 0 ] && echo "$msg" && exit 1

    echo "Success"
    echo ""
}

function end_grace() {
    echo "End Grace-period status ..."
    [ "$AUID" = "" ] && echo "Skip: AUID not defined, please specify auid by '--auid 07012345678'" && exit 1

    printf 'AUID: %s, ' "$AUID"  
    local msg
    msg=`curl -d "auid=$AUID&pkg_name=$PKG_NAME&action=end_grace_period" $URL_STATUS 2>/dev/null`
    [ $? -ne 0 ] && echo "$msg" && exit 1

    echo "Success"
    echo ""
}

function restart() {
    echo "Restart UtaPass ..."
    for device in `adb devices | grep 'device$' | awk '{print $1}'`; do
        printf 'Connected Device: %s, ' "$device"

        adb -s "$device" shell am force-stop com.kddi.android.UtaPass &>/dev/null
        adb -s "$device" shell am start -n com.kddi.android.UtaPass/com.kddi.android.UtaPass.HomeActivity &> /dev/null
        [ $? -eq 0 ] && echo "Success"
    done
    echo ""
}

for arg in "$@"; do
    case "$arg" in
        --auid )
            AUID="$2"; shift 2 ;;

        -el | --end-leave )
            PKG_NAME="no"
            end_leave
            restart
            exit 0
            ;;

        -eg | --end-grace )
            PKG_NAME="all"
            end_grace
            restart
            exit 0
            ;;

        -egnr | --end-grace-no-reset )
            PKG_NAME="no"
            end_grace
            restart
            exit 0
            ;;

        --restart )
            restart
            exit 0
            ;;
    esac
done
