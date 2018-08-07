#!/bin/sh

# READ 4
# WRITE 2
# EXECUTE 1

path=$(dirname $0)
date=$(date '+%Y-%m-%d')
datetime=$(date '+%Y-%m-%d %H:%M:%S')

base_url="https://api.godaddy.com/v1/domains"

writelog ()
{
	logpath=$path/logs
	logfile=$logpath/$date.log

	# If logdir not found, create one
	if [ ! -d $logpath ];
	then
		mkdir $logpath
		chmod 740 $logpath
	fi

	# Check for log file
	if [ ! -s $logfile ];
	then
		touch $logfile
		chmod 640 $logfile
	fi

	# Write message to log
	echo $datetime": $1" >> $logfile
}

exitapp ()
{
	writelog "---------------------------------------------------------"
	exit $1
}

ip_url="https://api.ipify.org"

writelog "IP Updater started!"

cred_path="$path/apicredentials"
domain_path="$path/domainname"
ip_path="$path/lastip"
changepath="$path/record_changes.log"

apikeys=$(cat $cred_path)
res1=$?
domain=$(cat $domain_path)
res2=$?

if [ ! $res1 -eq 0 ] || [ ! $res2 -eq 0 ]
then
	touch $cred_path
	touch $domain_path
	chmod 600 $cred_path
	chmod 600 $domain_path

	writelog "Configuration files are missing! Please configure apikey and domain files."
	writelog "Put API Key and Secret into credentials file and domain name into domain file."
	writelog "Keys format: API_KEY:API_SECRET | Domain format DOMAIN_NAME.SUFFIX."
	exitapp 1

elif [ ! -s $cred_path ] || [ ! -s $domain_path ]
then
	writelog "Files are missing data! Please configure options properly!"
	writelog "Put API Key and Secret into credentials file and domain name into domain file."
	writelog "Keys format: API_KEY:API_SECRET | Domain format DOMAIN_NAME.SUFFIX"
	exitapp 1
fi

writelog "Getting last ip from file..."
lastip=$(cat $ip_path)
ipres=$?

A_url="$base_url/$domain/records/A/@"
WILD_url="$base_url/$domain/records/A/*"

# Get external ip
writelog "Getting external ip..."
ip=$(curl -X GET $ip_url)

# Trim whitespace
trimmed_ip=$(echo $ip | xargs)

# Check if IP is empty
if [ -z "$trimmed_ip" ];
then
	writelog "Error while getting IP, value was empty. Exiting..."
	exitapp 1
fi

# Get last ip and check if need to update
if [ ! $ipres -eq 0 ];
then
	writelog "Last IP file not found, creating file.."
	touch $ip_path
	chmod 600 $ip_path
	lastip="NULL"

elif [ "$ip" = "$lastip" ];
then
	writelog "IP not changed from last, exiting..."
	exitapp 0
fi

# Save new IP to file
writelog "IP is changed! Updating record..."
echo $ip > $ip_path

# Log new ip
writelog "Last IP was: $lastip"
writelog "New IP is: $ip"

if [ ! -s $changepath ];
then
	writelog "IP change logfile not found. Creating one.."
	touch $changepath
	chmod 640 $changepath
fi

echo "$datetime: IP changed! FROM $lastip TO $ip" >> $changepath

# Create domain data request
result=[{\"data\":\"$ip\"}]

# Put modified domain IP to API
writelog "Sending PUT data to API..."

curl -X PUT -H "Content-type: application/json" -H "Authorization: sso-key $apikeys" -d $result $A_url
putres1=$?
curl -X PUT -H "Content-type: application/json" -H "Authorization: sso-key $apikeys" -d $result $WILD_url
putres2=$?

if [ ! $putres1 -eq 0 ] || [ ! $putres2 -eq 0 ];
then
	writelog "Error in PUT(s)! Send failed!"
	exitapp 1
fi

writelog "PUT sent!"
writelog "Operation done"

exitapp 0
