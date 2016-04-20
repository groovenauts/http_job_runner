# HTTP Job Runner

## Test on local with mysql container

```bash
$ bundle exec brocket build
$ docker run --name mysql1 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -e MYSQL_USER=app1 -e MYSQL_PASSWORD=password -d mysql:latest
$ docker exec mysql1 mysqladmin -u root create http_job_runner_production
$ docker exec mysql1 mysql -u root -e "GRANT ALL PRIVILEGES ON http_job_runner_production.* TO  'app1'@'%';"
$ docker run --rm --link mysql1:mysql http_job_runner:0.0.1 bin/rake db:migrate
$ docker run -d --link mysql1:mysql -p 3000:3000 http_job_runner:0.0.1 bin/rails server --bind=0.0.0.0 --port 3000
$ docker run -d --link mysql1:mysql http_job_runner:0.0.1 bin/delayed_job run
```

