#!/bin/bash

# delete_entity.sh
#
# Removes a specific VHDL entity from a VHDL file in place.
#
# Usage:
#   ./delete_entity.sh <file.vho> <entity_name>
#
# Example:
#   ./delete_entity.sh top_impl.vho top

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <file.vho> <entity_name>"
    exit 1
fi

FILE="$1"
ENTITY="$2"

if [ ! -f "$FILE" ]; then
    echo "Error: file '$FILE' does not exist."
    exit 1
fi

# Create a temporary file in the same directory.
# This ensures that mv() remains atomic on the same filesystem.
TMP=$(mktemp "${FILE}.tmp.XXXXXX")

cleanup()
{
    rm -f "$TMP"
}

trap cleanup EXIT

awk -v entity="$ENTITY" '
BEGIN {
    IGNORECASE = 1
    skip = 0
    found = 0
}

# Start of the entity declaration
$0 ~ "^[[:space:]]*entity[[:space:]]+" entity "[[:space:]]+is([[:space:]]*;)?[[:space:]]*$" {
    skip = 1
    found = 1
    next
}

# End of the entity declaration
skip && $0 ~ "^[[:space:]]*end[[:space:]]+(entity[[:space:]]+)?" entity "[[:space:]]*;" {
    skip = 0
    next
}

# Support the shorter VHDL form:
#   end;
skip && $0 ~ "^[[:space:]]*end[[:space:]]*;" {
    skip = 0
    next
}

# Skip everything inside the entity
skip {
    next
}

# Preserve everything outside the entity
{
    print
}

END {
    if (!found) {
        print "Error: entity \"" entity "\" was not found." > "/dev/stderr"
        exit 2
    }

    if (skip) {
        print "Error: entity \"" entity "\" was not properly terminated." > "/dev/stderr"
        exit 3
    }
}
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

trap - EXIT

echo "OK: entity '$ENTITY' removed from '$FILE'."
