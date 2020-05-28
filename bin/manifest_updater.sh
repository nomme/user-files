#!/bin/bash

GERRIT_CRED_PATH="$HOME/.cred/gerrit"
JQ_QUERY=". | { project: .project, status: .status, current_revision: .current_revision, ref: .revisions[] | .ref }"

P_MANIFESTS=(IHU_android-P-devel.xml IHU_android-P-devel-src.xml devel-p.xml components.xml bsp-dev-p.xml)
Q_MANIFESTS=(IHU_android-Q-devel.xml IHU_android-Q-devel-src.xml devel-q.xml components.xml bsp-dev-q.xml)
MANIFESTS="${Q_MANIFESTS[@]}"

function error()
{
    echo "$(basename $0) error: $@" >&2
    exit 1
}

function check_executable()
{
    command -v $1 > /dev/null || error "Could not find executable: $1"
}

function usage()
{
    my_name="$(basename $0)"
    cat <<EOF
$my_name [-p|-q] <Gerrit URL>...

$my_name will update the manifest files in the current directory with the
revisions from the given Gerrit URLs. It will update to the latest available
revisions. "upstream" attribute is updated when applicable.

-p      Update P manifests
-q      Update Q manifests (default)

Examples:
$my_name http://1.2.3.4:8080/c/my_repository/+/123456
$my_name -p http://1.2.3.4:8080/c/my_repository/+/123456/
$my_name -q http://1.2.3.4:8080/123456

Gerrit credentials shall be put into $GERRIT_CRED_PATH
The format of the file is '<username>:<http credentials>'
EOF
}

while getopts hpq option
do
    case "$option"
        in
        p)
            MANIFESTS="${P_MANIFESTS[@]}"
            ;;
        q)
            MANIFESTS="${Q_MANIFESTS[@]}"
            ;;
        h)
            ;&
        ?)
            usage
            exit 0
            ;;
    esac
done
shift $((OPTIND-1))

# Sanity tests
[ -z ${MANIFESTS+x} ] && error "Variable MANIFESTS not set"
for manifest in ${MANIFESTS[@]}; do [ -f $manifest ] && break; done || error "Could not find manifest files"

check_executable xmlstarlet
check_executable jq
check_executable sed
check_executable curl

GERRIT_CREDENTIALS="$(cat $GERRIT_CRED_PATH)" && \
    [[ $GERRIT_CREDENTIALS =~ .+:.+ ]] || \
    error "Did not find Gerrit credentials in $GERRIT_CRED_PATH"

# Loop URLs
for change in $@;
do
    # Extract Gerrit change number
    change_number="$(echo "$change" | sed -re 's#https?://.*\+?/([0-9]+)/?[0-9]*|/([0-9]+)/?#\1\2#')"
    [[ $change_number =~ ^[0-9]+$ ]] || error "Could not find change number from $change"
    gerrit_output="$(curl -s -u $GERRIT_CREDENTIALS ${GERRIT_REST_URL}/changes/$change_number/?o=CURRENT_REVISION | \
        grep -v ')]}' | jq "$JQ_QUERY")"

    # Extract individual fields from Gerrit output
    gerrit_project="$(echo "$gerrit_output" | jq -r '.project')"
    current_revision="$(echo "$gerrit_output" | jq -r '.current_revision')"
    reference="$(echo "$gerrit_output" | jq -r '.ref')"
    status="$(echo "$gerrit_output" | jq -r '.status')"

    for manifest in ${MANIFESTS[@]};
    do
        [ -f $manifest ] || continue
        if xmlstarlet sel -Q -t -c "/manifest/project[@name=\"$gerrit_project\"]" "$manifest"
        then
            echo "Updating $gerrit_project with change $change_number in $manifest"
            # Update revision
            xmlstarlet edit -P -L -u "/manifest/project[@name=\"$gerrit_project\"]/@revision" -v "$current_revision" "$manifest"

            if [ $status = "MERGED" ]
            then
                # Delete upstream
                xmlstarlet edit -P -L -d "/manifest/project[@name=\"$gerrit_project\"]/@upstream" "$manifest"
            else
                if xmlstarlet sel -Q -t -v "/manifest/project[@name=\"$gerrit_project\"]/@upstream" "$manifest"
                then
                    # Update upstream
                    xmlstarlet edit -P -L -u "/manifest/project[@name=\"$gerrit_project\"]/@upstream" -v "$reference" "$manifest"
                else
                    # Insert upstream
                    xmlstarlet edit -P -L -i "/manifest/project[@name=\"$gerrit_project\"]" -t attr -n upstream -v "$reference" "$manifest"
                fi
            fi
            break
        fi
    done
done

