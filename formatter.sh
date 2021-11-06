#!/bin/bash
set -eo pipefail

# the script is designed to be launched from within the root directory of a multiple directory project
if [[ $1 -ef $(pwd -P) ]]; then
    PROJECT_ROOT=$( cd "$(dirname "$0")" ; $(pwd -P))
elif [[ -d $1 ]]; then
    echo "Changing directory to project root: " $1
    cd $1
    PROJECT_ROOT=$( cd "$(dirname "$0")" ; pwd -P )
else 
    echo "formatter.sh <project root> <optional log directory path> <intellij formatter path> <intellij codestyle xml path"
    exit 1
fi


LOG_PATH=$(mktemp -d "${TMPDIR:-/tmp}/idea_formatter.XXXXXXXXX")
echo "Logs can be found at " $LOG_PATH 
# clean up log files, rm -rf pretty safe since they were made using mktemp
trap "rm -rf -- $LOG_PATH" 0

# on MacOS it looks like this /Applications/IntelliJ\ IDEA\ CE.app/Contents/bin/format.sh
if [[ -z $2 ]]; then
    FORMATTER_PATH="/Applications/IntelliJ IDEA CE.app/Contents/bin/format.sh"
    echo "Defaulting to MacOS formatter installation path"
elif [[ -e $2 && -x $2 ]]; then
    FORMATTER_PATH="$2"
    echo "Formatter located at: " "$FORMATTER_PATH"
else 
    echo $2 " doesn't exist or isn't executable"
    exit 1
fi

# point this to wherever you store your intelliJ codestyle 
if [[ -z $3 ]]; then
    STYLE_PATH=$PROJECT_ROOT/".idea/codeStyles/Project.xml"
elif [[ -e $3 ]]; then
    STYLE_PATH=$3
else 
    echo $3 " doesn't exist"
    return 1
fi

# my project contains non-project directories, so i only want the ones that match the prefix
$PREFIX="prefix*"
for MODULE in $(find * -maxdepth 0 -type d -name "$PREFIX" | cut -c1-)
    do
        echo "Running formatter on " $MODULE
        cd $PROJECT_ROOT/$MODULE || exit 1;
        touch $LOG_PATH/$MODULE.log 
        exec "$FORMATTER_PATH" -r . -s $STYLE_PATH >> $LOG_PATH/$MODULE.log || exit 1;
    done
