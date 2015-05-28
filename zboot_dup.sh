#!/bin/bash
#Initialize variables
DB_NAME="glide_dup"
VERSION="6"
if [ -n "$1" ]; then
    DB_NAME="$1"
    case $DB_NAME in
        "fuji") VERSION="6" ;;
        "eureka") VERSION="5" ;;
        "dublin") VERSION="3" ;;
        *) VERSION=$VERSION ;;
    esac
fi
DOMAIN=( "nexus.proxy.devsnc.com" "https://artifact.devsnc.com" )
DIR="content/groups/dev/com/snc/glide/test/glide-db-dump/$VERSION.0.0.0-SNAPSHOT"
DB_URL=$(curl -s ${DOMAIN[0]}/$DIR/ | grep -o \http\:[a-zA-Z.0-9\:\/\-]* | grep zsql$ | tail -1)

#Attempt to download the latest snapshot
if [ -n "$DB_URL" ]; then
    curl -O -L -J $DB_URL
else
    read -p "The snapshot was not found, attempt authenticated download? " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
    #Attempt authenticated download
    read -p "source.devsnc.com username: " myuser
    read -s -p "source.devsnc.com password: " mypwd
    echo -e "\nAttempting download..."
    DB_URL=$(curl --user "$myuser":"$mypwd" -s ${DOMAIN[1]}/$DIR/ | grep -o \https\:[a-zA-Z.0-9\:\/\-]* | grep zsql$ | tail -1)
    if [ -z "$DB_URL" ]; then
        echo "Snapshot could not be found!"
        exit 0
    fi
    curl -O -L -J --user "$myuser":"$mypwd" $DB_URL
fi

#Drop and create new database
/usr/local/homebrew/Cellar/mysql56/5.6.22/bin/mysqladmin -uroot -f drop $DB_NAME
echo -e "Creating \"$DB_NAME\" database"
/usr/local/homebrew/Cellar/mysql56/5.6.22/bin/mysqladmin -uroot create $DB_NAME

#Load and delete snapshot
SNAPSHOT="${DB_URL##*/}"
echo "Loading the snapshot: $SNAPSHOT"
gzcat $SNAPSHOT | /usr/local/homebrew/Cellar/mysql56/5.6.22/bin/mysql -uroot $DB_NAME
echo "Deleting downloaded snapshot"
rm $SNAPSHOT

echo -e "\nDone!"
