#!/usr/bin/env bash
export GIT_PASSWORD=Asterope123
export POSTGRES_PASSWORD=very_secret
sudo docker-compose -f docker-compose-registry-unsecure.yml up
