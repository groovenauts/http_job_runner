# HTTP Job Runner

[README.en.md](./README.en.md)

## 概要

HTTP Job Runnerは非同期でジョブを実行する機能を提供します。
ジョブの実行を依頼するHTTPリクエストを送ると、非同期でジョブが実行されます。
その際、各ジョブの状態を確認することも可能です。

## 利用方法

HTTP Job Runnerは[Docker](https://www.docker.com/)のコンテナとして利用可能です。
実際に実行されるジョブはコマンドとして実装すると、以下の手順でジョブの実行環境を構築できます。

1. HTTP Job RunnerのDockerイメージをベースにジョブのコマンドを含む新しいDockerイメージを作成します。
2. ジョブの実行を管理するためのMySQLサーバを起動します。
3. 作成したDockerイメージから以下の２つの種類のコンテナを起動します。
    - HTTPサーバ
    - delayed_jobワーカー

これらが起動した状態で、HTTPサーバに対してコマンドを実行するHTTPリクエストを送ると、
delayed_jobワーカーが非同期でコマンドを実行します。

HTTP Job RunnerのDockerイメージをベースに新しいDockerイメージを作る方法については、
[HTTP Job Runnerアプリのイメージをリリースする](../doc/release_app_image.ja.md) を
参照してください。


## [重要] ユーザ認証の実装

HTTP Job Runnerにはユーザ認証は実装されておりません。ユーザ認証の仕組みがない環境で
利用されると誰でもアクセスできてしまう状態になり、不正な操作をされたりデータが漏洩して
しまう恐れがあります。

これを回避するためには、OAuth2による認証を提供する[MAGELLAN](http://www.magellanic-clouds.com/)をご利用いただくか、
別途ユーザ認証の仕組みを作成していただく必要があります。[MAGELLAN](http://www.magellanic-clouds.com/)については後述します。

## MAGELLANでの利用

[MAGELLAN](http://www.magellanic-clouds.com/)は、大量のアクセスに対してもコンテナを
スケールアウトさせることでシステムの可用性を高めることができるプラットフォームサービスです。
HTTP/HTTPSの他、MQTTにも対応しております。

HTTP Job Runnerで作ったアプリケーションをMAGELLANへデプロイする具体的な方法については以下を参照してください。

- [HTTP Job Runnerアプリをデプロイする(ブラウザ版)](https://github.com/groovenauts/http_job_runner/blob/master/doc/deploy_to_magellan_with_browser.ja.md)
- [HTTP Job Runnerアプリをデプロイする(コマンド版)](https://github.com/groovenauts/http_job_runner/blob/master/doc/deploy_to_magellan_with_command.ja.md)

https://github.com/groovenauts/http_job_runner/blob/master/README.md



## HTTP Job Runnerの開発

### MySQLコンテナを使ったローカルでのテスト

```bash
$ bundle exec brocket build
$ docker run --name mysql1 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -e MYSQL_USER=app1 -e MYSQL_PASSWORD=password -d mysql:latest
$ docker exec mysql1 mysqladmin -u root create http_job_runner_production
$ docker exec mysql1 mysql -u root -e "GRANT ALL PRIVILEGES ON http_job_runner_production.* TO  'app1'@'%';"
$ docker run --rm --link mysql1:mysql http_job_runner:0.0.1 bin/rake db:migrate
$ docker run -d --link mysql1:mysql -p 3000:3000 http_job_runner:0.0.1 bin/rails server --bind=0.0.0.0 --port 3000
$ docker run -d --link mysql1:mysql http_job_runner:0.0.1 bin/delayed_job run
```

