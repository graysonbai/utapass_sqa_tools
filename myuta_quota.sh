#! /bin/sh

#===== default value =====
AUID="07036330158"
MSNO="338075789866"
QUOTA="10"

URL_REVOKE="http://shell.kkcorp/~hunterchung/utapass-myuta-console/public/bin/quota-revoke.php"
URL_QUERY="http://shell.kkcorp/~hunterchung/utapass-myuta-console/public/bin/list-quota.php"
#=========================

function auid_to_msno() {
    MSNO=`curl -s 'https://goingmarry.kkinternal.com/~wesleyliao/console/api/mybox_user.php?msno=&uid=YPAU::'${AUID} | jq '."台長資訊"."msno"'`
}

function query() {
    local msg
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

function grant() {
    local msno=$1
    local quota=$2
    curl -d "msno=$msno&number=$quota&valid_at=0" http://shell.kkcorp/~hunterchung/utapass-myuta-console/public/bin/quota-creater.php
}

for arg in "$@"; do
    case "$arg" in
        --auid )
            AUID=$2
            auid_to_msno; shift 2
            ;;

        --query )
            query $MSNO | jq
            ;;

        --revoke )
            revoke_all $MSNO
            ;;

        --reset-to )
            QUOTA=$2; shift 2
            revoke_all $MSNO
            grant $MSNO $QUOTA
            ;;

        --grant )
            grant $MSNO $QUOTA
            ;;
    esac
done
