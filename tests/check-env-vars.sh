#!/bin/bash
if [ "$VARIABLE" = "correct" ]; then
    echo "Strings are equal."
    exit 0
else
    echo "Strings are not equal."
    exit 1
fi