#!/bin/bash
# Use: log-archiver.sh

# Dependancies: If archiving logs from a remote machine, this script uses SSH and assumes the connection is already tested and secured with
# a gpg key.  It also assumes your bash system has a connection to AWS and is connected with a key rather than a password.

# Description: This script will operate in five steps.

# Step 1 - Server information gathering:  The script will have the user specify the IPs of the servers that the user wants to include.  If one
# of the servers is local the user can specify this by typing "localhost".  It will take the data from the user and form a temporary list.
 
# Step 2 - Log information gathering:  The script will then ask the user if it is archiving the same logs on each machine, or if it's archiving 
# different files on each machine.  It will then loop through the server list and get the specifics for what is being archived. (this step is only
# performed once if all of the machiens have the same logs being archived.)  It will also ask the user if there are non-system logs being gathered,
# and find out the locations of those logs.  It will store these preferences in a temp file.

# Step 3 - Cloud: Script will ask if you'll want to back up the finished product to the cloud.  If so, it will gather the necessary connection information.

# Step 4 - Cron: Script will ask if you'd like to have this archival take place automatically at regular intervals.  If so, it will combine all of this
# information into a cron job.

# Step 5 - Processing:  Next, the script will begin processing.  It will loop through the server list and for each server it will connect, add the
# log files to a compressed tar ball, and move it back to the computer running the script.

# Step 6 - Logging:  Simultaneously with step 3, the script will create a log file of what servers it connected to, which files it archived, and what
# server the archived logs were sent to.

# Step 7 - Cron and Cloud:  Here, the script will create the cron job and move the archive up to S3 if that was requested by the user.

echo "----------------------------
--------Log Archiver--------
----------------------------
Grab logs, Archive logs...
Let someone else parse them.
----------------------------"

serverList() # Server information gathering
{
    read -p "How many servers do you want to archive? " server_count
    if [ $server_count -lt 1 ] # Let's make sure we didn't get a zero or a letter.
    then
        echo "Number of servers to archive must be at least 1."
        serverList
    fi
    if [ ! -f log-archiver-server-list ] # Making the temporary server log if we don't have one. If we do, we're dumping it and making a fresh one.
    then
        touch log-archiver-server-list
    else
        read -r -p "log-archiver-server-list exists. Shall  we blow it out? [y/n]" yesNo # Always nice to ask before nuking.
        case $yesNo in
        [yY][eE][sS]|[yY])
            echo "removing old copy of log-archiver-server-list"
            rm log-archiver-server-list
            echo "making new copy of log-archiver-server-list"
            touch log-archiver-server-list
            ;;
        [nN][oO]|[nN])
            echo "exiting program, please rename or remove log-archiver-server-list."
            exit
            ;;
        *) echo "Invalid option $REPLY";;
        esac
    fi
    server_num=1
    while [ $server_num -le $server_count ]
    do
        printf "server $server_num\n----------------------------\nWhat is the IP address for this host?\n(ex. ###.###.###.### or \'localhost\')\n"
        read -e server_ip
        echo "$server_ip" >> log-archiver-server-list
        (( server_num++ ))
    done
}

logInfo()
{

}
serverList
logInfo