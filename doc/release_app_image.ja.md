# HTTP Job Runnerアプリのイメージをリリースする

## 事前準備

- dockerのインストールとセットアップ

## 手順

### 1. `Dockerfile`を追加する

```
# ## How To Release Container Image
#
# ### brocket command (recommend)
#
# $ cd http_job_runner/examples/hello_world
# $ brocket build
# $ brocket release

# [config] IMAGE_NAME: "http_job_runner_hello_world"
# [config]
# [config] DOCKER_PUSH_USERNAME: "groovenauts"
# [config] DOCKER_PUSH_EXTRA_TAG: "latest"
# [config]
# [config] WORKING_DIR: "."
# [config]

FROM groovenauts/http_job_runner:0.0.1

COPY * $JOB_HOME
```

### 2. ビルドする

#### dockerコマンドでビルドする

```
docker build -t http_job_runner_hello_world:0.0.1 .
```

#### brocketでビルドする

もしRubyの環境が整っているのであれば [brocket](https://github.com/groovenauts/brocket) を使って
簡単にビルドすることができます。

```bash
$ gem install brocket
```

でインストールしたら、以下のようにディレクトリを移動して `brocket build` を実行するだけです。

```bash
$ cd http_job_runner/examples/hello_world
$ brocket build
```

### 3. リリースする

ビルドの動作確認が取れたら、[MAGELLAN](http://www.magellanic-clouds.com/)などの実行環境から参照できるレジストリに
ビルドしたイメージをpushする必要があります。

##### dockerコマンドの場合

```bash
$ docker push groovenauts/http_job_runner_hello_world:0.0.1
```

##### brocketコマンドの場合

```bash
$ brocket release
```

このコマンドでビルドとpushを行います。
