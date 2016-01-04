#!/usr/bin/env bash

# ##################################################
# MongoDB Replica Set Admin Script
#
version="1.0.1"               # Sets version variable
#
scriptTemplateVersion="1.5.0" # Version of scriptTemplate.sh that this script is based on
#                               v1.1.0 -  Added 'debug' option
#                               v1.1.1 -  Moved all shared variables to Utils
#                                      -  Added $PASS variable when -p is passed
#                               v1.2.0 -  Added 'checkDependencies' function to ensure needed
#                                         Bash packages are installed prior to execution
#                               v1.3.0 -  Can now pass CLI without an option to $args
#                               v1.4.0 -  checkDependencies now checks gems and mac apps via
#                                         Homebrew cask
#                               v1.5.0 - Now has preferred IFS setting
#                                      - Preset flags now respect true/false
#                                      - Moved 'safeExit' function into template where it should
#                                        have been all along.
#
# HISTORY:
#
# * 01-01-2016 - v1.0.0  - First Creation
# * 03-01-2016 - v1.0.1  - Implement replica set details
#
# ##################################################

# Provide a variable with the location of this script.
scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source Scripting Utilities
# -----------------------------------
# These shared utilities provide many functions which are needed to provide
# the functionality in this boilerplate. This script will fail if they can
# not be found.
# -----------------------------------

utilsLocation="${scriptPath}/../lib/utils.sh" # Update this path to find the utilities.

if [ -f "${utilsLocation}" ]; then
  source "${utilsLocation}"
else
  echo "Please find the file util.sh and add a reference to it in this script. Exiting."
  exit 1
fi

# trapCleanup Function
# -----------------------------------
# Any actions that should be taken if the script is prematurely
# exited.  Always call this function at the top of your script.
# -----------------------------------
function trapCleanup() {
  echo ""
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  die "Exit trapped."  # Edit this if you like.
}

# safeExit
# -----------------------------------
# Non destructive exit for when script exits naturally.
# Usage: Add this function at the end of every script.
# -----------------------------------
function safeExit() {
  # Delete temp files, if any
  if is_dir "${tmpDir}"; then
    rm -r "${tmpDir}"
  fi
  trap - INT TERM EXIT
  exit
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=false
printLog=false
verbose=false
force=false
strict=false
debug=false
args=()

# Set Temp Directory
# -----------------------------------
# Create temp directory with three random numbers and the process ID
# in the name.  This directory is removed automatically at exit.
# -----------------------------------
tmpDir="/tmp/${scriptName}.$RANDOM.$RANDOM.$RANDOM.$$"
(umask 077 && mkdir "${tmpDir}") || {
  die "Could not create temporary directory! Exiting."
}

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="$HOME/Library/Logs/${scriptBasename}.log"

# Check for Dependencies
# -----------------------------------
# Arrays containing package dependencies needed to execute this script.
# The script will fail if dependencies are not installed.  For Mac users,
# most dependencies can be installed automatically using the package
# manager 'Homebrew'.  Mac applications will be installed using
# Homebrew Casks. Ruby and gems via RVM.
# -----------------------------------
homebrewDependencies=()
caskDependencies=()
gemDependencies=()

function startCluster() {

  e_header "Starting Cluster"

  echo " "
  echo " ### Starting replica set: rs1"
  cd ${scriptPath}/rs1
  mongod --config mongodb.conf --fork

  echo " "
  echo " ### Starting replica set: rs2"
  cd ${scriptPath}/rs2
  mongod --config mongodb.conf --fork

  echo " "
  echo " ### Starting replica set: rs3"
  cd ${scriptPath}/rs3
  mongod --config mongodb.conf --fork

  echo ""

}

function startReplication() {
  e_header "Starting Replication"

  # 6 tries
  TIMEOUT=6
  COUNT=0

  # Checking if mongo is up
  while ! mongo --port 27023 --eval "var rs_cluster=$(cat ${scriptPath}/replication-cluster.json);" $scriptPath/start-replication.js; do 
    ((COUNT++));
    sleep 1; 
    echo " ";
    echo " ### Waiting for Mongo instance 27023 startup... ${COUNT}s"; 
    (($COUNT > $TIMEOUT)) && 
      echo " ### Cannot start replication: Timeout while trying to connect Mongo instance 27023" &&  
      exit 1;
  done
}

function stopCluster() {
  e_header "Stopping cluster"

  PIDS_MONGO=`ps aux | grep mongodb.conf | grep config | awk '{print $2}'`

  if [ -z "$PIDS_MONGO" ]; then
    echo " ### Mongo replica set nodes are not running"
  else
    echo " ### Stoping mongo instances"
    for PID in $PIDS_MONGO; do
      echo "Killing mongo process: $PID"
      kill $PID
    done 
  fi
}

function restartCluster() {

  stopCluster && startCluster;
}

function purgeCluster() {
  stopCluster

  echo " "
  echo " ### Purge replica set dbs"
  rm -rf ${scriptPath}/rs1/db
  rm -rf ${scriptPath}/rs2/db
  rm -rf ${scriptPath}/rs3/db
}

function mainScript() {

if [[ "$args" == "start-cluster" ]]; then

  mkdir ${scriptPath}/rs1/db
  mkdir ${scriptPath}/rs2/db
  mkdir ${scriptPath}/rs3/db

  startCluster

elif [[ "$args" == "start-replication" ]]; then
  startReplication

elif [[ "$args" == "stop-cluster" ]]; then
  stopCluster

elif [[ "$args" == "restart-cluster" ]]; then
  restartCluster

elif [[ "$args" == "purge-cluster" ]]; then
  purgeCluster

else 
  echo "Unknown option: {$args}"
fi

}

############## Begin Options and Usage ###################


# Print usage
usage() {
  echo -n "${scriptName} [OPTION]... [ACTION]...

MongoDB Replica Set Starter script.

 ${bold}Options:${reset}
  -u, --username    Username for script
  -p, --password    User password
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit

 ${bold}Actions:${reset}
  start-cluster       Start cluster
  start-replication   Start cluster replication
  stop-cluster        Stop cluster
  restart-cluster     Restart cluster
  purge-cluster       Purge cluster

"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    --version) echo "$(basename $0) ${version}"; safeExit ;;
    -u|--username) shift; username=${1} ;;
    -p|--password) shift; echo "Enter Pass: "; stty -echo; read PASS; stty echo;
      echo ;;
    -v|--verbose) verbose=true ;;
    -l|--log) printLog=true ;;
    -q|--quiet) quiet=true ;;
    -s|--strict) strict=true;;
    -d|--debug) debug=true;;
    --force) force=true ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

############## End Options and Usage ###################




# ############# ############# #############
# ##       TIME TO RUN THE SCRIPT        ##
# ##                                     ##
# ## You shouldn't need to edit anything ##
# ## beneath this line                   ##
# ##                                     ##
# ############# ############# #############

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$'\n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

# Invoke the checkDependenices function to test for Bash packages.  Uncomment if needed.
# checkDependencies

# Run your script
mainScript

# Exit cleanlyd
safeExit