#! /usr/bin/env bash

trap 'cleanTemporary && exit 1' SIGINT SIGTERM

# paths
FUNCTION_FILE_PATH="$HOME/local/bin/_functions"
FUNCTION_FOLDER="$HOME/local/bin/functions"

# TODO: have some kind of adaptor that allows files to be generated to the proper format
# in any way? Trying to keep everything pure bash for now.

# TODO: is it better to just create a file for each function?

# this can be json in the future but for now consists of \n\n separate blocks
# that contain the following format
# alias name
# alias command
# documentation
FUNCTION_DEFS_PATH="$HOME/.local/make-function/_functions.txt"

cleanTemporary() {
  echo
  echo  'exiting'
  echo
  rm -f "$FUNCTION_DEFS_PATH"
  rm -f "$FUNCTION_FOLDER/*"
  rmdir "$FUNCTION_FOLDER"
}

initialize () {
  if ! [ -w $FUNCTION_DEFS_PATH ]; then
    mkdir -p $(dirname $FUNCTION_DEFS_PATH)
    touch $FUNCTION_DEFS_PATH
  fi

  if ! [ -d "$FUNCTION_FOLDER" ]; then
    mkdir -p "$FUNCTION_FOLDER"
  fi
}

generate() {
  # set -x
  cat $FUNCTION_DEFS_PATH | while read -r ALIAS; do
    read -r COMMAND
    read -r DOCUMENTATION
    read -r _   # blank line

    if [ -z $ALIAS ] || [ -z "'""$COMMAND""'" ] || [ -z "$DOCUMENTATION" ]; then
      echo "$FUNCTION_DEFS_PATH is malformed" >&2
      exit 1;
    fi

    FUNCTION_FILE_PATH="$FUNCTION_FOLDER/$ALIAS"
    echo "#! /bin/bash" > "$FUNCTION_FILE_PATH"
    echo "" >> $FUNCTION_FILE_PATH

    command_with_replacements=""
    replacement_mapping=""
    # how many parameters do we need to account for?
    for tok in $COMMAND; do
      extracted_replacement=$(echo $tok | grep -E -o "@[A-Za-z0-9]+")
      if ! [ -z "$extracted_replacement" ]; then
        if ! printf "$replacement_mapping" | grep $extracted_replacement ; then
          # found a replacement that isn't yet in the replacement mappings
          # so add it to replacement mappings
          replacement_mapping="${replacement_mapping}${extracted_replacement}\n"
        fi
        # our token is in the replacement mappings so we can add a replaced
        # version to our command string
        replacement_arg=$(printf $replacement_mapping | grep -n $extracted_replacement | cut -f 1 -d":")
        replaced_token=$(echo $tok | sed -E "s/(@[a-zA-Z0-9_]+)/\$$replacement_arg/g")
        command_with_replacements="$command_with_replacements $replaced_token"
      else
        command_with_replacements="$command_with_replacements $tok"
      fi
    done

    total_parameters=$(( $(printf "$replacement_mapping" | wc -l) + 0 ))
    printf "if ! [ \$# -eq $total_parameters ]; then\n" >> $FUNCTION_FILE_PATH
    printf "\t" >> $FUNCTION_FILE_PATH
    echo "echo $DOCUMENTATION" >> $FUNCTION_FILE_PATH
    echo ""
    printf "\t" >> $FUNCTION_FILE_PATH
    echo echo "USAGE: $ALIAS " "$(printf "$replacement_mapping" | tr '\n' ' ')" >> $FUNCTION_FILE_PATH
    echo ""
    printf "\treturn 1\n" >> $FUNCTION_FILE_PATH
    printf "fi\n" >> $FUNCTION_FILE_PATH
    echo $command_with_replacements >> $FUNCTION_FILE_PATH
    chmod +x $FUNCTION_FILE_PATH
  done
  # set +x
}

initialize
if [ "$#" -eq 1 ] && [ "$1" == "generate" ]; then
  echo "generating $FUNCTION_FILE_PATH"
  generate
fi
