# AUTHOR

[@heri](http://twitter.com/heri)

# BACKGROUND

Installing Spree, let alone its re-engineering deep learning version, is time-consuming and error-prone. This dockerfile/docker compose solves this issue

* Ubuntu trusty
* Ruby 2.4.0
* Rails 5.0
* mysql
* Redis/Sidekiq for engagement emails and also compute machine learning
* DLSpree alpha version

# MANUAL

A > 8GB machine is recommended with a nvidia card. It will work however on a 4GB machine without an nvidia card

This dockerfile needs an id_rsa file to access the Deep Learning Spree repo. Ask heri@studiozenkai.com for information.

* Install docker https://docs.docker.com/engine/installation/#server
* Build `docker-compose up --build`
* To stop server: `docker-compose down`

# CREDITS

Inspired from:

https://nickjanetakis.com/blog/dockerize-a-rails-5-postgres-redis-sidekiq-action-cable-app-with-docker-compose

https://github.com/dell-cloud-marketplace/docker-spree

# COPYRIGHT

All rights reserved Heri Rakotomalala.

A Free Software version will be public when DLSpree goes out of beta.