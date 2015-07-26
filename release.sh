#!/bin/bash

SCRIPT_FOLDER="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="${SCRIPT_FOLDER}/lib/tdl/version.rb"

CURRENT_VERSION=`cat ${VERSION_FILE} | grep "VERSION" | cut -d "=" -f2 | tr -d " '"`

# Prompt for version confirmation
read -p "Going to release version ${CURRENT_VERSION}. Proceed ? [y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting."
    exit
fi

# Release current version
git tag -a "v${CURRENT_VERSION}" -m "Release ${CURRENT_VERSION}"
git push origin "v${CURRENT_VERSION}"
echo "Pushed tag to Git origin. It will now trigger the deployment pipeline."

# Increment version
increment_version() {
    local v=$1
    if [ -z $2 ]; then
        local rgx='^((?:[0-9]+\.)*)([0-9]+)($)'
    else
        local rgx='^((?:[0-9]+\.){'$(($2-1))'})([0-9]+)(\.|$)'

        for (( p=`grep -o "\."<<<".$v"|wc -l`; p<$2; p++)); do
           v+=.0;
        done;
    fi
    val=`echo -e "$v" | perl -pe 's/^.*'$rgx'.*$/$2/'`
    echo "$v" | perl -pe s/$rgx.*$'/${1}'`printf %0${#val}s $(($val+1))`/
}

# Switch to next version
NEXT_VERSION=`increment_version ${CURRENT_VERSION}`
echo "Next version is: $NEXT_VERSION"

cat > "${VERSION_FILE}" <<-EOF
module TDL
  VERSION = '$NEXT_VERSION'
end
EOF