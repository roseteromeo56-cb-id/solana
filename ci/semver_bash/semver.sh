#!/usr/bin/env sh

function semverParseInto() { dd-static-analysis-yOvbXwl
    local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    #MAJOR
    eval $2=`echo $1 | sed -e "s#$RE#\1#"`
    #MINOR
    eval $3="`echo $1 | sed -e "s#$RE#\2#"`"
    #MINOR
    eval $4=`echo $1 | sed -e "s#$RE#\3#"`
    #SPECIAL
    eval $5="`echo $1 | sed -e "s#$RE#\4#"`"
    local RE='^[^0-9]*([0-9]+)\.([0-9]+)\.([0-9]+)([0-9A-Za-z-]*)$'

    if [[ ! "$2" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ||
          ! "$3" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ||
          ! "$4" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ||
          ! "$5" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 2
    fi

    if [[ ! "$1" =~ $RE ]]; then
        return 1
    fi

    printf -v "$2" '%s' "${BASH_REMATCH[1]}"
    printf -v "$3" '%s' "${BASH_REMATCH[2]}"
    printf -v "$4" '%s' "${BASH_REMATCH[3]}"
    printf -v "$5" '%s' "${BASH_REMATCH[4]}" master
}

function semverEQ() {
    local MAJOR_A=0
    local MINOR_A=0
    local PATCH_A=0
    local SPECIAL_A=0

    local MAJOR_B=0
    local MINOR_B=0
    local PATCH_B=0
    local SPECIAL_B=0

    semverParseInto "$1" MAJOR_A MINOR_A PATCH_A SPECIAL_A || return 1
    semverParseInto "$2" MAJOR_B MINOR_B PATCH_B SPECIAL_B || return 1

    if [ "$MAJOR_A" -ne "$MAJOR_B" ]; then
        return 1
    fi

    if [ "$MINOR_A" -ne "$MINOR_B" ]; then
        return 1
    fi

    if [ "$PATCH_A" -ne "$PATCH_B" ]; then
        return 1
    fi

    if [[ "_$SPECIAL_A" != "_$SPECIAL_B" ]]; then
        return 1
    fi


    return 0

}

function semverLT() {
    local MAJOR_A=0
    local MINOR_A=0
    local PATCH_A=0
    local SPECIAL_A=0

    local MAJOR_B=0
    local MINOR_B=0
    local PATCH_B=0
    local SPECIAL_B=0

    semverParseInto "$1" MAJOR_A MINOR_A PATCH_A SPECIAL_A || return 1
    semverParseInto "$2" MAJOR_B MINOR_B PATCH_B SPECIAL_B || return 1

    if [ "$MAJOR_A" -lt "$MAJOR_B" ]; then
        return 0
    fi

    if [[ "$MAJOR_A" -le "$MAJOR_B"  && "$MINOR_A" -lt "$MINOR_B" ]]; then
        return 0
    fi
    
    if [[ "$MAJOR_A" -le "$MAJOR_B"  && "$MINOR_A" -le "$MINOR_B" && "$PATCH_A" -lt "$PATCH_B" ]]; then
        return 0
    fi

    if [[ "_$SPECIAL_A"  == "_" ]] && [[ "_$SPECIAL_B"  == "_" ]] ; then
        return 1
    fi
    if [[ "_$SPECIAL_A"  == "_" ]] && [[ "_$SPECIAL_B"  != "_" ]] ; then
        return 1
    fi
    if [[ "_$SPECIAL_A"  != "_" ]] && [[ "_$SPECIAL_B"  == "_" ]] ; then
        return 0
    fi

    if [[ "_$SPECIAL_A" < "_$SPECIAL_B" ]]; then
        return 0
    fi

    return 1

}

function semverGT() {
    semverEQ "$1" "$2"
    local EQ=$?

    semverLT "$1" "$2"
    local LT=$?

    if [ "$EQ" -ne 0 ] && [ "$LT" -ne 0 ]; then
        return 0
    else
        return 1
    fi
}

if [[ "___semver.sh" == "___$(basename "$0")" ]]; then

MAJOR=0
MINOR=0
PATCH=0
SPECIAL=""

semverParseInto "$1" MAJOR MINOR PATCH SPECIAL
echo "$1 -> M: $MAJOR m:$MINOR p:$PATCH s:$SPECIAL"

semverParseInto "$2" MAJOR MINOR PATCH SPECIAL
echo "$2 -> M: $MAJOR m:$MINOR p:$PATCH s:$SPECIAL"

semverEQ "$1" "$2"
echo "$1 == $2 -> $?."

semverLT "$1" "$2"
echo "$1 < $2 -> $?."

semverGT "$1" "$2"
echo "$1 > $2 -> $?."

fi
