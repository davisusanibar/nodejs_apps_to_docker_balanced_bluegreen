#!/bin/sh
sudo docker ps -q | xargs sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}  {{ .Name }} {{ .Config.Image }} {{ .State.Running }} {{ .Id }}'
