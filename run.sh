#!/usr/bin/env bash

set -e

# set variables based on docker env
RAILS_ENV=${RAILS_ENV:-ephemeral}
SECRET_KEY_BASE=${SECRET_KEY_BASE:-64563a9cddafd0b18b18b4ae36fdd96fbdf077f9338b87f765c32a3c5b3e3ba191ee2039b4239e52c0876283bcf024e45f773927e4d243517db0bb6bf9132742}
CASA_UUID=${CASA_UUID:-67f41a0b-8552-4e83-bfb1-d9119b2937db}
CASA_CONTACT_NAME=${CASA_CONTACT_NAME:-'Joe Schmoe'}
CASA_CONTACT_EMAIL=${CASA_CONTACT_EMAIL:-'joe@schmoecity.com'}

# replace casa config items:
echo -e "casa:\n  engine:\n    uuid: '$CASA_UUID'\n\nstore:\n  user_contact:\n    - name: '$CASA_CONTACT_NAME'\n      email: '$CASA_CONTACT_EMAIL'" > config/casa.yml
echo -e "hosts:\n  - host: elasticsearch\n    port: 9200\n\nindex: casa-$CASA_UUID" > config/elasticsearch.yml


# set up a mysql database if a mysql container is linked! note some weird echoing. i'll fix this later, i promise.
if [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
  DB_NAME=${DB_NAME:-casa}
  DB_USER=${DB_USER:-casa}
  DB_PASS=${DB_PASS:-casa}
  DB_PORT=${DB_PORT:-$MYSQL_PORT_3306_TCP_PORT}
  DB_HOST=${DB_HOST:-$MYSQL_PORT_3306_TCP_ADDR}
  mysql -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -h$DB_HOST -P$DB_PORT mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; grant all on $DB_NAME.* to \"$DB_USER\"@\"%\" IDENTIFIED BY \"$DB_PASS\"; FLUSH PRIVILEGES;"
  echo '' > config/database.yml
  echo " ephemeral:
   adapter: sqlite3
   pool: 5
   timeout: 5000
   database: db/ephemeral.sqlite3
 production:
   adapter: mysql2
   encoding: utf8
   database: $DB_NAME
   username: $DB_USER
   password: $DB_PASS
   host: $DB_HOST
   port: $DB_PORT
" >> config/database.yml
else
  echo '' > config/database.yml
  echo " ephemeral:
   adapter: sqlite3
   pool: 5
   timeout: 5000
   database: db/ephemeral.sqlite3
" >> config/database.yml
fi


RAILS_ENV=$RAILS_ENV bundle exec rake db:migrate

# a big ol' seeding hack. docker fs is ephemeral so we can't place a .seeded and assume it's been seeded.
# for now, just assume if an admin user is in whatever db we connect to, don't seed.
if [ "$RAILS_ENV" = "production" ]; then
  admin_count=`mysql -h$DB_HOST -P$DB_PORT -uroot -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD -BN -e 'select count(*) from users where username = "admin";' $DB_NAME`
  if [ $admin_count -eq 0 ]; then
    RAILS_ENV=$RAILS_ENV bundle exec rake db:seed
  fi
else
  admin_count=`sqlite3 db/ephemeral.sqlite3 "SELECT count(*) FROM users WHERE username = 'admin';"`
  if [ $admin_count -eq 0 ]; then
    RAILS_ENV=$RAILS_ENV bundle exec rake db:seed
  fi
fi

# start thin. docker dies when thin dies.
RAILS_ENV=$RAILS_ENV SECRET_KEY_BASE=$SECRET_KEY_BASE bundle exec thin start
