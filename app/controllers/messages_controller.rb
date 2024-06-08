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
    message_count = 0
    message_number = 0
    $lock_manager.lock("#{params[:application_token]}_#{params[:chat_chat_number]}_message_creation_lock", 2000) do |locked|
      if locked
        message_count = $redis.incr("#{params[:application_token]}_#{params[:chat_chat_number]}_message_count")
        message_number = $redis.incr("#{params[:application_token]}_#{params[:chat_chat_number]}_message_number")
      end
    end
    if @chat
      CreateMessageJob.perform_async(params[:application_token], params[:chat_chat_number], message_number, message_count, params[:message_body])
      render json: {"message_number": message_number, "message_body": params[:message_body]}, status: :created
    else
      render json: {error: "Incorrect token or chat number"}, status: :unprocessable_entity
    end 
  end

  # PATCH/PUT /messages/1
  def update
    if @chat
      UpdateMessageJob.perform_async( params[:application_token], 
                                      params[:chat_chat_number], 
                                      params[:message_number],
                                      params[:message_body])
      render json: {"message_number": params[:message_number], "message_body": params[:message_body]}
    else
      render json: {error: "Incorrect token or chat number"}, status: :unprocessable_entity
    end

  end

  # DELETE /messages/1
  def destroy
    message_count = $redis.decr("#{params[:application_token]}_#{params[:chat_chat_number]}_message_count")
    @chat.with_lock do
      @chat.update(message_count: message_count)
    end
    @message.destroy!
  end

  def search
    if @chat
      unless params[:query].blank?
        @results = Message.search(params[:query], fields:[:message_body], where:{chat_id:params[:chat_chat_number]})
        render json: @results.results,:except=> [:id, :chat_id], status: :ok
      end
    else
      render json: {error: "Incorrect token or chat number"}, status: :unprocessable_entity
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
      params.require(:message).permit(:message_body, :message_number, :query) #should i remove message_number?
    end
end
