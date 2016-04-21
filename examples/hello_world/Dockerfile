# ## How To Release Container Image
#
# ### brocket command (recommend)
#
# $ cd http_job_runner/examples/hello_world
# $ bundle exec brocket build
# $ bundle exec brocket release

# [config] IMAGE_NAME: "http_job_runner_hello_world"
# [config] 
# [config] DOCKER_PUSH_USERNAME: "groovenauts"
# [config] DOCKER_PUSH_EXTRA_TAG: "latest"
# [config] 
# [config] WORKING_DIR: "."
# [config] 
# [config] GIT_TAG_PREFIX: "examples/hello_world/"

FROM groovenauts/http_job_runner:0.0.2

COPY bin/* $JOB_HOME/bin/
