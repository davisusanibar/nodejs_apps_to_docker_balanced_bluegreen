# nodejs_apps_to_docker_balanced_bluegreen
To tes blue green deployment with docker compose


We add this extra configuration:

1st: We build our docker-compose.
```yaml
sudo docker-compose up build
```

2nd: We start our docker-compose, but, only start consul app
```yaml
sudo docker-compose up -d consul
```

3rd: Create our key value that we are going to use to change dynamically to bluee / green deployment.
Put the key/value for our purpose:
```yaml
curl -X PUT -d 'blue' http://localhost:8500/v1/kv/bluegreen/deploy
```
Check if this value was stored or not:
```yaml
curl http://localhost:8500/v1/kv/bluegreen/deploy?raw
```

4.- Start all our app throughout:
```yaml
sudo docker-compose up -d --no-recreate
```

5.- This line have the main idea:  proxy_pass http://{{key "bluegreen/deploy"}};
```yaml
upstr```yamleam blue {
  least_conn;
  {{range service "production.appblue"}}server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;
  {{else}}server 127.0.0.1:65535; # force a 502{{end}}
}
upstream green {
  least_conn;
  {{range service "production.appgreen"}}server {{.Address}}:{{.Port}} max_fails=3 fail_timeout=60 weight=1;
  {{else}}server 127.0.0.1:65535; # force a 502{{end}}
}
server {
  listen 80 default_server;

  location / {
    proxy_pass http://{{key "bluegreen/deploy"}};
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

6.- Check the nginx configuration (it should be generated with blue app_stream):
```yaml

root@8c64c9853f47:/# cat /etc/nginx/conf.d/app.conf
upstream blue {
  least_conn;
  server 172.17.42.1:32768 max_fails=3 fail_timeout=60 weight=1;

}

upstream green {
  least_conn;
  server 172.17.42.1:32769 max_fails=3 fail_timeout=60 weight=1;

}


server {
  listen 80 default_server;

  location / {
    proxy_pass http://green;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

7.- Testing:
```yaml
curl -X PUT -d 'green' http://localhost:8500/v1/kv/bluegreen/deploy
curl http://localhost:8500/v1/kv/bluegreen/deploy?raw
```
