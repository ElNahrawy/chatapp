class ChatsController < ApplicationController
  before_action :set_application, only: %i[index create show destroy]
  before_action :set_chat, only: %i[show destroy] #add update if it will be added

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
    #@application = Application.find_by token: params[:application_token]
    chat_count = $redis.get("#{params[:application_token]}_chat_count")
    chat_number = $redis.get("#{params[:application_token]}_chat_number")
    @chat = @application.chats.new(chat_number: chat_number, message_count:0)

    if @chat.save
      $redis.set("#{params[:application_token]}_#{chat_number}_message_count", 1)
      $redis.set("#{params[:application_token]}_#{chat_number}_message_number", 1)
      $redis.incr("#{params[:application_token]}_chat_count")
      $redis.incr("#{params[:application_token]}_chat_number")
      @application.update(chat_count: chat_count)

      render json: @chat,:except=> [:id, :application_id], status: :created, location: application_chat_url(@application, @chat)
    else
      render json: @chat.errors, status: :unprocessable_entity
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
    @application.update(chat_count: chat_count)
    @chat.destroy!
  end

  private
    def set_application
      @application = Application.find_by(token: params[:application_token])
      #@application = Application.find(id: params[:application_id])
    end
    
    def set_chat
      @chat = @application.chats.find_by(chat_number: params[:chat_number]) if @application
    end
    # Use callbacks to share common setup or constraints between actions.
    # def set_chat
    #   @chat = Chat.find(params[:id])
    # end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat).permit(chat_number: params[:chat_number])
    end
end
