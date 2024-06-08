class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[ show update destroy ]

  # GET /applications
  def index
    @applications = Application.all

    render json: @applications, :except=> [:id]
  end

  # GET /applications/1
  def show
    render json: @application,:except=> [:id]
  end

  # POST /applications
  def create
    token = SecureRandom.urlsafe_base64(nil, false)
    CreateApplicationJob.perform_async(params[:name], token)
    render json: {"token":token, name: params[:name]}, status: :created
  end

  # PATCH/PUT /applications/1
  def update
    if @application
      UpdateApplicationJob.perform_async(params[:name], params[:token])
      render json: {"token":params[:token], name: params[:name]}
    else
      render json: {error: "Incorrect token"}, status: :unprocessable_entity
    end
  end

  # DELETE /applications/1
  def destroy
    # should we set to zero or delete?
    # needs locking
    $redis.del("#{@application.token}_chat_count")
    $redis.del("#{@application.token}_chat_number") 
    @application.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by("token": params[:token])
    end

    # Only allow a list of trusted parameters through.
    def application_params
      params.require(:application).permit( :name)
    end
end
