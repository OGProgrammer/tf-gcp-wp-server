#!/usr/bin/env bash
#usage admin-password.sh acme

newSite=$1
NEW_ADMIN_PW=$(echo -n wp_$newSite_`date +"%m-%d-%y"` | sha1sum | cut -c -20)
echo $NEW_ADMIN_PW
