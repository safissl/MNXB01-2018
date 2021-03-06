#!/bin/bash

###############################################################################
# 
# Fortuneteller pseudocode - MNXB01-2018 Homework
#
# Author: Florido Paganelli florido.paganelli@hep.lu.se
#
# Description: this script downloads a fortune database
#              from a public API and presents it to the
#              user at login.
#              It takes in input the options
#                 --printinfo
#                 --cleanup
#                 -h|--help
#              that shows the downloaded fortunes.
# 
###############################################################################


#
# Student: Dalia Farghaly
#

# E0 (1 point) 
# inspect the website http://fortunecookieapi.herokuapp.com/
# and understand the format of the data that the API returns
# at http://fortunecookieapi.herokuapp.com/v1/fortunes
# understand what kind of data structure teh website returns and write it here:
#
# Datastructure format is: JSON


###### DO NOT TOUCH THE CODE BELOW #####################################

# This part of code defines variables and functions you can use
# during the exercises. It's like a small code library.

# This variable contains the name of this script.
SCRIPTNAME=$0

# Read options using GNU getopt.
# see info at 
#  - http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt
#  - https://dustymabe.com/2013/05/17/easy-getopt-for-a-bash-script/
OPTS=`getopt -o h --long help,printinfo,cleanup -n $SCRIPTNAME -- "$@"`

# I use this function to show help.
usage() {
      echo
      echo "usage:"
      echo " $0 [--printinfo|--cleanup|-h|--help]"
      echo -e "\t--printinfo     prints the contents of intermediate fortune files and exits"
      echo -e "\t--cleanup       delete temporary files and ask the user for each of them"
      echo -e "\t-h     this help"
}

# This line strips the quotes from the options, it's required when using
# the getopt command.
eval set -- "$OPTS"

# this while block  processes the command line options.
while true; do
  case $1 in
    -h|--help)
      # print help using the usage function
      usage
      # exit with no error
      exit 0
      ;;
    --printinfo)
      # This variable contains --printinfo if the user wants to see information
      # about where the fortunes file is saved.
      PRINTINFO=$1
      shift
      ;;
      # This variable contains --cleanup if the user wants to delete the
      # temporary folders and their contents
    --cleanup)
      CLEANUP=$1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1"
      # print help using the usage function
      usage
      # exit with error
      exit 1
      ;;
  esac
done

# Helper functions

# The dumpfile function takes in input a filename 
# and prints its contents if and only if the
# --printoption option was used when calling fortuneteller.
# Example usage of the function:
# dumpfile /path/to/filename
dumpfile() {
  # Store the passed filename in a variable called FILENAME
  FILENAME=$1

  # test if the printinfo option is passed to the command line then
  # print the content of the downloaded fortunes file using cat.
  if [[ "${PRINTINFO}x" == "--printinfox" ]]; then
        echo "printing $FILENAME..."
        cat $FILENAME
  fi
}

# Cleanup function. usage: 
#   cleanup <foldername>
# It deletes files if and only if
# the option --cleanup is passed to ./fortuneteller.sh
# It asks the user for permission to remove each file. (rm -i)
cleanup() {
  DIRTOREMOVE=$1
  # perform cleanup if specified by the user
  if [[ "${CLEANUP}x" == "--cleanupx" ]]; then
          echo "cleaning temporary folders..."
          rm -ir $DIRTOREMOVE
  fi
}

############  END OF UNTOUCHABLE CODE ##################################

############ START OF EXERCISES  (EDIT THIS PART!) #####################

# E1 (1 point)
# Create a temporary directory with the mktemp command.
# save its name in a variable named FTTEMPDIR
# make sure the directory is created in /tmp and is called ftellerXXX
# where XXX are random characters created by mktemp. Read mktemp
# documentation to understand more.
cd /tmp
FTTEMPDIR=`mktemp ftellerXXX -d`


# E2 (1 point)
# Download the database of fortunes from the URL
# http://fortunecookieapi.herokuapp.com/v1/fortunes
# using the wget command.
# save it into FTTEMPDIR
# make sure the output of wget is not visible to the user.
cd /tmp/$FTTEMPDIR
wget -q  http://fortunecookieapi.herokuapp.com/v1/fortunes


# E3 (1 point)
# use the dumpfile function to print the content of the fortunes file.
# --printinfo used in terminal #####
dumpfile fortunes



# E4 (2 point) Use the tool json_pp to print nicely the 
# fortunes file and save it as $FTTEMPDIR/fortunes_pp
# (hint: use cat and the pipe | to pass input to json_pp, and use 
# the redirector > to write the output of the commands to a file.)
cat fortunes|json_pp > fortunes_pp


# E5 (1 points)
# use the dumpfile function to print the content of the fortunes_pp file.
dumpfile fortunes_pp

# E6 (2 points) exit with 0 if --printinfo specified.
# cleanup if --cleanup is specified.
# Inform the user with a message:
#  "Exiting because --printinfo specified"
# call the cleanup function to delete the temporary files.
# To write this you can take inspiration in the IF statements in the
# helper functions at the beginning of this file.
  if [[ "${PRINTINFO}x" == "--printinfox" ]]; then
        echo  "Exiting because --printinfo specified"
	exit
  fi

  if [[ "${CLEANUP}x" == "--cleanupx" ]]; then
          rm -ir /tmp/$FTTEMPDIR
  fi


# E7 (1 point)
# Extract only the lines containing "message" and save them as $FTTEMPDIR/fortunes_messages
touch /tmp/$FTTEMPDIR/fortunes_messages
grep "message" /tmp/$FTTEMPDIR/fortunes_pp>fortunes_messages


# E8 (2 points) calculate the number of lines in the fortunes_messages file
# and store it in a variable NUMMSG
# hint: use the command wc, the pipe and a tool called "cut"
# see cut examples here:
# https://www.thegeekstuff.com/2013/06/cut-command-examples
NUMMSG=`wc fortunes_messages|cut -d' ' -f2`


# E9 (2 points) 
# pick a random number between 1 and NUMMSG and save it into the variable
# CHOSEN
# use the predefined variable RANDOM and the bc command. For hints see:
# https://coderwall.com/p/s2ttyg/random-number-generator-in-bash
CHOSEN=`echo $(($RANDOM % $NUMMSG + 1))`


#E10 (2 points)
# Pick the CHOSEN message from the list and print it on screen
# use head and tail to achieve this. Search on the internet:
# "print by line number using bash"
# put the message in a variable called MESSAGE

MESSAGE=`sed "${CHOSEN}q;d" /tmp/$FTTEMPDIR/fortunes_messages`
 



# E11 (1 point) extract only the message content using cut
 
only_message=`echo $MESSAGE|cut -d':' -f2|cut -d',' -f1|cut -d'"' -f2`


# E12 (1 point) Use echo -e to print spaces and newlines to show the 
# output as in the simple_call_output file
echo -e "\n\t$only_message\n"

# calling cleanup to clean the tmp folder
cleanup /tmp/$FTTEMPDIR
