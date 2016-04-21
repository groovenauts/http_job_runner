# HTTP Job Runnerアプリをデプロイする(コマンド版)

## 事前準備

- [magellanのアカウント](http://www.magellanic-clouds.com/)
- rubyのインストール
- magellan-cliのインストール

### magellan-cliのインストール

```bash
$ echo "source 'https://rubygems.org'" > Gemfile
$ echo "gem 'magellan-cli'" >> Gemfile
$ bundle
```

### ログイン

```bash
$ bundle exec magellan login
```
メールアドレスとパスワードを入力します。

### HTTPサーバのデプロイ

```
$ bundle exec magellan-cli stage list
+---+-----+-----------------+---------------+------------+-------------+----------------+---------------+------------------+---------------------+-------+-----------------------------+---------------------------+----------------+---------------+--------------------+------------------+------------+------------+
|   | id  |     project     |     name      | stage_size | stage_type  | authentication | blocks_secret | max_worker_count | max_container_count | label | maintenance_window_start_at | maintenance_window_end_at | need_to_reload | container_num | release_job_status | last_released_at | can_update | can_delete |
+---+-----+-----------------+---------------+------------+-------------+----------------+---------------+------------------+---------------------+-------+-----------------------------+---------------------------+----------------+---------------+--------------------+------------------+------------+------------+
| * | 453 | DefaultProject1 | DefaultStage1 | micro      | development | true           |               | 1                | 100                 |       | 0                           | 0                         | false          | 0             |                    |                  | true       | true       |
+---+-----+-----------------+---------------+------------+-------------+----------------+---------------+------------------+---------------------+-------+-----------------------------+---------------------------+----------------+---------------+--------------------+------------------+------------+------------+

Total: 1
```

表示された一覧のいづれかの先頭に `*` が付いていることを確認します。


Cloud SQLのDBを作成します。

```bash
$ bundle exec magellan-cli cloudsql create hello_world_db
$ bundle exec magellan-cli cloudsql list
+---+------+----------------+---------+----------------+---------------------------------------------------+-----------------+-----------+------------+------------+--------------------------+--------------------------+----------------+------------------+
|   |  id  | stage_title_id | db_size |      name      |                   database_name                   |    username     | available | max_volume | suppressed |        created_at        |        updated_at        |    address     |     password     |
+---+------+----------------+---------+----------------+---------------------------------------------------+-----------------+-----------+------------+------------+--------------------------+--------------------------+----------------+------------------+
| * | 4139 | 6877           | micro   | hello_world_db | akm2_DefaultProject1_DefaultStage1_hello_world_db | uc44ccb3b6c401b | true      | 5242880    | false      | 2016-04-21T07:47:57.000Z | 2016-04-21T07:47:58.000Z | xxx.xxx.xxx.xx | xxxxxxxxxxxxxxxx |
+---+------+----------------+---------+----------------+---------------------------------------------------+-----------------+-----------+------------+------------+--------------------------+--------------------------+----------------+------------------+

Total: 1
```


次にMAGELLANのWorker `http_server` として dockerイメージ `groovenauts/http_job_runner_hello_world:0.0.2`
を登録します。

```
$ bundle exec magellan-cli worker create http_server groovenauts/http_job_runner_hello_world:0.0.2
$ bundle exec magellan-cli worker list
+---+-------+----------------------------------+-------------+--------+-----------------------------------------------+---------+---------+------------------+------------------+
|   |  id   |              stage               |    name     | status |                  image_name                   | log_dir | version | root_url_mapping | migration_status |
+---+-------+----------------------------------+-------------+--------+-----------------------------------------------+---------+---------+------------------+------------------+
| * | 12046 | [DefaultProject1]DefaultStage1#1 | hello_world | 1      | groovenauts/http_job_runner_hello_world:0.0.1 |         | 1       | true             | not_yet          |
+---+-------+----------------------------------+-------------+--------+-----------------------------------------------+---------+---------+------------------+------------------+

Total: 1
```

`http_server.yml` を以下の内容で作成します。

```yaml
# Worker リリース時に実行するコマンド
#   migration_command_1: Worker 初回リリース時にのみ実行させたいコマンド
#   migration_command_2: Worker 初回リリース以降のリリース毎に実行させたいコマンド
migration_command_1: "bundle exec rake db:migrate:reset db:seed"
migration_command_2: "bundle exec rake db:migrate"

# Worker に渡す環境変数
environment_vars_yaml: |
  # MAGELLAN 関連
  #   MAGELLAN_HTTP_WORKER:       Worker が HTTP 通信をする場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
  #   MAGELLAN_SUBSCRIBER_WORKER: Worker が Pub/Sub 機能を使用する場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
  MAGELLAN_HTTP_WORKER: 1
  MAGELLAN_SUBSCRIBER_WORKER: 0
  #  MySQL接続設定
  MYSQL_PORT_3306_TCP_ADDR: 104.199.147.37
  MYSQL_DATABASE_NAME: akm2_DefaultProject1_DefaultStage1_hello_world_db
  MYSQL_ENV_MYSQL_USER: uc44ccb3b6c401b
  MYSQL_ENV_MYSQL_PASSWORD: 019f1843fee97c42
  # Rails 関連
  RAILS_ENV: production
  SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
```



Workerの属性を更新します。

```
$ bundle exec magellan-cli worker update http_server.yml
$ bundle exec magellan-cli worker show
+------------------+-----------------------------------------------+
|      field       |                     value                     |
+------------------+-----------------------------------------------+
| id               | 12048                                         |
| stage_version_id | [DefaultProject1]DefaultStage1#1              |
| name             | http_server                                   |
| status           | 1                                             |
| image_name       | groovenauts/http_job_runner_hello_world:0.0.1 |
| log_dir          |                                               |
| version          | 1                                             |
| root_url_mapping | true                                          |
| created_at       | 2016-04-21T07:45:31.000Z                      |
| updated_at       | 2016-04-21T08:09:47.000Z                      |
| migration_status | not_yet                                       |
+------------------+-----------------------------------------------+

============== migration_command_1 ===============
bundle exec rake db:migrate:reset db:seed

============== migration_command_2 ===============
bundle exec rake db:migrate

================== run_command ===================

============= environment_vars_yaml ==============
# MAGELLAN 関連
#   MAGELLAN_HTTP_WORKER:       Worker が HTTP 通信をする場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
#   MAGELLAN_SUBSCRIBER_WORKER: Worker が Pub/Sub 機能を使用する場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
MAGELLAN_HTTP_WORKER: 1
MAGELLAN_SUBSCRIBER_WORKER: 0
#  MySQL接続設定
MYSQL_PORT_3306_TCP_ADDR: 104.199.147.37
MYSQL_DATABASE_NAME: akm2_DefaultProject1_DefaultStage1_hello_world_db
MYSQL_ENV_MYSQL_USER: uc44ccb3b6c401b
MYSQL_ENV_MYSQL_PASSWORD: 019f1843fee97c42
# Rails 関連
RAILS_ENV: production
SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
```


デプロイするコンテナを準備します。

```
$ bundle exec magellan-cli stage prepare
+---+-------+----------------------------------+----------------+-----------------------------------------------+-------------------------+-------+-----------------------------------------------+----------+------------+--------------+------------+
|   |  id   |              stage               | vm_instance_id |                     image                     | container_assignment_id | name  |                  image_name                   |  status  | docker_cid | memory_limit | cpu_shares |
+---+-------+----------------------------------+----------------+-----------------------------------------------+-------------------------+-------+-----------------------------------------------+----------+------------+--------------+------------+
|   | 28881 | [DefaultProject1]DefaultStage1#1 | 184            | groovenauts/http_job_runner_hello_world:0.0.1 | 23835                   | 2e101 | groovenauts/http_job_runner_hello_world:0.0.1 | planning |            | 200M         | 2          |
+---+-------+----------------------------------+----------------+-----------------------------------------------+-------------------------+-------+-----------------------------------------------+----------+------------+--------------+------------+

Total: 1
$ bundle exec magellan-cli container show 28881
+-------------------------+-----------------------------------------------+
|          field          |                     value                     |
+-------------------------+-----------------------------------------------+
| id                      | 28881                                         |
| stage_version_id        | [DefaultProject1]DefaultStage1#1              |
| vm_instance_id          | 184                                           |
| container_image_id      | groovenauts/http_job_runner_hello_world:0.0.1 |
| container_assignment_id | 23835                                         |
| name                    | 2e101                                         |
| image_name              | groovenauts/http_job_runner_hello_world:0.0.1 |
| status                  | planning                                      |
| docker_cid              |                                               |
| memory_limit            | 200M                                          |
| cpu_shares              | 2                                             |
| created_at              | 2016-04-21T08:10:23.000Z                      |
| updated_at              | 2016-04-21T08:10:23.000Z                      |
+-------------------------+-----------------------------------------------+

============= docker_properties_json =============

=================== links_yaml ===================

================ publishings_yaml ================

================== volumes_yaml ==================
--- {}

==================== env_yaml ====================
---
MAGELLAN_HTTP_WORKER: 1
MAGELLAN_SUBSCRIBER_WORKER: 0
MYSQL_PORT_3306_TCP_ADDR: 104.199.147.37
MYSQL_DATABASE_NAME: akm2_DefaultProject1_DefaultStage1_hello_world_db
MYSQL_ENV_MYSQL_USER: uc44ccb3b6c401b
MYSQL_ENV_MYSQL_PASSWORD: 019f1843fee97c42
RAILS_ENV: production
SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
MAGELLAN_WORKER_AMQP_VHOST: "/d8en6b8gwlkoz3gt"
MAGELLAN_WORKER_REQUEST_QUEUE: d8en6b8gwlkoz3gt.DefaultStage1.1.http_server
MAGELLAN_WORKER_RESPONSE_EXCHANGE: d8en6b8gwlkoz3gt.DefaultStage1.reply
MAGELLAN_WORKER_AMQP_USER: d8en6b8gwlkoz3gt
MAGELLAN_WORKER_AMQP_PASS: workerpw
MAGELLAN_PUBLISH_AMQP_VHOST: "/d8en6b8gwlkoz3gt"
MAGELLAN_PUBLISH_AMQP_USER: d8en6b8gwlkoz3gt
MAGELLAN_PUBLISH_AMQP_PASS: workerpw
MAGELLAN_PUBLISH_EXCHANGE: d8en6b8gwlkoz3gt.DefaultStage1.mqtt
MAGELLAN_PUBLISH_MESSAGE_SIZE_LIMIT: '1024'
```

リリースします。

```
$ bundle exec magellan-cli stage release_now
completed
```

HTTPで接続できるか確認します。

```
$ bundle exec magellan-cli http get /jobs.json
[]
$ bundle exec magellan-cli http post /jobs.json -d "job[command]=bin/hello_world.sh"
{"id":1,"priority":0,"attempts":0,"handler":"--- !ruby/object:Delayed::PerformableMethod\nobject: !ruby/module 'Command'\nmethod_name: :run\nargs:\n- bin/hello_world.sh\n","last_error":null,"run_at":"2016-04-21T08:35:07.659Z","locked_at":null,"failed_at":null,"locked_by":null,"queue":null,"created_at":"2016-04-21T08:35:07.660Z","updated_at":"2016-04-21T08:35:07.660Z"}

$ bundle exec magellan-cli http get /jobs.json
[{"id":1,"priority":0,"attempts":0,"last_error":null,"run_at":"2016-04-21T08:35:07.000Z","locked_at":null,"failed_at":null,"locked_by":null,"queue":null,"created_at":"2016-04-21T08:35:07.000Z","updated_at":"2016-04-21T08:35:07.000Z","command":"bin/hello_world.sh"}]
```



### delayed_jobワーカーのデプロイ

2016-04現在のMAGELLANでは一つのステージに一つの種類のワーカーしか登録できないので、
delayed_jobのワーカーを動かすためにステージを新たに追加します。

```bash
$ bundle exec magellan-cli stage create JobWorker -t development
$ bundle exec magellan-cli stage list
+---+------+-----------------+---------------+------------+-------------+----------------+---------------+------------------+---------------------+-------+-----------------------------+---------------------------+----------------+---------------+--------------------+----------------------+------------+------------+
|   |  id  |     project     |     name      | stage_size | stage_type  | authentication | blocks_secret | max_worker_count | max_container_count | label | maintenance_window_start_at | maintenance_window_end_at | need_to_reload | container_num | release_job_status |   last_released_at   | can_update | can_delete |
+---+------+-----------------+---------------+------------+-------------+----------------+---------------+------------------+---------------------+-------+-----------------------------+---------------------------+----------------+---------------+--------------------+----------------------+------------+------------+
| * | 6879 | DefaultProject1 | JobWorker     | micro      | development | true           |               | 1                | 5                   |       | 0                           | 0                         | false          | 0             |                    |                      | true       | true       |
|   | 6877 | DefaultProject1 | DefaultStage1 | micro      | development | true           |               | 1                | 5                   |       | 0                           | 0                         | false          | 1             | completed          | 2016-04-21T08:30:32Z | true       | true       |
+---+------+-----------------+---------------+------------+-------------+----------------+---------------+------------------+---------------------+-------+-----------------------------+---------------------------+----------------+---------------+--------------------+----------------------+------------+------------+

Total: 2
```


次にMAGELLANのWorker `delayed_job` として dockerイメージ `groovenauts/http_job_runner_hello_world:0.0.2`
を登録します。

```
$ bundle exec magellan-cli worker create delayed_job groovenauts/http_job_runner_hello_world:0.0.2
$ bundle exec magellan-cli worker list
+---+-------+------------------------------+-------------+--------+-----------------------------------------------+---------+---------+------------------+------------------+
|   |  id   |            stage             |    name     | status |                  image_name                   | log_dir | version | root_url_mapping | migration_status |
+---+-------+------------------------------+-------------+--------+-----------------------------------------------+---------+---------+------------------+------------------+
| * | 12052 | [DefaultProject1]JobWorker#1 | delayed_job | 1      | groovenauts/http_job_runner_hello_world:0.0.2 |         | 1       | true             | not_yet          |
+---+-------+------------------------------+-------------+--------+-----------------------------------------------+---------+---------+------------------+------------------+

Total: 1
```

`delayed_job.yml` を以下の内容で作成します。

```yaml
run_command: "bundle exec bin/delayed_job start"

# Worker に渡す環境変数
environment_vars_yaml: |
  # MAGELLAN 関連
  #   MAGELLAN_HTTP_WORKER:       Worker が HTTP 通信をする場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
  #   MAGELLAN_SUBSCRIBER_WORKER: Worker が Pub/Sub 機能を使用する場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
  MAGELLAN_HTTP_WORKER: 0
  MAGELLAN_SUBSCRIBER_WORKER: 0
  #  MySQL接続設定
  MYSQL_PORT_3306_TCP_ADDR: 104.199.147.37
  MYSQL_DATABASE_NAME: akm2_DefaultProject1_DefaultStage1_hello_world_db
  MYSQL_ENV_MYSQL_USER: uc44ccb3b6c401b
  MYSQL_ENV_MYSQL_PASSWORD: 019f1843fee97c42
  # Rails 関連
  RAILS_ENV: production
  SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
```

Workerの属性を更新します。

```
$ bundle exec magellan-cli worker update delayed_job.yml
$ bundle exec magellan-cli worker show
+------------------+-----------------------------------------------+
|      field       |                     value                     |
+------------------+-----------------------------------------------+
| id               | 12052                                         |
| stage_version_id | [DefaultProject1]JobWorker#1                  |
| name             | delayed_job                                   |
| status           | 1                                             |
| image_name       | groovenauts/http_job_runner_hello_world:0.0.2 |
| log_dir          |                                               |
| version          | 1                                             |
| root_url_mapping | true                                          |
| created_at       | 2016-04-21T08:43:59.000Z                      |
| updated_at       | 2016-04-21T08:46:52.000Z                      |
| migration_status | not_yet                                       |
+------------------+-----------------------------------------------+

============== migration_command_1 ===============

============== migration_command_2 ===============

================== run_command ===================
bundle exec bin/delayed_job start

============= environment_vars_yaml ==============
# MAGELLAN 関連
#   MAGELLAN_HTTP_WORKER:       Worker が HTTP 通信をする場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
#   MAGELLAN_SUBSCRIBER_WORKER: Worker が Pub/Sub 機能を使用する場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
MAGELLAN_HTTP_WORKER: 0
MAGELLAN_SUBSCRIBER_WORKER: 0
#  MySQL接続設定
MYSQL_PORT_3306_TCP_ADDR: 104.199.147.37
MYSQL_DATABASE_NAME: akm2_DefaultProject1_DefaultStage1_hello_world_db
MYSQL_ENV_MYSQL_USER: uc44ccb3b6c401b
MYSQL_ENV_MYSQL_PASSWORD: 019f1843fee97c42
# Rails 関連
RAILS_ENV: production
SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
```

リリースします。

```
$ bundle exec magellan-cli stage release_now
completed
```

ワーカーが動いたかどうかを確認します。

```
$ bundle exec magellan-cli stage logs
2016-04-21 17:48:30:1:2e501: 0.0.2: Pulling from groovenauts/http_job_runner_hello_world
2016-04-21 17:48:30:1:2e501: efd26ecc9548: Already exists
2016-04-21 17:48:30:1:2e501: a3ed95caeb02: Already exists
(snip)
2016-04-21 17:48:37:1:2e501: 04b2e725effd: Already exists
2016-04-21 17:48:37:1:2e501: Digest: sha256:4f0c50f3ec635c900a60bd1273f305ac75eb47096d9990df43beca5abc80793e
2016-04-21 17:48:37:1:2e501: Status: Image is up to date for groovenauts/http_job_runner_hello_world:0.0.2
2016-04-21 17:48:42:1:2e501: delayed_job: process with pid 14 started.
```

