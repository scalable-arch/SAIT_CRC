#!/bin/bash

source ../common.sh

function print_help() {
  echo "Usage: run [command]"
  echo "  command options :"
  echo "    synth   : Synthesize the RTL codes using the Design Compiler"
  echo ""
  echo "    clean   : Clean the output directory."

  exit 1
}

export ROOT_DIR="$SAIT_CRC_HOME/../"
SCRIPT_PATH="$ROOT_DIR/syn/script.tcl"
export RTL_PATH="$ROOT_DIR/rtl/"

if [[ $1 == "clean" ]]; then
  echo "Cleaning up the old directory"
  rm -rf $RUN_DIR
  exit 0
elif [[ $1 == "synth" ]]; then
  mkdir -p $RUN_DIR
  cd $RUN_DIR
  echo "Synthesizing"
  $DC_CMD $DC_OPTIONS -f $SCRIPT_PATH | tee ./dc_shell.log
  rm -rf alib-52 *.pvl *.mr *.syn command.log default.svf
else
  print_help
fi