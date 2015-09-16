# casa-on-rails docker.

This is a [docker](https://www.docker.io) image that eases setup of the [casa-on-rails](https://github.com/ucla/casa-on-rails) server.

## Usage

The docker containers built from this repository can be found at the [docker hub](https://registry.hub.docker.com/u/stevenolen/casa-on-rails/).

If you'd just like to start to get a feel for casa, and don't care about database persistence, feel free to start with this command:

```bash
docker run -d -p 3000:3000 stevenolen/casa-on-rails
```

You can now find casa running at port 3000 on your docker host!

It should be noted that casa will complain about elasticsearch not being available (which disables app searching) and when you destroy the container, all the data will go with it!

If you'd like to link to a mysql and elasticsearch container and keep data beyond the life of this container (let's assume the container's name is `mysql`), you can start like this:

```bash
docker run -d 
  -p 3000:3000 \
  --link mysql:mysql \
  --link elasticsearch:elasicsearch
  -e DB_NAME=casa \
  -e DB_USER=casa \ 
  -e DB_PASS=casa \
  stevenolen/casa-on-rails
```

Note that in both cases port `8080` will be used on the docker host to support this container. Additionally, you'll likely want to pass a few environment variables for your case.

## Environment Variables

  * `RAILS_ENV`: defaults to `ephemeral`. set to `production` if you plan to use a linked mysql container.
  * `DB_HOST`: defaults to `$MYSQL_PORT_3306_TCP_ADDR`
  * `DB_PORT`: defaults to `$MYSQL_PORT_3306_TCP_PORT`
  * `DB_NAME`: defaults to `casa`
  * `DB_USER`: defaults to `casa`
  * `DB_PASS`: defaults to `casa`
  * `CASA_UUID`: defaults to a uuid. set this or your instance wont be unique!
  * `CASA_CONTACT_NAME`: defaults to "Joe Schmoe".
  * `CASA_CONTACT_EMAIL`: defaults to "joe@schmoecity.com"
  * `SECRET_KEY_BASE`: defaults to a non-unique cookie string. be careful with this!

## Bugs/Notes

This container (in addition to the casa-on-rails project is quite new, and is not yet considered production quality. Keep that in mind.

  * DB seeding is very weird, and simply assumes that if your admin user exists, the db has been seeded.
  * the production db info is overwritten at each startup
  * etc..

## Copyright
Copyright (c) 2015 UC Regents

This container is **open-source** and licensed under the AFFERO GENERAL PUBLIC LICENSE in accordance with the source app's license. The full text of the license may be found in the `LICENSE` file.