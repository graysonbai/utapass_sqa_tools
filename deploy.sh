#! /bin/sh

function get_apk_regex() {
    local tmp_number="${build_number}"
    [ "${build_number}" = "lastBuild" ] && tmp_number="[0-9][0-9][0-9]?"

    if [ "${type}" = "dev" -a "${flavor}" = "production" ]; then
        apk_regex=".*(utapass_11.[0-9].[0-9][0-9]?_Build_${tmp_number}_20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9].apk).*"

    elif [ "${type}" = "dev" -a "${flavor}" = "debug" ]; then
        apk_regex=".*(utapass_11.[0-9].[0-9][0-9]?_Build_${tmp_number}_20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]_debug.apk).*"

    elif [ "${type}" = "dev" -a "${flavor}" = "test" ]; then
        apk_regex=".*(utapass_test_11.[0-9].[0-9][0-9]?_Build_${tmp_number}_20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9].apk).*"

    elif [ "${type}" = "master" ]; then
        apk_regex=".*(utapass_11.[0-9].[0-9][0-9]?_Build_${tmp_number}_20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9].apk).*"

    else
        echo "Unknown parameters: $type, $flavor" && exit 1

    fi

    apk_name=`curl -s "${site}${build_number}/" | sed -En 's/'$apk_regex'/\1/p'`
}

function download() {
    echo "Downloading ${apk_name} ..."

    local tgt=`cd "$(dirname ~/Downloads/x)" ; pwd -P`/${apk_name}
    [ -f "${tgt}" ] && echo "Already exists in '${tgt}'" \
                    && echo "skip downloading" \
                    && echo "" \
                    && return

    local url="${site}${build_number}/artifact/jenkins_output/${apk_name}"
    wget ${url} -O ${tgt}
    [ $? -eq 0 ] && echo "" || exit 1
}

function uninstall() {
    echo "Uninstall UtaPass ... "

    adb -s "$device" shell pm list package | egrep -i 'com.kddi.android.utapass$' &> /dev/null
    [ $? -ne 0 ] && echo "Skip it (NotInstalled)" && echo "" && return 

    adb -s "$device" uninstall 'com.kddi.android.UtaPass'
    echo ""
}

function install() {
    echo "Installing Utapass: ${apk_name} ... "
    adb -s "$device" install -r ~/Downloads/${apk_name}
    [ $? -eq 0 ] && echo "" || exit 1
}

function launch() {
    echo "Launching Utapass ... "
    adb -s "$device" shell am start -n com.kddi.android.UtaPass/com.kddi.android.UtaPass.HomeActivity
    [ $? -eq 0 ] && echo "" || exit 1
}

type="dev"
flavor="debug"
build_number="lastBuild"

base_url="https://utapass-jenkins.kkinternal.com/view/Android/job/"
site="${base_url}UtaPassAndroidDev/"
apk_regex=""
apk_name=""

device="BH900026C7"

action="install"

# if [ "$#" -eq 1 ]; then
#     build_number=$1

# else
    for arg in "$@"; do

        case "$arg" in

            --master )
                # echo "Fetching master build not supported yet ..." && exit 1
                type="master"
                site="${base_url}UtaPassAndroidMaster/"
                ;;

            --dev )
                type="dev"
                site="${base_url}UtaPassAndroidDev/"
                ;;

            --production | -p )
                flavor="production"
                ;;

            --debug | -d )
                flavor="debug"
                ;;

            --test | -t )
                flavor="test"
                ;;

            --install )
                action="install"
                ;;

            --upgrade )
                action="upgrade"
                ;;

            --remove )
                action="remove"
                ;;

            --freetier_dev )
                type="dev"
                site="${base_url}UtaPassAndroidFreeTier/"
                ;;

            * )
                build_number=$1
                
        esac
    done
# fi

case "$action" in
    install )
        get_apk_regex \
            && download \
            && uninstall \
            && install \
            && launch
        ;;

    upgrade )
        get_apk_regex \
            && download \
            && install \
            && launch
        ;;

    remove )
        uninstall
        ;;
esac






