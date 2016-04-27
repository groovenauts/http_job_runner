# HTTP Job Runnerアプリをデプロイする(ブラウザ版)

## 事前準備

- [magellanのアカウント](http://www.magellanic-clouds.com/) の作成
- rubyのインストール
- magellan-cliのインストール

## magellanへのログイン


[magellanログイン](https://console.magellanic-clouds.com/) 画面からメールアドレスとパスワードを入力してログインします。


## HTTPサーバのデプロイ

このドキュメントでは、WorkerをDefaultProject1のDefaultStage1に作成することを前提としています。
別のProject名、Stage名を使用する場合は適切な名前に読み替えてください。

### Stageの作成

サイドメニューの「DefaultProject1」をクリックし一覧から「DefaultStage1」をクリックします。

**DefaultProject1またはDefaultStage1がない場合**

初期状態でDefaultProject1とDefaultStage1は作成されていますが、
削除している場合は以下の手順で作成してください。

DefaultProject1の作成方法（存在しない場合）

1. サイドメニューの「Projects」をクリックします。
2. 「Create Project」から以下の情報でProjectを作成します。
  - Project Name: DefaultProject1
3. プロジェクトを作成するとDefaultStage1は自動的に作成されています。

DefaultStage1の作成方法（存在しない場合）

1. サイドメニューの「Projects」をクリックします。
2. 一覧から「Create Stage」をクリックします。
3. 以下の情報でStageを作成します。
  - Stage Name: DefaultStage1
  - Stage Size: micro
  - Stage Type: development
  - Authentication: 認証あり

### DBの作成

サイドメニューの「DefaultProject1」をクリックし一覧から「DefaultStage1」をクリックします。

次に「DB」のタブを選択します。

「Create Cloud SQL」をクリックし、Nameに`hello_world_db`と入れて「Create」を押します。

### Workerの作成

サイドメニューの「DefaultProject1」をクリックし一覧から「DefaultStage1」をクリックします。

次に「Planning」のタブを選択します。

以下のWorker情報を入力し「Save」を押して保存してください。

| name                  | value                                         |
| --------------------- | --------------------------------------------- |
| Name                  | hello_world                                   |
| Image Name            | groovenauts/http_job_runner_hello_world:0.0.5 |
| Container Num         | 1                                             |
| Migration Command 1   | bundle exec rake db:migrate:reset db:seed     |
| Migration Command 2   | bundle exec rake db:migrate                   |

Environment Variables

```
# MAGELLAN 関連
#   MAGELLAN_HTTP_WORKER:       Worker が HTTP 通信をする場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
#   MAGELLAN_SUBSCRIBER_WORKER: Worker が Pub/Sub 機能を使用する場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
MAGELLAN_HTTP_WORKER: 1
MAGELLAN_SUBSCRIBER_WORKER: 0
# MySQL接続設定（下記のMySQL接続情報の取得方法を参照）
MYSQL_PORT_3306_TCP_ADDR: addressの内容
MYSQL_DATABASE_NAME: nameの内容
MYSQL_ENV_MYSQL_USER: usernameの内容
MYSQL_ENV_MYSQL_PASSWORD: passwordの内容
# Rails 関連
RAILS_ENV: production
SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
```

**MySQL接続情報の取得方法**

```
magellan-cli project select DefaultProject1
magellan-cli stage select DefaultStage1
magellan-cli cloudsql select hello_world_db
magellan-cli cloudsql select hello_world_db
magellan-cli cloudsql show
```

Saveを押してコンテナ起動



### 接続テスト

HTTPで接続できるか確認します。

```
$ bundle exec magellan-cli http get /jobs.json
[]
$ bundle exec magellan-cli http post /jobs.json -d "job[command]=bin/hello_world.sh"
{"id":1,"priority":0,"attempts":0,"handler":"--- !ruby/object:Delayed::PerformableMethod\nobject: !ruby/module 'Command'\nmethod_name: :run\nargs:\n- bin/hello_world.sh\n","last_error":null,"run_at":"2016-04-21T08:35:07.659Z","locked_at":null,"failed_at":null,"locked_by":null,"queue":null,"created_at":"2016-04-21T08:35:07.660Z","updated_at":"2016-04-21T08:35:07.660Z"}

$ bundle exec magellan-cli http get /jobs.json
[{"id":1,"priority":0,"attempts":0,"last_error":null,"run_at":"2016-04-21T08:35:07.000Z","locked_at":null,"failed_at":null,"locked_by":null,"queue":null,"created_at":"2016-04-21T08:35:07.000Z","updated_at":"2016-04-21T08:35:07.000Z","command":"bin/hello_world.sh"}]
```



## delayed_jobワーカーのデプロイ

2016-04現在のMAGELLANでは一つのステージに一つの種類のワーカーしか登録できないので、
delayed_jobのワーカーを動かすためにステージを新たに追加します。


#### Stageの作成

サイドメニューの「DefaultProject1」をクリックし一覧の「Create Stage」をクリックします。

以下の情報でStageを作成します。

| name           | value       |
| -------------- | ----------- |
| Stage Name     | JobWorker   |
| Stage Size     | micro       |
| Stage Type     | development |
| Authentication | 認証あり     |

#### Worker情報の作成・編集

サイドメニューの「DefaultProject1」をクリックし一覧から「JobWorker」をクリックします。

以下の情報でWorkerを作成します。

| item name             | value                                         |
| --------------------- | --------------------------------------------- |
| Name                  | delayed_job                                   |
| Image Name            | groovenauts/http_job_runner_hello_world:0.0.5 |
| Container Num         | 1                                             |
| Migration Command 1   | bundle exec rake db:migrate:reset db:seed     |
| Migration Command 2   | bundle exec rake db:migrate                   |

Environment Variables

```
# MAGELLAN 関連
#   MAGELLAN_HTTP_WORKER:       Worker が HTTP 通信をする場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
#   MAGELLAN_SUBSCRIBER_WORKER: Worker が Pub/Sub 機能を使用する場合は、1/true/yes/on のいずれかを設定。そうでない場合は、0/false/no/off のいずれかを設定。
MAGELLAN_HTTP_WORKER: 0
MAGELLAN_SUBSCRIBER_WORKER: 0
# MySQL接続設定（hello_worldワーカーと同じ内容）
MYSQL_PORT_3306_TCP_ADDR: addressの内容
MYSQL_DATABASE_NAME: nameの内容
MYSQL_ENV_MYSQL_USER: usernameの内容
MYSQL_ENV_MYSQL_PASSWORD: passwordの内容
# Rails 関連
RAILS_ENV: production
SECRET_KEY_BASE: d6295088a32acfc29a844a0bac73d5660bebfb6e5d0a81eb49f4e3428f79713638ddd3caa607e1906fdeb874115200c0fd3dc3c55ad92e7030b729e61b0eec6a
RUN_MODE: delayed_job
```

**リリースします。**

起動する

**ワーカーが動いたかどうかを確認します。**

Logsのタブを見る



```
$ bundle exec magellan-cli stage logs
2016-04-21 17:48:30:1:2e501: 0.0.5: Pulling from groovenauts/http_job_runner_hello_world
2016-04-21 17:48:30:1:2e501: efd26ecc9548: Already exists
2016-04-21 17:48:30:1:2e501: a3ed95caeb02: Already exists
(snip)
2016-04-21 17:48:37:1:2e501: 04b2e725effd: Already exists
2016-04-21 17:48:37:1:2e501: Digest: sha256:4f0c50f3ec635c900a60bd1273f305ac75eb47096d9990df43beca5abc80793e
2016-04-21 17:48:37:1:2e501: Status: Image is up to date for groovenauts/http_job_runner_hello_world:0.0.5
2016-04-21 17:48:42:1:2e501: delayed_job: process with pid 14 started.
```
