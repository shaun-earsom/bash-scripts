#!/bin/bash
# Use: log-archiver.sh $1 $2 $3 $4

# Dependancies: If archiving logs from a remote machine, this script uses SSH and assumes the connection is already tested and secured with
# a gpg key.  It also assumes your bash system has a connection to AWS and is connected with a key rather than a password.

# Description: This script will operate in five steps.

# Step 1 - Read from server list: $1 provides server list for script to use.
 
# Step 2 - Read from log list:  $2 provides list of which logs to grab on each server.

# Step 3 - Cloud?:  $3 is the location in AWS S3 you want a copy moved to.

# Step 4 - Cron: $4 reads from a file you want to use as your crontab file.

# Step 5 - Processing:  Next, the script will begin processing.  It will loop through the server list and for each server it will connect, add the
# log files to a compressed tar ball, and move it back to the computer running the script.

# Step 6 - Logging:  Simultaneously with step 3, the script will create a log file of what servers it connected to, which files it archived, and what
# server the archived logs were sent to.

# Step 7 - Cron and Cloud:  Here, the script will create the cron job and move the archive up to S3 if that was requested by the user.
