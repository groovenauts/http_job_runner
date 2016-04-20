class Delayed::JobsController < ApplicationController
  before_action :set_delayed_job, only: [:show, :update, :destroy]

  # GET /delayed/jobs
  # GET /delayed/jobs.json
  def index
    @delayed_jobs = Delayed::Job.all

    render json: @delayed_jobs
  end

  # GET /delayed/jobs/1
  # GET /delayed/jobs/1.json
  def show
    render json: @delayed_job
  end

  # POST /delayed/jobs
  # POST /delayed/jobs.json
  def create
    @delayed_job =
      LoggerPipe.delay(queue: delayed_job_params[:queue], priority: delayed_job_params[:queue]).
      run(delayed_job_params[:command])

    if @delayed_job.save
      render json: @delayed_job, status: :created, location: @delayed_job
    else
      render json: @delayed_job.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /delayed/jobs/1
  # PATCH/PUT /delayed/jobs/1.json
  def update
    @delayed_job = Delayed::Job.find(params[:id])

    if @delayed_job.update(delayed_job_params)
      head :no_content
    else
      render json: @delayed_job.errors, status: :unprocessable_entity
    end
  end

  # DELETE /delayed/jobs/1
  # DELETE /delayed/jobs/1.json
  def destroy
    @delayed_job.destroy

    head :no_content
  end

  private

    def set_delayed_job
      @delayed_job = Delayed::Job.find(params[:id])
    end

    def delayed_job_params
      params.fetch(:job, {}).permit(:priority, :command, :queue)
    end

    # Delayed::Job is actually Delayed::Backend::ActiveRecord::Job.
    # So controller try to call methods like `delayed_backend_active_record_jobs_url`,
    # which aren't implemented. To resolve this problem, define aliases of
    # unimplemented methods
    orig = "delayed_backend_active_record_job"
    dest = "delayed_job"
    {
      orig.pluralize => dest.pluralize,
      "new_#{orig}"  => "new_#{dest}",
      "edit_#{orig}" => "edit_#{dest}",
      orig           => dest,
    }.each do |s,d|
      alias_method :"#{s}_path", :"#{d}_path"
      alias_method :"#{s}_url" , :"#{d}_url"
    end
end
