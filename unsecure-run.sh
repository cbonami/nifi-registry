#!/usr/bin/env bash

# !!!! make sure a .env file is present in the same folder than this file, with content !!
# GIT_PASSWORD=xxxxx
# POSTGRES_PASSWORD=xxxxx

sudo docker-compose pull
sudo docker-compose up
