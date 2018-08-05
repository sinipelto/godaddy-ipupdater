# godaddy-ipupdater
A small shell script that allows an automatic update of domain record when having a dynamic IP. This needs a active domain name owned on GoDaddy(tm) domain service and a linux-based server to run on. It uses GoDaddy(tm) domain API to update the record.

What you need:
 - Active domain in GoDaddy(tm) service (visit www.godaddy.com to get one)
 - UNIX/Linux server that runs locally behind a dynamic IP Address
 - A service/task scheduler or something that you can schedule this script with (for example Cron https://en.wikipedia.org/wiki/Cron)
 
 Using instructions
 1. To begin, put this script to a folder you have your user rights (for example create a new dir inside your home dir and put it there)
 2. Run the script once or add configuration files manually ('apicredentials' and 'domain')
 3. Add your personal configurations (api key, api secret and domain name to configuration:
  apicredentials: API_KEY:API_SECRET (for example: asdfgh1234:kjhgfds2456)
  domain: DOMAIN_NAME.SUFFIX (for example: mydomainname.com)
 4. Run the script again to test your configurations (the script should once do the update and create some logs
 5. Check the logs and ensure that the script ran correctly (there should be no errors)
 6. Add a scheduled task that runs the script periodically to upkeep your latest ip in the domain record
 
 (c) 2018 Sinipelto
 
