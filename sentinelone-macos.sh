#!/bin/bash
set -e

ORGANIZATION_KEY=a0294c88a7c26f9054b2a9332810b3005cc3c3a9851b9b993318183437ab84c2
SITE_TOKEN=eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS1ncmR6LnNlbnRpbmVsb25lLm5ldCIsICJzaXRlX2tleSI6ICI0OGJmZmRhNzBhYTVlMzU5In0=
AGENT_FILE_URL=https://device-agent.app.us.guardz.com/api/device/agent-gateway/endpoint/installer/sentinel-one/2074150182101979687
AGENT_FILE_NAME=Sentinel-Release-24-2-2-7632_macos_v24_2_2_7632.pkg


AGENT_FOLDER_PATH="$(mktemp -d /tmp/sentinel-installer-XXXX)"
AGENT_FILE_PATH="$AGENT_FOLDER_PATH/$AGENT_FILE_NAME"

function check_root () {
    if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        printf "ERROR:  This script must be run as root.  Please retry with 'sudo'\n"
        exit 1;
    fi
}

function dependencies_check () {
    if ! [[ -x "$(which curl)" ]]; then
        printf "ERROR:  curl must be installed.\n"
        exit 1
    else
        printf "INFO:  curl is properly installed.\n"
    fi
}

function download_installer_file () {
    printf "INFO:  Downloading %s\n" "$AGENT_FILE_NAME"
    curl -H "Authorization: Bearer $ORGANIZATION_KEY" \
    "$AGENT_FILE_URL" --fail | xargs curl > "$AGENT_FILE_PATH"
}

function verify_variable(){
    if [ -n "$AGENT_FILE_URL" ] && [ -n "$AGENT_FILE_NAME" ] && [ -n "$SITE_TOKEN" ]
    then
        printf "INFO:  All parameters valid: %s\n" "$AGENT_INSTALL_SYNTAX $AGENT_FILE_NAME"
    else
        printf "INFO:  Missing parameters %s\n" "AGENT_FILE_URL=$AGENT_FILE_URL AGENT_FILE_NAME=$AGENT_FILE_NAME SITE_TOKEN=$SITE_TOKEN"
        exit 1
    fi
}

echo "Starting..."
check_root
verify_variable
download_installer_file

echo "$SITE_TOKEN" > "$AGENT_FOLDER_PATH/com.sentinelone.registration-token"

/usr/sbin/installer -pkg "$AGENT_FILE_PATH" -target /

rm -f "$AGENT_FILE_PATH"

printf "SUCCESS:  Finished installing SentinelOne Agent.\n"
