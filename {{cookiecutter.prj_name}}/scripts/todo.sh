#!/bin/bash
SEARCHTEXT="TODO"
ROOT=$(git rev-parse --show-toplevel)
OUTFILE="TODO.md"
EXCLUDE=''

while getopts "ohf:t:e:i:" option; do
    case $option in
        'o' )
            STDOUT=true
        ;;
        'h' )
            echo "$(basename "$0") - generate a todo file based on your code"
            echo "---"
            echo    "  -h - display this help"
            echo    "  -o - print output to STDOUT"
            echo -n "  -f - write to this file (defaults to TODO.md and path "
            echo    "starts at the repo's root)"
            echo    "  -t - text to search for (defaults to TODO)"
            echo    "  -e - exclude pattern"
            echo    "  -i - include pattern"
            exit
        ;;
        'f' )
            OUTFILE=$OPTARG
        ;;
        't' )
            SEARCHTEXT=$OPTARG
        ;;
        'e' )
            EXCLUDE="$EXCLUDE$OPTARG|"
        ;;
        'i' )
            if [[ -z $INCLUDE ]]; then
                INCLUDE=$OPTARG
            else
                INCLUDE="$INCLUDE|$OPTARG"
            fi
        ;;
    esac
done

if [[ $INCLUDE ]] && [[ $EXCLUDE ]]; then
    echo "-i and -e can't be used together!"
    exit 1
fi

EXCLUDE=$EXCLUDE$OUTFILE

OUTFILE="$ROOT/$OUTFILE"
if [ -z $STDOUT ]; then
    exec 1>"$OUTFILE"
fi

# initializes the file or just writes to stdout
echo "## To Do"
echo

# git grep options used and meaning:
#   -E - enable POSIX extended regexp for patterns
#   -I - skip binaries
#   -i - include lower case and mixed case versions of the text
#   -n - include line numbers
#   -w - Match the pattern only at word boundary
#   --full-name - the full path (starting from the repo root)
if [[ -z $INCLUDE ]]; then
    IFS=$'\r\n' tasks=($(git grep -EIinw --full-name "$SEARCHTEXT" "$ROOT" | egrep -v "($EXCLUDE)"))
else
    IFS=$'\r\n' tasks=($(git grep -EIinw --full-name "$SEARCHTEXT" "$ROOT" | egrep "($INCLUDE)"))
fi

# sed options used and meaning:
#    -r - enable extended regexp for patterns
#    /g - enable global pattern replacement
#    /I - ignore case of pattern match
current_file=''
for task in "${tasks[@]}"; do
    file=$(echo "$task" | cut -f1 -d':')
    line=$(echo "$task" | cut -f2 -d':')
    item=$(echo "$task" | cut -f3- -d':' | sed -r "s/.*$SEARCHTEXT *//gI")

    if [[ $file != "$current_file" ]]; then
        if [ $current_file ]; then
            echo
        fi
        current_file=$file
        echo "### \`\`$current_file\`\`"
    fi
    echo "(line $line) $item"
    echo
done
