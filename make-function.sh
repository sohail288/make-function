#! /usr/bin/env bash

trap 'cleanTemporary && exit 1' SIGINT SIGTERM

# paths
FUNCTION_FILE_PATH="$HOME/local/bin/_functions"

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
  rm -f $FUNCTION_DEFS_PATH
}

initialize () {
  if ! [ -w $FUNCTION_DEFS_PATH ]; then
    mkdir -p $(dirname $FUNCTION_DEFS_PATH)
    touch $FUNCTION_DEFS_PATH
  fi
}

generate() {
  # set -x
  echo "#! /bin/bash" > $FUNCTION_FILE_PATH
  echo "" >> $FUNCTION_FILE_PATH
  echo "set -a" >> $FUNCTION_FILE_PATH
  cat $FUNCTION_DEFS_PATH | while read -r ALIAS; do
    read -r COMMAND
    read -r DOCUMENTATION
    read -r _   # blank line

    if [ -z $ALIAS ] || [ -z "'""$COMMAND""'" ] || [ -z "$DOCUMENTATION" ]; then
      echo "$FUNCTION_DEFS_PATH is malformed" >&2
      exit 1;
    fi

    # output the command as a shell function
    printf "$ALIAS() {\n" >> $FUNCTION_FILE_PATH

    command_with_replacements=""
    replacement_mapping=""
    # how many parameters do we need to account for?
    for tok in $COMMAND; do
      extracted_replacement=$(echo $tok | grep -E -o "@[A-Za-z0-9]+")
      if ! [ -z "$extracted_replacement" ]; then
        for replacement in $extracted_replacement; do
          if ! printf "${replacement_mapping}" | grep "$replacement"; then
            replacement_mapping="${replacement_mapping}${replacement}\n"
          fi
        done

        # our token(s) are in the replacement mappings so we can add a replaced
        # version to our command string
        replace_with="$tok"
        for replacement in $extracted_replacement; do
          replacement_arg=$(printf $replacement_mapping | grep -n $replacement | cut -f 1 -d":")
          replace_with=$(echo $replace_with | sed -E "s/"$replacement"/\$$replacement_arg/g")
        done
        command_with_replacements="$command_with_replacements $replace_with"
      else
        command_with_replacements="$command_with_replacements $tok"
      fi
    done

    total_parameters=$(( $(printf "$replacement_mapping" | wc -l) + 0 ))
    printf "\tif ! [ \$# -eq $total_parameters ]; then\n" >> $FUNCTION_FILE_PATH
    printf "\t\t" >> $FUNCTION_FILE_PATH
    echo "echo $DOCUMENTATION" >> $FUNCTION_FILE_PATH
    echo ""
    printf "\t\t" >> $FUNCTION_FILE_PATH
    echo echo "USAGE: $ALIAS " "$(printf "$replacement_mapping" | tr '\n' ' ')" >> $FUNCTION_FILE_PATH
    echo ""
    printf "\t\treturn 1\n" >> $FUNCTION_FILE_PATH
    printf "\tfi\n" >> $FUNCTION_FILE_PATH
    printf "\t" >> $FUNCTION_FILE_PATH
    echo $command_with_replacements >> $FUNCTION_FILE_PATH
    printf "}\n" >> $FUNCTION_FILE_PATH
    printf "\n" >> $FUNCTION_FILE_PATH
  done
  echo "set +a" >> $FUNCTION_FILE_PATH
  # set +x
}

initialize
if [ "$#" -eq 1 ] && [ "$1" == "generate" ]; then
  echo "generating $FUNCTION_FILE_PATH"
  generate
fi
