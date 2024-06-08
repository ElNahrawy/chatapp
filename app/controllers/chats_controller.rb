class ChatsController < ApplicationController
  before_action :set_application, only: %i[index create show destroy]
  before_action :set_chat, only: %i[show destroy] 

  # GET /chats
  def index
    @chats = @application.chats.all

    render json: @chats,:except=> [:id, :application_id]
  end

  # GET /chats/1
  def show
    render json: @chat,:except=> [:id, :application_id]
  end

  # POST /chats
  def create
    chat_count = 0
    chat_number = 0
    if @application
      $lock_manager.lock("#{params[:application_token]}_chat_creation_lock", 2000) do |locked|
        if locked
          chat_count = $redis.incr("#{params[:application_token]}_chat_count")
          chat_number = $redis.incr("#{params[:application_token]}_chat_number")
        end
      end
      CreateChatJob.perform_async(params[:application_token], chat_number, chat_count)
      render json: {"chat_number": chat_number}, status: :created
    else
      render json: {error: "Incorrect token"}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /chats/1
  # def update
  #   if @chat.update(chat_params)
  #     render json: @chat,:except=> [:id, :application_id]
  #   else
  #     render json: @chat.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /chats/1
  def destroy
    $redis.del("#{params[:application_token]}_#{params[:chat_number]}_message_count")
    $redis.del("#{params[:application_token]}_#{params[:chat_number]}_message_number")
    
    chat_count = $redis.decr("#{params[:application_token]}_chat_count")
    @application.with_lock do
      @application.update(chat_count: chat_count)
    end
    @chat.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by(token: params[:application_token])
    end
    
    def set_chat
      @chat = @application.chats.find_by(chat_number: params[:chat_number]) if @application
    end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat).permit(chat_number: params[:chat_number])
    end
end
