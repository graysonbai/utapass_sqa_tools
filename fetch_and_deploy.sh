#! /bin/sh

function print_usage() {
    echo "The usage of $0"
    echo ""
    echo "Options:"
    echo "  --ios"
    echo "      fetch and deploy ios build"
    echo ""
    echo "  --android"
    echo "      fetch and deploy android build"
    echo ""
    echo "  --job"
    echo "      Jenkins Job Name without product name 'UtaPass' and platform name such as 'Android' or 'iOS',"
    echo "      ex. Master, Dev, Open, FreeTier"
    echo "      default is 'Dev'"
    echo ""
    echo "  --number"
    echo "      Build number, ex. 997,"
    echo "      default is 'lastBuild'"
    echo ""
    echo "  --flavor"
    echo "      which kind of build, ex. production, debug, or test"
    echo "      default is 'debug'"
    echo "      when '--ios' is specified, only 'production' and 'debug' is "
    echo ""
}

function screen_turn_on() {
    case "${platform}" in
        Android )
            echo "Turn on screen ..."

            for device in `adb devices | grep 'device$' | awk '{print $1}'`; do
                printf '%s : ' "$device"

                adb -s $device shell dumpsys power | \
                    grep -i  'display power' | \
                    grep -iq 'off' && \
                    adb -s $device shell input keyevent 26 && \
                    adb -s $device shell input keyevent 82

                [ $? -ne 0 ] && echo "Skip (ScreenIsOn)" || echo "Success"
            done
            ;;

        iOS )
            ;;

        * )
            print_usage && exit 1
            ;;
    esac

    echo ""
}


function get_build_name() {
    local _url="${url}${prodname}${platform}${job_name}/"

    local major="[0-9][0-9]?"
    local middle="[0-9]"
    local minor="[0-9][0-9]?"
    local version="${major}.${middle}.${minor}"

    local _number="${number}"
    [ "${number}" = "lastSuccessfulBuild" ] && _number="[0-9][0-9]?[0-9]?[0-9]?"

    case "$platform" in
        Android )
            local year="20[0-9][0-9]"
            local month="[0-9][0-9]"
            local day="[0-9][0-9]"
            local hour="[0-9][0-9]"
            local minute="[0-9][0-9]"
            local second="[0-9][0-9]"
            local date="${year}-${month}-${day}-${hour}-${minute}-${second}"

            case "${flavor}" in
                production )
                    apk_regex=".*(utapass_${version}_Build_${_number}_${date}.apk).*" ;;

                debug )
                    apk_regex=".*(utapass_${version}_Build_${_number}_${date}_debug.apk).*" ;;

                test )
                    apk_regex=".*(utapass_test_${version}_Build_${_number}_${date}.apk).*" ;;

                * )
                    print_usage && exit 1
            esac

            ;;

        iOS )
            case "${flavor}" in
                production )
                    apk_regex=".*(UtaPass_${version}_${_number}_InHouse.ipa).*" ;;
                    
                debug )
                    apk_regex=".*(UtaPass_${version}_${_number}_Inc.ipa).*" ;;

                test )
                    apk_regex=".*(UtaPass_${version}_${_number}_KDDI_K1_env.ipa).*" ;;

                * )
                    print_usage && exit 1
            esac
            ;;

        * )
            print_usage && exit 1
    esac

    build_name=`curl -s "${_url}${number}/" | sed -En 's/'$apk_regex'/\1/p'`
    # [ -z "${build_name}" ] && echo "Cannot get filename ($number)." && exit 1
}


function download_build() {
    if [ "${action}" != "archive" ]; then
        echo "Downloading ${build_name} ..."
    else
        echo "Archiving ${prodname}${platform}${job_name}: ${number} ..."
        [ "${platform}" = "iOS" ] && build_name="*.ipa" || build_name="*.apk"
    fi

    local tgt=`cd "$(dirname ~/Downloads/x)" ; pwd -P`

    local _path="/Users/utapass/.jenkins/jobs/${prodname}${platform}${job_name}/builds/${number}/archive/"
    [ "${platform}" = "iOS" ] && _path="${_path}${build_name}" || _path="${_path}jenkins_output/${build_name}"
    expect -c " 
        spawn scp utapass@172.30.66.75:${_path} ${tgt}
        expect \"assword:\"
        send \"UtaPass\r\"
        interact"

    echo ""
    echo "/Users/utapass/.jenkins/jobs/${prodname}${platform}${job_name}/builds/${number}/archive/"

    # local _url="${url}${prodname}${platform}${job_name}/${number}/artifact/"
    # case "${platform}" in
    #     iOS )
    #         _url="${_url}${build_name}"
    #         ;;

    #     Android )
    #         _url="${_url}jenkins_output/${build_name}"
    #         ;;
    # esac

    # wget ${_url} -O ${tgt}
    # [ $? -eq 0 ] && echo "" || exit 1
}


function uninstall() {
    echo "Uninstall ${prodname} ... "

    case "${platform}" in
        Android )
            for device in `adb devices | grep 'device$' | awk '{print $1}'`; do
                printf '%s : ' "$device"

                adb -s "$device" shell pm list package \
                    | grep -v '.test.home' \
                    | grep -i 'com.kddi.android.UtaPass' &> /dev/null

                [ $? -ne 0 ] && echo "Skip (NotInstalled)" && continue
                
                adb -s "$device" uninstall 'com.kddi.android.UtaPass'
            done
            ;;

        iOS )
            for device in `idevice_id -l`; do
                [ "$device" = "d1d6eacb4485d3259d766652e6217c2ead680e2f" ] && continue

                printf '%s : ' "$device"
                ideviceinstaller -u $device -U 'com.kkbox.utapassinhouse'

                printf '%s : ' "$device"
                ideviceinstaller -u $device -U 'com.kkbox.utapass'
            done
            ;;

        * )
            print_usage && exit 1
            ;;
    esac

    echo ""
}

function install() {
    echo "Installing Utapass: ${build_name} ... "
    
    case "${platform}" in
        Android )
            for device in `adb devices | grep 'device$' | awk '{print $1}'`; do
                printf '%s : ' "$device"
                adb -s "$device" install -r ~/Downloads/${build_name}
            done
            ;;

        iOS )
            for device in `idevice_id -l`; do
                [ "$device" = "d1d6eacb4485d3259d766652e6217c2ead680e2f" ] && continue

                printf '%s : ' "$device"

                ideviceinstaller -u $device -i ~/Downloads/$build_name
            done
            ;;

        * )
            print_usage && exit 1
            ;;
    esac

    echo ""
}

function permission() {
    [ "${permission}" = "no" ] && return

    case "${platform}" in
        Android )
            echo "Grant permissions ... "
            PERMISSIONS=(
                "READ_EXTERNAL_STORAGE"
                "READ_PHONE_STATE"
                "GET_ACCOUNTS"
            )

            for device in `adb devices | grep 'device$' | awk '{print $1}'`; do
                printf '%s : ' "$device"

                for permission in "${PERMISSIONS[@]}"; do
                    printf '%s ' "$permission"
                    adb -s "$device" shell pm grant com.kddi.android.UtaPass android.permission."${permission}"
                done
                echo ""
            done
            ;;

        iOS )
            ;;

        * )
            print_usage && exit 1
            ;;
    esac

    echo ""
}

function launch() {
    case "${platform}" in
        Android )
            echo "Launching Utapass ... "
            for device in `adb devices | grep 'device$' | awk '{print $1}'`; do
                printf '%s : ' "$device"
                adb -s "$device" shell am start -n com.kddi.android.UtaPass/com.kddi.android.UtaPass.HomeActivity
            done
            ;;

        iOS )
            ;;

        * )
            print_usage && exit 1
            ;;
    esac

    echo ""
}


prodname="UtaPass"
platform="Android"
job_name="Dev"
number="lastSuccessfulBuild"
flavor="debug"

action="install"
permission="yes"

url="https://utapass-jenkins.kkinternal.com/view/${platform}/job/"
build_name=""

for arg in "$@"; do
    case "$arg" in

        # ========================================
        # device platform releated
        # ========================================
        --ios | --iOS )
            platform="iOS"
            url="https://utapass-jenkins.kkinternal.com/view/${platform}/job/"
            shift ;;

        --android )
            platform="Android"
            url="https://utapass-jenkins.kkinternal.com/view/${platform}/job/"
            shift ;;

        # ========================================
        # job releated
        # ========================================
        --job )
            job_name="$2"; shift 2 ;;

        --master | --Master )
            job_name="Master"
            flavor="production"
            shift
            ;;

        --dev | --Dev )
            job_name="Dev"; shift ;;

        # ==================================================
        # build flavor (prod, debug, or test) releated
        # ==================================================
        --flavor | -f )
            flavor="$2"; shift 2 ;;

        --production | --prod )
            flavor="production"; shift ;;

        --debug | --staging )
            flavor="debug"; shift ;;

        --test )
            flavor="test"; shift ;;

        # ========================================
        # build number
        # ========================================
        --number | --num | -n )
            number="$2"; shift 2 ;;

        # ========================================
        # action (install, upgrade, remove, or archive)
        # ========================================
        --action | -a )
            action="$2"; shift 2 ;;

        --upgrade )
            action="upgrade"; shift ;;

        --remove )
            action="remove"; shift ;;

        --archive )
            action="archive"; shift ;;

        # ========================================
        # action (install, upgrade, or remove)
        # ========================================
        --permission )
            permission="$2"; shift 2 ;;

        --permission-all )
            permission="yes"; shift ;;

    esac
done

echo ""

case "$action" in
    install )
        screen_turn_on \
            && get_build_name \
            && download_build \
            && uninstall \
            && install \
            && permission \
            && launch
        ;;

    upgrade )
        screen_turn_on \
            && get_build_name \
            && download_build \
            && install \
            && permission \
            && launch
        ;;

    archive )
        get_build_name \
            && download_build
        ;;

    remove )
        screen_turn_on \
            && uninstall
        ;;
esac

exit 0
