#! /bin/sh

#===== default value =====
auid="07036330158"
msno="338075789866"
pkg_name="no"
device="BH900026C7"

URL_REVOKE="http://shell.kkcorp/~hunterchung/utapass-myuta-console/public/bin/quota-revoke.php"
URL_QUERY="http://shell.kkcorp/~hunterchung/utapass-myuta-console/public/bin/list-quota.php"
URL_STATUS="http://shell.kkcorp/~carolinesun/utapass_member_update_api.php"
#=========================

function query() {
    curl -d msno=$1 $URL_QUERY 2>/dev/null
}

function revoke() {
    local msno=$1
    local time_t=${2-:0}
    time_t=`echo "$time_t" | sed 's/"//g'`
    curl -d "msno=$msno&revoke_at=$time_t" $URL_REVOKE 2>/dev/null
}

function revoke_all() {
    local msno="$1"
    local list=`query $msno | jq '.[].valid_at' | sort | uniq`
    for time in $list; do
        revoke "$msno" "$time"
    done
}

function end_leaving() {
    local msg
    msg=`curl -d "auid=$auid&pkg_name=$pkg_name&action=end_unsub_reserved" $URL_STATUS 2>/dev/null`
    [ $? -ne 0 ] && echo "$msg" && exit 1
}

function end_grace() {
    local msg
    msg=`curl -d "auid=$auid&pkg_name=$pkg_name&action=end_grace_period" $URL_STATUS 2>/dev/null`
    [ $? -ne 0 ] && echo "$msg" && exit 1
}

function restart() {
    adb -s "$device" shell am force-stop com.kddi.android.UtaPass &>/dev/null

    adb -s "$device" shell am start -n com.kddi.android.UtaPass/com.kddi.android.UtaPass.HomeActivity &> /dev/null
    [ $? -eq 0 ] && echo "" || exit 1
}

for arg in "$@"; do
    case "$arg" in
        --state_reset )
            pkg_name="all"
            ;;
    esac
done

for arg in "$@"; do
    case "$arg" in
        --query )
            query $msno
            ;;

        --revoke )
            revoke_all $msno
            ;;

        --end_leaving )
            end_leaving
            restart
            ;;

        --end_grace )
            echo $pkg_name

            end_grace
            restart
            ;;

        --restart )
            restart
            ;;
    esac
done


