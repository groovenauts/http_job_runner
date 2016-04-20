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
    @delayed_job = Delayed::Job.new(delayed_job_params)

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
      params[:delayed_job]
    end
end
