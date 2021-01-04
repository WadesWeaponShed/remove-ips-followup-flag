#!/bin/bash
printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nDetermining Number of Protections\n"
total=$(mgmt_cli -r true -d $DOMAIN show threat-protections limit 5 --format json |jq '.total')
printf "There are $total Protections\n"

printf "\nSearching for unused HOST objects. Depending on number of objects this can take a min.\n"
for I in $(seq 0 500 $total)
  do
    mgmt_cli -r true -d $DOMAIN show threat-protections offset $I limit 500 --format json | jq --raw-output '.protections[] | select(."follow-up" == true) | ("set threat-protection name " + "'" + .name + "'" + " follow-up false")' >>changing-ips-flag.txt
  done


sed -i "1s/^/mgmt_cli -d $DOMAIN -r true login > id.txt\n/" changing-ips-flag.txt
sed -i '1s/^/Clearing IPS Follow-up Flag\n/' changing-ips-flag.txt
echo "mgmt_cli -s id.txt publish" >> changing-ips-flag.txt
echo "mgmt_cli -s id.txt logout" >> changing-ips-flag.txt
chmod 777 changing-ips-flag.txt
printf "Host Deletion Commands in delete-unused-objects.txt\n"
