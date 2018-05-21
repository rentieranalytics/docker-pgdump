#!/bin/bash -e

export DIRECTORY=/code/dump/

if [[ -z $SOURCE_HOST || -z $SOURCE_LOGIN || -z $SOURCE_PASSWORD || -z $SOURCE_PORT || -z $SOURCE_DATABASE || -z $DESTINATION_HOST || -z $DESTINATION_LOGIN || -z $DESTINATION_PASSWORD || -z $DESTINATION_PORT || -z $DESTINATION_DATABASE ]]; then
  echo 'Not every required variable is defined.'
  exit 1
fi

if [ ! -d "$DIRECTORY" ]; then
    PGPASSWORD="$SOURCE_PASSWORD" pg_dump -U "$SOURCE_LOGIN" -h "$SOURCE_HOST" -d "$SOURCE_DATABASE" -F d -f "$DIRECTORY" -j 4 -Z 9 -c -v --if-exists
fi

PGPASSWORD="$DESTINATION_PASSWORD" psql -U "$DESTINATION_LOGIN" -h "$DESTINATION_HOST" -d "$DESTINATION_DATABASE" -c "DROP SCHEMA IF EXISTS public CASCADE;"

PGPASSWORD="$DESTINATION_PASSWORD" pg_restore -U "$DESTINATION_LOGIN" -h "$DESTINATION_HOST" -F d -v -c --if-exists -e -j 2 --disable-triggers --no-privileges -d "$DESTINATION_DATABASE" "$DIRECTORY"