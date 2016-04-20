# ## How To Release Container Image
#
# ### brocket command (recommend)
#
# $ cd http_job_runner
# $ bundle exec brocket release
#
# #### Dryrun
#
# You can check the commands which brocket calls by using this:
#
# $ bundle exec brocket release --dryrun
#
# It doesn't call the commands actually but show the commands.

# [config] IMAGE_NAME: "http_job_runner"
# [config]
# [config] DOCKER_PUSH_USERNAME: "groovenauts"
# [config] DOCKER_PUSH_EXTRA_TAG: "latest"
# [config]
# [config] WORKING_DIR: "."
# [config]

FROM ruby:2.3.0

COPY . /usr/app/http_job_runner

ENV RAILS_ENV production

# Magellan Proxy
# http://devcenter.magellanic-clouds.com/learning/how-to-make-magellan-web-app.html
ADD https://github.com/groovenauts/magellan-proxy/releases/download/v0.1.3/magellan-proxy-0.1.3_linux-amd64 /usr/app/magellan-proxy
RUN chmod +x /usr/app/magellan-proxy

WORKDIR /usr/app/http_job_runner
# RUN bin/setup # Don't migrate on build
RUN bundle install --without development test

# TODO use another application server
CMD /usr/app/magellan-proxy --port 3000 bundle exec rails s

