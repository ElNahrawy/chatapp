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
    @application = Application.new(name: application_params[:name], token:token, chat_count:0) 

    if @application.save
      $redis.set("#{token}_chat_count", 1)
      $redis.set("#{token}_chat_number", 1)   
      render json: @application,:except=> [:id] , status: :created, location: @application 
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applications/1
  def update
    if @application.update(application_params)
      render json: @application, :except=> [:id]
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # DELETE /applications/1
  def destroy
    # should we set to zero or delete?
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
