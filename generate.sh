#!/bin/bash

Green='\033[0;32m' # Green
Red='\033[0;31m'   # Red
NC='\033[0m'       # No Color
print() {
    printf "${Green}%b${NC}" "$1"
}

printerr() {
    printf "${Red}%b${NC}" "$1"
}

function bundle_identifier() {
    case $1 in
    "chrome")
        echo "com.google.Chrome"
        ;;
    "edge")
        echo "com.microsoft.Edge"
        ;;
    "brave")
        echo "com.brave.Browser"
        ;;
    *)
        return 1
        ;;
    esac
}

function extension_id() {

    # User input for extension ID as array
    print "Enter extension ID (separated by space): "
    read -r -a EXTENSION_IDS

    EXTENSION_STRING_TEMPLATE="<string>{{ EXTENSION_ID }}</string>\n"

    # For each extension ID, add it to a string based on template, end with new line
    EXTENSION_STRING=""
    for EXTENSION_ID in ${EXTENSION_IDS[@]}; do
        EXTENSION_STRING+=$(echo $EXTENSION_STRING_TEMPLATE | sed "s/{{ EXTENSION_ID }}/$EXTENSION_ID/g")
        EXTENSION_STRING+="                                        "
        # EXTENSION_STRING+=$'\n'
    done
    # echo $EXTENSION_STRING

}

# If no arguments are passed generate a new mobileconfig
if [ $# -eq 0 ]; then
    # Generate UUID
    UUID1=$(uuidgen)
    UUID2=$(uuidgen)

    # User input for browser name
    print "Enter browser name (Chrome, Edge, Brave): "
    read -r BROWSER

    # Get the bundle identifier for the browser with lowercased input
    BROWSER_BUNDLE_IDENTIFIER=$(bundle_identifier $(echo $BROWSER | tr '[:upper:]' '[:lower:]'))
    if [ $? -ne 0 ]; then
        printerr "Invalid browser name\n"
        exit 1
    fi

    # Get the extension string from extension_id function
    extension_id

    # Edit the template, replace the UUIDs, browser name, and bundle identifier
    cat template.mobileconfig | sed "s#{{ EXTENSION_STRINGS }}#$EXTENSION_STRING#g" | sed "s/{{ UUID1 }}/$UUID1/g" | sed "s/{{ UUID2 }}/$UUID2/g" | sed "s/{{ BROWSER }}/$BROWSER/g" | sed "s/{{ BROWSER_BUNDLE_ID }}/$BROWSER_BUNDLE_IDENTIFIER/g" >"$BROWSER_BUNDLE_IDENTIFIER.mobileconfig"
# if argument is passed, use it as template
else

    print "Existing extension IDs from $1, copy to next prompt to preserve:\n"
    # Insane sed command to get the existing extension IDs from file
    cat $1 | sed -e ':a' -e 'N' -e '$!ba' -n -e "s#[[:space:][:graph:]]*<key>ExtensionInstallAllowlist</key>[[:space:]]*<array>\([[:space:][:graph:]]*\)\n                                    </array>[[:space:][:graph:]]*#\1#p" | sed "s#[[:space:]]*<string>\(.*\)</string>#\1#g" | sed "s#</string>#\n#g" | sed "s#<string>##g" | sed -e ':a' -e 'N' -e '$!ba' -e "s#\n# #g" | sed 's/^ *//g'
    echo ""

    extension_id

    cat $1
    # Replace existing extension IDs with new ones
    cat $1 | sed -e ':a' -e 'N' -e '$!ba' -e "s#\(<key>ExtensionInstallAllowlist</key>[[:space:]]*<array>\n                                        \)\([[:space:][:graph:]]*\)\(\n                                    </array>\)#\1$EXTENSION_STRING\3#" >"new_$1"
    mv "new_$1" $1

fi
