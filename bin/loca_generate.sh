#!/usr/bin/env bash

# when running locally (default), fvm is used
# on ci, fvm is not used
IS_CI=${1-false}
if [ "$IS_CI" = "false" ]; then COMMAND="fvm "; else COMMAND=""; fi

# generate from csv
$COMMAND dart run arb_generator

# generate localization delegates
$COMMAND flutter gen-l10n
