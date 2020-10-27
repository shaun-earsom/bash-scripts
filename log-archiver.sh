#!/bin/bash
# Use: log-archiver.sh $1

# Dependancies:
# * You're running this script from a user that has permissions to all servers & files.
# * If planning to run this script from cron, This user owns the crontab you wish to use.
# * The connection to external servers are already tested and secured with a gpg key.
# * If using AWS, you have already configured a connection and using a key for authentication.
# * You've already got jq installed. If not, get it from apt or a similar repository for your version of linux.
# * A JSON has already been created with the information this script will use.

# Description: In order to get a good data lifecycle going, we need to first harvest the data, prepare it for archival, and get it to the cloud.
# That is what this script enables.  It does this by creating an ssh connection to a list of servers, copying over the target files (in this example, logs),
# and merges them into a compressed tarball (tar.gz).  It will then add a log of its activity to the tarball, and if desired, send a copy to an S3 bucket.
# I made this script to accept all input parameters from a JSON file.  That way, the configuration parameters may be programically generated in the future.
# This script seemed especially useful for starting a backup of my home envrionment, which is why I created it.

# What I learned:
# 1. How to use jq.  This thing is super handy!
# 2. How to get some basic error handling and file validation in my scripts.

#Create a few arrays and a temp dir.
key=("null") #I want to start my counts at one rather than zero, so I supply the first value of the array.
username=("null")
mkdir log-archiver-temp

# Create log file for this run. Format: log_archive-YYYY-MM-DD
log_file="log_archive-$(date +"%Y-%m-%d").log"
time_stamp=$(date +"%F %T")
touch $log_file
echo "-----(INITIALIZATION)-----" >> $log_file
echo "$time_stamp - Log Created." >> $log_file

# Change name of JSON here.
json="log-archiver.json"

# TODO: Put in logic to validate if this is a properly formatted JSON file.

echo "$time_stamp - JSON input file validated." >> $log_file

# Read information from the JSON.
server_count=$(jq '.servers | length' $json)
key_count=$(jq '.config.keys | length' $json)
user_count=$(jq '.config.usernames | length' $json)
use_aws=$(jq -r .config.aws.useaws $json)
bucket_name=$(jq -r .config.aws.bucketname $json)
for ((i = 1; i <= $key_count; i++))
do
    key+=( $(jq -r .config.keys.key$i $json) )
done
for ((i = 1; i <= $user_count; i++))
do
    username+=( $(jq -r .config.usernames.username$i $json) )
done

# Loop through the servers and perform the archival of logs.
echo "$time_stamp - Initialization Successful." >> $log_file
echo "--------(ARCHIVAL)--------" >> $log_file
for ((i = 1; i <= $server_count; i++))
do
    server_host_ip=$(jq -r .servers.server$i.host $json)
    log_count=$(jq ".servers.server$i.logs | length" $json)
    mkdir ./log-archiver-temp/$server_host_ip

    # Check to see if this is localhost. If not, connect to the server.
    if [ $server_host_ip == "localhost" ] || [ $server_host_ip == "127.0.0.1" ] || [ $server_host_ip == "" ];
    then
        local_host="y"
        echo "$time_stamp - $server_host_ip - No Connection Needed" >> $log_file
    else
        local_host="n"
        ssh -i ${key[$i]} -l ${username[$i]} $server_host_ip
        error_ssh=$(echo $?)
        if [ $error_ssh == "0" ];
        then
            echo "$time_stamp - $server_host_ip - Connection Successful" >> $log_file
        else
            echo "$time_stamp - $server_host_ip - ERROR: Connection Failed, exiting program. SSH Error Code: $error_ssh" >> $log_file
            echo "--Please test all SSH connections before running this script" >> $log_file
            exit
        fi
    fi

    # Loop through the logs and move them to our host for more processing.
    for ((c = 1; c <= $log_count; c++))
    do
        log_location=$(jq -r .servers.server$i.logs.log$c $json)
        if [ $local_host == "y" ];
        then
            cp $log_location ./log-archiver-temp/$server_host_ip
            error_cp=$(echo $?)
            # Error check to make sure file copied successfully.
            if [ $error_cp == "0" ];
            then
                echo "$time_stamp - $server_host_ip - $log_location Copied Successfully" >> $log_file
            else
                echo "$time_stamp - $server_host_ip - ERROR: Copy failed for $log_location, exiting program.  CP Error Code: $error_scp" >> $log_file
                echo "--Please check and make sure all log locations exist and that you have permission to copy them before running this script" >> $log_file
                exit
            fi

        else
            scp ${username[$i]}@$server_host_ip:$log_location ./log-archiver-temp/$server_host_ip
            error_scp=$(echo $?)
            if [ $error_scp == "0" ];
            then
                echo "$time_stamp - $server_host_ip - $log_location Copied Successfully" >> $log_file
            else
                echo "$time_stamp - $server_host_ip - ERROR: Copy failed for $log_location, exiting program.  SCP Error Code: $error_scp" >> $log_file
                echo "--Please check and make sure all log locations exist and that you have permission to copy them before running this script" >> $log_file
                exit
            fi
        fi
    done
done
echo "$time_stamp - $server_host_ip - Log Archival Complete " >> $log_file

# Bundle up these logs and make a compressed tarball of the information, and do some cleanup.
echo "--------(COMPLETE)--------" >> $log_file
cp $log_file ./log-archiver-temp/$log_file
tarball="log-archive-$(date +"%Y-%m-%d").tar.gz"
tar cvzf $tarball ./log-archiver-temp
rm -rf ./log-archiver-temp

# Move tarball up to AWS S3 bucket.
if [ $use_aws == y ];
then
    aws cp $log_file $bucket_name
fi