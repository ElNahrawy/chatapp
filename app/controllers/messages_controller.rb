class MessagesController < ApplicationController
  before_action :set_application, :set_chat
  before_action :set_message, only: %i[ show update destroy ]

  # GET /messages
  def index
    @messages = @chat.messages.all

    render json: @messages,:except=> [:id, :chat_id]
  end

  # GET /messages/1
  def show
    render json: @message,:except=> [:id, :chat_id]
  end

  # POST /messages
  def create
    message_count = $redis.get("#{params[:application_token]}_#{params[:chat_chat_number]}_message_count")
    message_number = $redis.get("#{params[:application_token]}_#{params[:chat_chat_number]}_message_number")
    puts "hamada"
    puts "#{params[:application_token]}_#{params[:chat_number]}_message_number"
    puts params
    @message = @chat.messages.new(message_body: params[:message_body],  message_number: message_number)

    if @message.save
      $redis.incr("#{params[:application_token]}_#{params[:chat_chat_number]}_message_count")
      $redis.incr("#{params[:application_token]}_#{params[:chat_chat_number]}_message_number")
      @chat.update(message_count: message_count)
      render json: @message,:except=> [:id, :chat_id], status: :created, location: application_chat_message_url(@application, @chat, @message)
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /messages/1
  def update
    if @message.update(message_body: params[:message_body])
      render json: @message,:except=> [:id, :chat_id]
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /messages/1
  def destroy
    message_count = $redis.decr("#{params[:application_token]}_#{params[:chat_chat_number]}_message_count")
    @chat.update(message_count: message_count)
    @message.destroy!
  end

  def search
    unless params[:query].blank?
      @results = Message.search(params[:query], fields:[:message_body])
      render json: @result, status: :ok
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Application.find_by(token: params[:application_token])
    end
    
    def set_chat
      @chat = @application.chats.find_by(chat_number: params[:chat_chat_number]) if @application
    end

    def set_message
      @message = @chat.messages.find_by(message_number: params[:message_number]) if @chat
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:message_body, :message_number) #should i remove message_number?
    end
end
